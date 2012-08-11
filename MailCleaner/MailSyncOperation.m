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


-(void)syncMsgs
{
	NSMutableDictionary *currEmailAddressByAddress = [EmailAddress addressesByName:self.connectionContext.syncDmc];
	NSMutableDictionary *currDomainByDomainName = [EmailDomain emailDomainsByDomainName:self.connectionContext.syncDmc];
	NSMutableDictionary *currFolderByFolderName = [EmailFolder foldersByName:self.connectionContext.syncDmc];
	
	// Remove all the existing EmailInfo objects, since they'll be
	// re-synchronized below.
	NSSet *currEmailInfos = [self.connectionContext.syncDmc fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME];
	for(EmailInfo *currEmailInfo in currEmailInfos)
	{
		[self.connectionContext.syncDmc deleteObject:currEmailInfo];
	}
	// Propagate the deletes, so the changes will be immediately available. Otherwise,
	// strange CoreData errors can occur (see Stackoverflow posts about 
	// processPendingChanges and deleteObject).
	// TBD - Should the NSManagedObjectContext be configured without an undo queue 
	// in this case?
	[self.connectionContext.syncDmc.managedObjectContext processPendingChanges];

	
	NSSet *allFolders = [self.connectionContext.mailAcct allFolders];
	NSInteger numNewMsgs = 0;
	NSInteger totalMsgs = 0;
	for (NSString *folderName in allFolders)
	{
		NSLog(@"%@: Processing folder",folderName);
		CTCoreFolder *currFolder = [self.connectionContext.mailAcct folderWithPath:folderName];
		
		EmailFolder *emailFolder = [EmailFolder findOrAddFolder:currFolder.path inExistingFolders:currFolderByFolderName 
			withDataModelController:self.connectionContext.syncDmc];
		
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
					andCurrentAddresses:currEmailAddressByAddress inDataModelController:self.connectionContext.syncDmc];
				
				[EmailAddress findOrAddAddress:newEmailInfo.from 
					withCurrentAddresses:currEmailAddressByAddress inDataModelController:self.connectionContext.syncDmc];
				
				[EmailDomain findOrAddDomainName:newEmailInfo.domain 
					withCurrentDomains:currDomainByDomainName inDataModelController:self.connectionContext.syncDmc];
				
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
