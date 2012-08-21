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
				NSLog(@"%@: Processing folder",folderName);
				CTCoreFolder *currFolder = [self.connectionContext.mailAcct folderWithPath:folderName];
				EmailFolder *emailFolder = [folderSyncContext 
					findOrCreateLocalEmailFolderForServerFolderWithName:currFolder.path];
					
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
			} // For each folder

			[folderSyncContext deleteMsgsForFoldersNoLongerOnServer];
			
			self.connectionContext.emailAcctInfo.lastSync = [NSDate date];
				
			[self.connectionContext teardownConnection];

			[self.connectionContext.progressDelegate mailSyncComplete:TRUE];			
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
