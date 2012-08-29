//
//  MailDeleteOperation.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailDeleteOperation.h"
#import "MailSyncConnectionContext.h"
#import "EmailInfo.h"
#import "MsgPredicateHelper.h"
#import "EmailFolder.h"
#import "DataModelController.h"
#import "DateHelper.h"
#import "LocalizationHelper.h"

#define SYNC_PROGRESS_UPDATE_THRESHOLD 0.05

@implementation MailDeleteOperation

-(void)deleteMarkedMsgs
{
	NSSet *allFolders = [self.connectionContext.mailAcct allFolders];
	NSMutableDictionary *folderByPath = [[NSMutableDictionary alloc] init];
	for (NSString *folderName in allFolders)
	{
		CTCoreFolder *serverFolder = [self.connectionContext.mailAcct folderWithPath:folderName];
		[folderByPath setObject:serverFolder forKey:folderName];
	}
	
	NSMutableSet *serverFoldersToExpunge = [[NSMutableSet alloc] init];
		
	CGFloat deleteProgress = 0.0;
	NSUInteger numMsgsDeleted = 0;
		
	NSArray *msgsMarkedForDeletion = [self.connectionContext.syncDmc fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME 
		andPredicate:[MsgPredicateHelper markedForDeletion]];
	for(EmailInfo *markedForDeletion  in msgsMarkedForDeletion)
	{
		NSLog(@"Deleting msg: msg ID = %d, subject = %@",[markedForDeletion.uid integerValue],
			markedForDeletion.subject);
		CTCoreFolder *msgFolder = (CTCoreFolder*)[folderByPath 
			objectForKey:markedForDeletion.folderInfo.folderName];
		if(msgFolder != nil)
		{
			NSLog(@"Deleting msg: uid= %d, send date = %@, subj = %@", [markedForDeletion.uid integerValue],
					[DateHelper stringFromDate:markedForDeletion.sendDate],markedForDeletion.subject);

			CTCoreMessage *msgMarkedForDeletion = [msgFolder messageWithUID:[markedForDeletion.uid unsignedIntValue]];
			if(msgMarkedForDeletion != nil)
			{
				// TODO - Implement custom delete logic here
				[msgFolder setFlags:CTFlagDeleted forMessage:msgMarkedForDeletion];
				[serverFoldersToExpunge addObject:msgFolder];
			}
		}
		
		numMsgsDeleted ++;
		CGFloat currentProgress = (CGFloat)numMsgsDeleted/((CGFloat)[msgsMarkedForDeletion count]);
		if((currentProgress - deleteProgress) >= SYNC_PROGRESS_UPDATE_THRESHOLD)
		{
			deleteProgress = currentProgress;
			[self.connectionContext.progressDelegate mailSyncUpdateProgress:deleteProgress];
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
		[self.connectionContext.syncDmc deleteObject:markedForDeletion];
	}
	
	[serverFoldersToExpunge release];
	[folderByPath release];

}

-(void)deleteFailedAlert
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
	if([self.connectionContext establishConnection])
	{
		[self deleteMarkedMsgs];
		[self.connectionContext teardownConnection];
		[self.connectionContext.progressDelegate mailSyncComplete:TRUE];
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(deleteFailedAlert) 
			withObject:self waitUntilDone:TRUE];

		[self.connectionContext.progressDelegate mailSyncComplete:FALSE];
	}

}

@end
