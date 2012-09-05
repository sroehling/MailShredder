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
#import "FolderSyncContext.h"
#import "MsgSyncContext.h"
#import "AppHelper.h"
#import "AppDelegate.h"


@implementation MailSyncOperation

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
		FolderSyncContext *folderSyncContext = [[FolderSyncContext alloc] 
					initWithConnectionContext:self.connectionContext];
		MsgSyncContext *msgSyncContext = [[MsgSyncContext alloc] 
					initWithConnectionContext:self.connectionContext
					andTotalExpectedMsgs:[folderSyncContext totalServerMsgCountInAllFolders]];
		NSSet *allFoldersOnServer = [[self.connectionContext.mailAcct allFolders] retain];
		
		@try
		{
			for (NSString *folderName in allFoldersOnServer)
			{
				CTCoreFolder *currFolder = [self.connectionContext.mailAcct folderWithPath:folderName];
				EmailFolder *emailFolder = [folderSyncContext 
					findOrCreateLocalEmailFolderForServerFolderWithName:currFolder.path];
					
				if([folderSyncContext folderIsSynchronized:folderName])
				{
					NSLog(@"%@: Synchronizing folder",folderName);
					[msgSyncContext startMsgSyncForFolder:emailFolder];
					NSUInteger totalMessageCount;
					if(![currFolder totalMessageCount:&totalMessageCount])
					{
						@throw [NSException exceptionWithName:@"FailureRetrievingFolderMsgCount" 
							reason:@"Failure retrievig message count for folder" userInfo:nil];
					}
				
					if(totalMessageCount > 0)
					{
						NSArray *serverMsgSet = [currFolder messagesFromUID:1 to:0 withFetchAttributes:CTFetchAttrEnvelope];
						if(serverMsgSet == nil)
						{
							@throw [NSException exceptionWithName:@"FailureRetrievingMsgSet" 
								reason:@"Failure retrievig message set for folder" userInfo:nil];
						}
						
						for(CTCoreMessage *msg in serverMsgSet)
						{			
							[msgSyncContext syncOneMsg:msg];
						} // For each message in the folder
					}
					[msgSyncContext finishFolderSync];
					NSLog(@"%@: ... done synchronizing folder",folderName);
					NSLog(@"-------");
				} // If folder is synchronized
				else 
				{
					NSLog(@"Skipping message sync for folder: %@",folderName);
					if ([emailFolder hasLocalEmailInfoObjects])
					{
						// If the folder is no longer synchronized, but still has local EmailInfo objects, then
						// these objects need to be deleted, so they don't show up in message list results.
						[self.connectionContext.syncDmc deleteObjects:[emailFolder.emailInfoFolder allObjects]];
						[self.connectionContext.syncDmc saveContext];
					}
				}

			} // For each folder

			[folderSyncContext deleteMsgsForFoldersNoLongerOnServer];
			
			self.connectionContext.emailAcctInfo.lastSync = [NSDate date];
				
			[self.connectionContext teardownConnection];

			[self.connectionContext.progressDelegate mailSyncComplete:TRUE];
			
			// Update the number of messages matching each saved message filter
			// to reflect the sychronization.
			[[AppHelper theAppDelegate] updateMessageFilterCountsInBackground];
		}
		@catch (NSException *exception) 
		{
			[self performSelectorOnMainThread:@selector(syncFailedAlert) 
				withObject:self waitUntilDone:TRUE];
			[self.connectionContext.progressDelegate mailSyncComplete:FALSE];
		}
		@finally 
		{
			[allFoldersOnServer release];
			[folderSyncContext release];
			[msgSyncContext release];
		}
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
