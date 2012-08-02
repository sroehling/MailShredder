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

@implementation MailClientServerSyncController

@synthesize mailAcct;
@synthesize appDataDmc;

-(id)initWithDataModelController:(DataModelController*)theAppDataDmc
{
	self = [super init];
	if(self)
	{		
		assert(theAppDataDmc != nil);
		self.appDataDmc = theAppDataDmc;
	
	}
	return self;
}

-(void)connect
{
	self.mailAcct = [[CTCoreAccount alloc] init];
	[self.mailAcct connectToServer:@"debianvm" port:143
		connectionType:CONNECTION_TYPE_PLAIN
		authType:IMAP_AUTH_TYPE_PLAIN 
		login:@"testimapuser@debianvm.local" password:@"pass"]; 
	
}

-(void)disconnect
{
	if(self.mailAcct != nil)
	{
		[self.mailAcct disconnect];
		self.mailAcct = nil;
	}
}

-(id)init
{
	assert(0);
	return nil;
}

-(void)dealloc
{
	[mailAcct release];
	[appDataDmc release];
	[super dealloc];
}

-(EmailInfo*)emailInfoFromServerMsg:(CTCoreMessage*)msg andFolderInfo:(EmailFolder*)folderInfo
{
	EmailInfo *newEmailInfo = (EmailInfo*) [self.appDataDmc insertObject:EMAIL_INFO_ENTITY_NAME];
	
	newEmailInfo.sendDate = msg.senderDate;
	newEmailInfo.from = msg.sender.email;
	newEmailInfo.subject = msg.subject;
	newEmailInfo.messageId = msg.uid;
	newEmailInfo.domain = [MailAddressHelper emailAddressDomainName:msg.sender.email];
	
	newEmailInfo.folderInfo = folderInfo;
	newEmailInfo.folder = folderInfo.folderName;
	
	return newEmailInfo;

}

-(void)syncWithServer
{

	[self connect];
	
	NSMutableDictionary *currEmailAddressByAddress = [EmailAddress addressesByName:self.appDataDmc];
	NSMutableDictionary *currDomainByDomainName = [EmailDomain emailDomainsByDomainName:self.appDataDmc];
	NSMutableDictionary *currFolderByFolderName = [EmailFolder foldersByName:self.appDataDmc];
	
	// Remove all the existing EmailInfo objects, since they'll be
	// re-synchronized below.
	NSSet *currEmailInfos = [self.appDataDmc fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME];
	for(EmailInfo *currEmailInfo in currEmailInfos)
	{
		[self.appDataDmc deleteObject:currEmailInfo];
	}
	[self.appDataDmc saveContext];
	
	NSSet *allFolders = [self.mailAcct allFolders];
	NSInteger numNewMsgs = 0;
	NSInteger totalMsgs = 0;
	for (NSString *folderName in allFolders)
	{
		NSLog(@"%@: Processing folder",folderName);
		CTCoreFolder *currFolder = [self.mailAcct folderWithPath:folderName];
		

		EmailFolder *emailFolder = [EmailFolder findOrAddFolder:currFolder.path inExistingFolders:currFolderByFolderName 
			withDataModelController:self.appDataDmc];
		
		if(currFolder.totalMessageCount > 0)
		{
			// set the toIndex to 0 so all messages are loaded
			NSSet *serverMsgSet = [currFolder messageObjectsFromIndex:1 toIndex:0];
			NSLog(@"%@: ... done getting message list",folderName);

			for(CTCoreMessage *msg in serverMsgSet)
			{
				NSLog(@"Sync msg: uid= %@, msg id = %@, send date = %@, subj = %@", msg.uid,msg.messageId,
					[DateHelper stringFromDate:msg.senderDate],msg.subject);
				EmailInfo *newEmailInfo = [self emailInfoFromServerMsg:msg andFolderInfo:emailFolder];
				
				[EmailAddress findOrAddAddress:newEmailInfo.from 
					withCurrentAddresses:currEmailAddressByAddress inDataModelController:self.appDataDmc];
				
				[EmailDomain findOrAddDomainName:newEmailInfo.domain 
					withCurrentDomains:currDomainByDomainName inDataModelController:self.appDataDmc];
				
				numNewMsgs ++;
					
			}
		}
		
		NSLog(@"%@: ... done synchronizing message list",folderName);
		NSLog(@"-------");
		
	}
	
	[self.appDataDmc saveContext];

	NSLog(@"Done synchronizing messages: new msgs = %d, total server msgs = %d",
		numNewMsgs, totalMsgs);

	[self disconnect];

}

-(void)deleteMarkedMsgs
{

	[self connect];
	
	
	NSSet *allFolders = [self.mailAcct allFolders];
	NSMutableDictionary *folderByPath = [[NSMutableDictionary alloc] init];
	for (NSString *folderName in allFolders)
	{
		CTCoreFolder *serverFolder = [self.mailAcct folderWithPath:folderName];
		[folderByPath setObject:serverFolder forKey:folderName];
	}
	
	NSMutableSet *serverFoldersToExpunge = [[NSMutableSet alloc] init];
		
	NSArray *msgsMarkedForDeletion = [self.appDataDmc fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME 
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
		[self.appDataDmc deleteObject:markedForDeletion];
	}
	
	[self.appDataDmc saveContext];

	[serverFoldersToExpunge release];
	[folderByPath release];

	
	[self disconnect];

}

@end
