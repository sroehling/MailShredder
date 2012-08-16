//
//  MailSyncOperation.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailSyncOperation.h"
#import "MailSyncConnectionContext.h"
#import "EmailInfo.h"
#import "EmailDomain.h"
#import "EmailAccount.h"
#import "DataModelController.h"
#import "EmailFolder.h"
#import "EmailAddress.h"
#import "DateHelper.h"
#import "MailAddressHelper.h"
#import "LocalizationHelper.h"
#import "PercentProgressCounter.h"

@implementation MailSyncOperation

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

-(void)deleteLocalEmailInfos:(NSArray*)msgsToDelete
{
	for(EmailInfo *msgToDelete in msgsToDelete)
	{
		[self.connectionContext.syncDmc deleteObject:msgToDelete];
	}
	// Propagate the deletes, so the changes will be immediately available. Otherwise,
	// strange CoreData errors can occur (see Stackoverflow posts about 
	// processPendingChanges and deleteObject).
	// TBD - Should the NSManagedObjectContext be configured without an undo queue 
	// in this case?
	[self.connectionContext.syncDmc.managedObjectContext processPendingChanges];

}

-(NSUInteger)totalServerMsgCount:(CTCoreAccount*)mailAcct
{
	CGFloat totalMsgs = 0;
	NSSet *allFoldersOnServer = [self.connectionContext.mailAcct allFolders];
	for (NSString *folderName in allFoldersOnServer)
	{
		CTCoreFolder *currFolder = [mailAcct folderWithPath:folderName];
		totalMsgs += currFolder.totalMessageCount;
	}
	return totalMsgs;
}


-(void)syncMsgs
{
	NSMutableDictionary *currEmailAddressByAddress = [EmailAddress addressesByName:self.connectionContext.syncDmc];
	NSMutableDictionary *currDomainByDomainName = [EmailDomain emailDomainsByDomainName:self.connectionContext.syncDmc];

	NSMutableDictionary *currFolderByFolderName = [EmailFolder foldersByName:self.connectionContext.syncDmc];
	NSMutableDictionary *foldersNoLongerOnServer = [EmailFolder foldersByName:self.connectionContext.syncDmc];
	
	PercentProgressCounter *syncProgressCounter = [[PercentProgressCounter alloc] 
		initWithTotalCount:[self totalServerMsgCount:self.connectionContext.mailAcct]];
	
	NSSet *allFoldersOnServer = [self.connectionContext.mailAcct allFolders];
	NSInteger numNewMsgs = 0;
	NSInteger totalMsgs = 0;
	for (NSString *folderName in allFoldersOnServer)
	{
		NSLog(@"%@: Processing folder",folderName);
		CTCoreFolder *currFolder = [self.connectionContext.mailAcct folderWithPath:folderName];
		
		EmailFolder *emailFolder = [currFolderByFolderName objectForKey:currFolder.path];
		if(emailFolder == nil)
		{
			emailFolder = [EmailFolder findOrAddFolder:currFolder.path 
				inExistingFolders:currFolderByFolderName 
				withDataModelController:self.connectionContext.syncDmc];
		}
		else 
		{
			// There is an existing EmailFolder object for the folder on the server,
			// so we "account for" the folder and remove it from the set of folders
			// not on the server.
			[foldersNoLongerOnServer removeObjectForKey:currFolder.path];
		}
			
		// If emailFolder is an existing folder, then it might have existing EmailInfo objects in its 
		// emailInfoFolder relationship. If a local EmailInfo object already exists with the same UID,
		// then there is no need to create a new one. To perform this check, we need a dictionary of 
		// existing EmailInfo objects, whereby the key is the UID.
		NSMutableDictionary *existingEmailInfoByUID = [emailFolder emailInfosInFolderByUID];
		
		if(currFolder.totalMessageCount > 0)
		{
			// set the toIndex to 0 so all messages are loaded
			NSSet *serverMsgSet = [currFolder messageObjectsFromIndex:1 toIndex:0];
			NSLog(@"%@: ... done getting message list",folderName);

			for(CTCoreMessage *msg in serverMsgSet)
			{
			
				EmailInfo *existingEmailInfo =[existingEmailInfoByUID objectForKey:msg.uid];
				if(existingEmailInfo != nil)
				{
					// The EmailInfo's remaining in the dictionary after the folder 
					// synchronization represent messages which are no longer on the server,
					// but there's still a local EmailInfo.
					[existingEmailInfoByUID removeObjectForKey:msg.uid];
				}
				else 
				{
					// Allocate a new local EmailInfo, since there's not an existing local
					// one with the same UID.
					NSLog(@"Sync msg: uid= %@, msg id = %@, send date = %@, subj = %@", msg.uid,msg.messageId,
						[DateHelper stringFromDate:msg.senderDate],msg.subject);
					EmailInfo *newEmailInfo = [self emailInfoFromServerMsg:msg andFolderInfo:emailFolder 
						andCurrentAddresses:currEmailAddressByAddress inDataModelController:self.connectionContext.syncDmc];
					
					[EmailAddress findOrAddAddress:newEmailInfo.from 
						withCurrentAddresses:currEmailAddressByAddress inDataModelController:self.connectionContext.syncDmc];
					
					[EmailDomain findOrAddDomainName:newEmailInfo.domain 
						withCurrentDomains:currDomainByDomainName inDataModelController:self.connectionContext.syncDmc];
					
					numNewMsgs ++;

				}
				
				BOOL progressThresholdCrossed = [syncProgressCounter incrementProgressCount];
				if(progressThresholdCrossed)
				{
					[self.connectionContext.progressDelegate mailSyncUpdateProgress:
						[syncProgressCounter currentProgress]];
				}
					
			} // For each message in the folder
			
			
		} // if(currFolder.totalMessageCount > 0)
		
		// Delete any local EmailInfo's which are unacounted after 
		// synchronizing this folder with the server.
		[self deleteLocalEmailInfos:[existingEmailInfoByUID allValues]];
		
		
		NSLog(@"%@: ... done synchronizing message list",folderName);
		NSLog(@"-------");
		
	} // For each folder
	
	// After processing all the folders, remove the local messages from folders which
	// are no longer on the server. We keep the local folder object, since it 
	// may be referenced within matching rules (the alternative would be to delete
	// the folder, cascading to any rules including the folder).
	for(EmailFolder *folderNoLongerOnServer in [foldersNoLongerOnServer allValues])
	{
		NSLog(@"Folder removed or renamed on server, deleting messages from local folder");
		[self deleteLocalEmailInfos:[folderNoLongerOnServer.emailInfoFolder allObjects]];
	}


	NSLog(@"Done synchronizing messages: new msgs = %d, total server msgs = %d",
		numNewMsgs, totalMsgs);
	[syncProgressCounter release];

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


-(void)main
{
	NSLog(@"MailSyncOperation: Mail sync execution started");
	
	if([self.connectionContext establishConnection])
	{
		[self syncMsgs];
		
		self.connectionContext.emailAcctInfo.lastSync = [NSDate date];
			
		[self.connectionContext teardownConnection];

		[self.connectionContext.progressDelegate mailSyncComplete:TRUE];

	}
	else 
	{
	
		[self performSelectorOnMainThread:@selector(syncFailedAlert) 
			withObject:self waitUntilDone:TRUE];
	
		[self.connectionContext.progressDelegate mailSyncComplete:FALSE];
		
	}
	
	NSLog(@"MailSyncOperation: Mail sync execution finished");
}


@end
