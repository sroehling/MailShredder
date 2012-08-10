//
//  MailSyncController.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailClientServerSyncController.h"
#import "DataModelController.h"
#import "DateHelper.h"
#import "EmailInfo.h"
#import "MsgPredicateHelper.h"
#import "EmailDomain.h"
#import "EmailAddress.h"
#import "MailAddressHelper.h"
#import "EmailFolder.h"
#import "AppHelper.h"
#import "EmailAccount.h"
#import "KeychainFieldInfo.h"
#import "SharedAppVals.h"
#import "MailSyncConnectionContext.h"
#import "LocalizationHelper.h"

#define SYNC_PROGRESS_UPDATE_THRESHOLD 0.05

@implementation MailClientServerSyncController

@synthesize mainThreadDmc;
@synthesize progressDelegate;

-(id)initWithMainThreadDataModelController:(DataModelController*)theMainThreadDmc
	andProgressDelegate:(id<MailSyncProgressDelegate>)theProgressDelegate
{
	self = [super init];
	if(self)
	{		
		assert(theMainThreadDmc != nil);
		self.mainThreadDmc = theMainThreadDmc;
		
		assert(theProgressDelegate != nil);
		self.progressDelegate = theProgressDelegate;

	}
	return self;
}



-(id)init
{
	assert(0);
	return nil;
}

-(void)dealloc
{
	[mainThreadDmc release];
	[super dealloc];
}

-(EmailInfo*)emailInfoFromServerMsg:(CTCoreMessage*)msg 
		andFolderInfo:(EmailFolder*)folderInfo andCurrentAddresses:(NSMutableDictionary*)currEmailAddressByAddress
		inDataModelController:(DataModelController*)mailSyncDmc
{
	EmailInfo *newEmailInfo = (EmailInfo*) [mailSyncDmc insertObject:EMAIL_INFO_ENTITY_NAME];
	
	newEmailInfo.sendDate = msg.senderDate;
	newEmailInfo.from = msg.sender.email;
	newEmailInfo.subject = msg.subject;
	newEmailInfo.messageId = msg.uid;
	newEmailInfo.domain = [MailAddressHelper emailAddressDomainName:msg.sender.email];
	
	NSSet *recipients = [msg to];
	for(CTCoreAddress *toAddress in recipients)
	{
		NSLog(@"Recipient: %@",toAddress.email);
		EmailAddress *recipientAddress = [EmailAddress findOrAddAddress:toAddress.email 
					withCurrentAddresses:currEmailAddressByAddress 
					inDataModelController:mailSyncDmc];
		[newEmailInfo addRecipientAddressesObject:recipientAddress];

	}
	
	newEmailInfo.folderInfo = folderInfo;
	newEmailInfo.folder = folderInfo.folderName;
	
	return newEmailInfo;

}

- (void)mailSyncThreadDidSaveNotificationHandler:(NSNotification *)notification
{
    // This method is invoked as a subscriber/call-back for saves the to NSManagedObjectContext
	// used to synchronize the email information on a dedicated thread. This will in turn 
	// trigger the main thread to perform updates on to the appropriate NSFetchedResultsControllers,
	// table views, etc.
    [self.mainThreadDmc.managedObjectContext 
		performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) 
		withObject:notification waitUntilDone:NO];

}

-(MailSyncConnectionContext *)setupConnectionContext
{
	MailSyncConnectionContext *connectionContext = [[MailSyncConnectionContext alloc] 
		initWithMainThreadDmc:self.mainThreadDmc];

	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(mailSyncThreadDidSaveNotificationHandler:)
		name:NSManagedObjectContextDidSaveNotification 
		object:connectionContext.syncDmc.managedObjectContext];

	return connectionContext;
}

-(void)teardownConnectionContext:(MailSyncConnectionContext*)connectionContext
{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
			name:NSManagedObjectContextDidSaveNotification 
			object:connectionContext.syncDmc.managedObjectContext];
	[connectionContext release];
}

-(MailSyncConnectionContext*)establishConnection
{
	MailSyncConnectionContext *connectionContext = [self setupConnectionContext];
		
	[self.progressDelegate mailSyncConnectionStarted]; 
	
	@try
	{
    	[connectionContext connect];
		
		[self.progressDelegate mailSyncConnectionEstablished];

		return connectionContext;

	}
	@catch (NSException *exception) 
	{
		NSLog(@"Connection error");
		[self teardownConnectionContext:connectionContext];
		return nil;
	}
}

-(void)teardownConnection:(MailSyncConnectionContext*)connectionContext
{
	[self.progressDelegate mailSyncConnectionTeardownStarted];

	[connectionContext.syncDmc saveContext];
		
	[connectionContext disconnect];
		
	[self teardownConnectionContext:connectionContext];						
																	
	[self.progressDelegate mailSyncConnectionTeardownFinished];

}

-(void)syncMsgs:(MailSyncConnectionContext *)connectionContext
{
	NSMutableDictionary *currEmailAddressByAddress = [EmailAddress addressesByName:connectionContext.syncDmc];
	NSMutableDictionary *currDomainByDomainName = [EmailDomain emailDomainsByDomainName:connectionContext.syncDmc];
	NSMutableDictionary *currFolderByFolderName = [EmailFolder foldersByName:connectionContext.syncDmc];
	
	// Remove all the existing EmailInfo objects, since they'll be
	// re-synchronized below.
	NSSet *currEmailInfos = [connectionContext.syncDmc fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME];
	for(EmailInfo *currEmailInfo in currEmailInfos)
	{
		[connectionContext.syncDmc deleteObject:currEmailInfo];
	}
	
	NSSet *allFolders = [connectionContext.mailAcct allFolders];
	NSInteger numNewMsgs = 0;
	NSInteger totalMsgs = 0;
	for (NSString *folderName in allFolders)
	{
		NSLog(@"%@: Processing folder",folderName);
		CTCoreFolder *currFolder = [connectionContext.mailAcct folderWithPath:folderName];
		
		EmailFolder *emailFolder = [EmailFolder findOrAddFolder:currFolder.path inExistingFolders:currFolderByFolderName 
			withDataModelController:connectionContext.syncDmc];
		
		if(currFolder.totalMessageCount > 0)
		{
			// set the toIndex to 0 so all messages are loaded
			NSSet *serverMsgSet = [currFolder messageObjectsFromIndex:1 toIndex:0];
			NSLog(@"%@: ... done getting message list",folderName);

			for(CTCoreMessage *msg in serverMsgSet)
			{
				NSLog(@"Sync msg: uid= %@, msg id = %@, send date = %@, subj = %@", msg.uid,msg.messageId,
					[DateHelper stringFromDate:msg.senderDate],msg.subject);
				EmailInfo *newEmailInfo = [self emailInfoFromServerMsg:msg andFolderInfo:emailFolder 
					andCurrentAddresses:currEmailAddressByAddress inDataModelController:connectionContext.syncDmc];
				
				[EmailAddress findOrAddAddress:newEmailInfo.from 
					withCurrentAddresses:currEmailAddressByAddress inDataModelController:connectionContext.syncDmc];
				
				[EmailDomain findOrAddDomainName:newEmailInfo.domain 
					withCurrentDomains:currDomainByDomainName inDataModelController:connectionContext.syncDmc];
				
				numNewMsgs ++;
					
			}
		}
		
		NSLog(@"%@: ... done synchronizing message list",folderName);
		NSLog(@"-------");
		
	}

	NSLog(@"Done synchronizing messages: new msgs = %d, total server msgs = %d",
		numNewMsgs, totalMsgs);

}

-(void)syncFailedAlert
{
		UIAlertView *syncFailedAlert = [[[UIAlertView alloc] initWithTitle:
				LOCALIZED_STR(@"MESSAGE_SYNC_FAILURE_ALERT_TITLE")
			message:LOCALIZED_STR(@"MESSAGE_SYNC_FAILURE_ALERT_MSG") delegate:self 
			cancelButtonTitle:LOCALIZED_STR(@"MESSAGE_SYNC_FAILURE_ALERT_BUTTON_TITLE") 
			otherButtonTitles:nil] autorelease];
		[syncFailedAlert show];
}

-(void)syncWithServerThread
{
	MailSyncConnectionContext *connectionContext = [self establishConnection];
	
	if(connectionContext != nil)
	{
		[self syncMsgs:connectionContext];
		
		connectionContext.emailAcctInfo.lastSync = [NSDate date];
			
		[self teardownConnection:connectionContext];

		[self.progressDelegate mailSyncComplete:TRUE];

	}
	else 
	{
		[self performSelectorOnMainThread:@selector(syncFailedAlert) 
			withObject:self waitUntilDone:FALSE];
	
		[self.progressDelegate mailSyncComplete:FALSE];
		
	}
	
}

-(void)syncWithServerInBackgroundThread
{
	[NSThread detachNewThreadSelector:@selector(syncWithServerThread) toTarget:self withObject:nil];		
}

-(void)deleteMarkedMsgs:(MailSyncConnectionContext*)connectionContext
{
	NSSet *allFolders = [connectionContext.mailAcct allFolders];
	NSMutableDictionary *folderByPath = [[NSMutableDictionary alloc] init];
	for (NSString *folderName in allFolders)
	{
		CTCoreFolder *serverFolder = [connectionContext.mailAcct folderWithPath:folderName];
		[folderByPath setObject:serverFolder forKey:folderName];
	}
	
	NSMutableSet *serverFoldersToExpunge = [[NSMutableSet alloc] init];
		
	CGFloat deleteProgress = 0.0;
	NSUInteger numMsgsDeleted = 0;
		
	NSArray *msgsMarkedForDeletion = [connectionContext.syncDmc fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME 
		andPredicate:[MsgPredicateHelper markedForDeletion]];
	for(EmailInfo *markedForDeletion  in msgsMarkedForDeletion)
	{
		NSLog(@"Deleting msg: msg ID = %@, subject = %@",markedForDeletion.messageId,
			markedForDeletion.subject);
		CTCoreFolder *msgFolder = (CTCoreFolder*)[folderByPath 
			objectForKey:markedForDeletion.folderInfo.folderName];
		if(msgFolder != nil)
		{
			NSLog(@"Deleting msg: uid= %@, send date = %@, subj = %@", markedForDeletion.messageId,
					[DateHelper stringFromDate:markedForDeletion.sendDate],markedForDeletion.subject);

			CTCoreMessage *msgMarkedForDeletion = [msgFolder messageWithUID:markedForDeletion.messageId];
			[msgFolder setFlags:CTFlagDeleted forMessage:msgMarkedForDeletion];
			[serverFoldersToExpunge addObject:msgFolder];
		}
		
		numMsgsDeleted ++;
		CGFloat currentProgress = (CGFloat)numMsgsDeleted/((CGFloat)[msgsMarkedForDeletion count]);
		if((currentProgress - deleteProgress) >= SYNC_PROGRESS_UPDATE_THRESHOLD)
		{
			deleteProgress = currentProgress;
			[self.progressDelegate mailSyncUpdateProgress:deleteProgress];
		}
			
	}
	
	if([serverFoldersToExpunge count] > 0)
	{
		for(CTCoreFolder *sererFolderWithDeletedMsgs in serverFoldersToExpunge)
		{
			[sererFolderWithDeletedMsgs expunge];
		}
	}
	
	for(EmailInfo *markedForDeletion  in msgsMarkedForDeletion)
	{
		[connectionContext.syncDmc deleteObject:markedForDeletion];
	}
	
	[serverFoldersToExpunge release];
	[folderByPath release];

}

-(void)deleteMarkedMsgsThread
{

	MailSyncConnectionContext *connectionContext = [self establishConnection];	
	
	if(connectionContext != nil)
	{
		[self deleteMarkedMsgs:connectionContext];
		[self teardownConnection:connectionContext];
		[self.progressDelegate mailSyncComplete:TRUE];
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(syncFailedAlert) 
			withObject:self waitUntilDone:FALSE];

		[self.progressDelegate mailSyncComplete:FALSE];
	}
	
}

-(void)deleteMarkedMsgsInBackgroundThread
{
	[NSThread detachNewThreadSelector:@selector(deleteMarkedMsgsThread) toTarget:self withObject:nil];		
}


@end
