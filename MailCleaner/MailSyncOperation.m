//
//  MailSyncOperation.m
//
//  Created by Steve Roehling on 8/10/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
#import "MsgSyncPriorityList.h"
#import "SyncHelper.h"


@implementation MailSyncOperation

@synthesize syncProgressDelegate;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
	andProgressDelegate:(id<MailSyncProgressDelegate>)theProgressDelegate
{
	self = [super initWithConnectionContext:theConnectionContext];
	if(self)
	{
		assert(theProgressDelegate != nil);
		self.syncProgressDelegate = theProgressDelegate;
	}
	return self;
}

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
{
	assert(0);
	return nil;
}

-(id)init
{
	assert(0);
	return nil;
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




-(NSArray*)retrieveServerMsgHeaderSetForFolder:(CTCoreFolder*)currFolder
                    andTotalMsgsAllFolders:(NSUInteger)totalMsgsAllFolders
                    andMaxMsgsToSync:(NSUInteger)maxMsgsSyncAllFolders
                           andSyncOldMsgsFirst:(BOOL)doSyncOldMsgsFirst
{
    
    [currFolder connect];

    NSUInteger folderMessageCount = [SyncHelper folderMsgCount:currFolder];
 
    NSUInteger numMsgsToSyncInFolder = [SyncHelper countOfMsgsToSyncForFolderWithMsgCount:folderMessageCount
                andTotalMsgCountAllFolders:totalMsgsAllFolders andMaxMsgsToSync:maxMsgsSyncAllFolders];
    
    NSArray *serverMsgSet;
    
    if(numMsgsToSyncInFolder > 0)
    {
        NSLog(@"Retrieving message headers: %@",currFolder.path);
        
        NSUInteger startSeqNum, stopSeqNum;
        [SyncHelper calcSequenceNumbersForSyncWithTotalFolderMsgCount:folderMessageCount
            andMsgsToSyncInFolder:numMsgsToSyncInFolder andSyncOldMsgsFirst:doSyncOldMsgsFirst
            andStartSeqNum:&startSeqNum andStopSeqNum:&stopSeqNum];
   
         NSArray *retrievedMsgSet = [currFolder messagesFromSequenceNumber:startSeqNum to:stopSeqNum
                        withFetchAttributes:CTFetchAttrEnvelope];
        
        NSLog(@"Done retrieving message headers: %@",currFolder.path);
        NSLog(@"-------");
        
        // When the folder is disconnected, the array containing the returned
        // message set is emptied.
        serverMsgSet = [NSArray arrayWithArray:retrievedMsgSet];
        
        if(serverMsgSet == nil)
        {
            @throw [NSException exceptionWithName:@"FailureRetrievingMsgSet"
                                           reason:@"Failure retrieving message set for folder" userInfo:nil];
        }
    }
    else
    {
        serverMsgSet = [[[NSArray alloc] init] autorelease];
    }
    
    // Retrieving the message headers causes the MailCore library to connect to the
    // current folder. If there are multiple folders, an exception is sometimes thrown
    // if no steps are taken to disconnect the from the folder after retrieving the
    // message headers. The necessity for this disconnect was found using the
    // "StressTestSyncAndDelete" test case.
    [currFolder disconnect];
    
   return serverMsgSet;
}

-(void)main
{
	NSLog(@"MailSyncOperation: Mail sync execution started");
	
	if([self.connectionContext establishConnection])
	{
		
        FolderSyncContext *folderSyncContext = [[FolderSyncContext alloc]
                        initWithConnectionContext:self.connectionContext];
        NSUInteger totalMsgCountAllSynchronizedFolders =
                [folderSyncContext totalServerMsgCountInAllFolders];
        
        
        MsgSyncContext *msgSyncContext = [[MsgSyncContext alloc]
                  initWithConnectionContext:self.connectionContext
                  andTotalExpectedMsgs:totalMsgCountAllSynchronizedFolders
                  andProgressDelegate:self.syncProgressDelegate];
        
        NSSet *allFoldersOnServer = [[self.connectionContext.mailAcct allFolders] retain];
        
        EmailAccount *syncEmailAcct = self.connectionContext.acctInSyncObjectContext;
        
        NSUInteger maxSyncMsgs = [syncEmailAcct.maxSyncMsgs unsignedIntegerValue];
        BOOL syncOldMsgsFirst = [syncEmailAcct.syncOldMsgsFirst boolValue];
        
        MsgSyncPriorityList *msgSyncPriorityList =
                [[MsgSyncPriorityList alloc] initWithMaxMsgsToSync:maxSyncMsgs
                andSyncOlderMsgsFirst:syncOldMsgsFirst];
		@try
		{
		
			////////////////////////////////////////////////////////////////////////////////////
			// Sync Pass 1: In the first pass, a list of chronologically sorted messages
			// to be synchronized is created.
			////////////////////////////////////////////////////////////////////////////////////
			for (NSString *folderName in allFoldersOnServer)
			{
				CTCoreFolder *currFolder = [self.connectionContext.mailAcct folderWithPath:folderName];
				EmailFolder *emailFolder = [folderSyncContext 
					findOrCreateLocalEmailFolderForServerFolderWithName:currFolder.path];
					
				if([folderSyncContext folderIsSynchronized:folderName])
				{
                    
					NSArray *serverMsgSet = [self retrieveServerMsgHeaderSetForFolder:currFolder
                                            andTotalMsgsAllFolders:totalMsgCountAllSynchronizedFolders
                                            andMaxMsgsToSync:maxSyncMsgs andSyncOldMsgsFirst:syncOldMsgsFirst];
                    [msgSyncPriorityList addWellFormedMsgs:serverMsgSet];
 
                     
				} // If folder is synchronized
				else 
				{
					NSLog(@"Skipping message sync for folder: %@",folderName);
					if ([emailFolder hasLocalEmailInfoObjects])
					{
						// If the folder is no longer synchronized, but still has local EmailInfo objects, then
						// these objects need to be deleted. Deleting them will ensure they don't show up
						// in message list results.
						[self.connectionContext.syncDmc deleteObjects:[emailFolder.emailInfoFolder allObjects]];
						[self.connectionContext.syncDmc saveContext];
					}
				}

			} // For each folder
			
			////////////////////////////////////////////////////////////////////////////////////
			// Sync Pass 2: In the 2nd pass, a list of messages to sync (as created from
			// pass 1 is iterated over. These messages are synchronized to the local database
			// of messages.
			////////////////////////////////////////////////////////////////////////////////////
			CTCoreFolder *currCoreFolder = nil;
			EmailFolder *currEmailFolder = nil;
			NSArray *msgsToSync = [msgSyncPriorityList syncMsgsSortedByFolder];
			if(msgsToSync.count > 0)
			{
				for(CTCoreMessage *msg in msgsToSync)
				{
					assert(msg.parentFolder != nil);
					if(msg.parentFolder != currCoreFolder)
					{
						if(currEmailFolder != nil)
						{
							[msgSyncContext finishFolderSync];
						}
						currEmailFolder = [folderSyncContext
							findOrCreateLocalEmailFolderForServerFolderWithName:msg.parentFolder.path];
						currCoreFolder = msg.parentFolder;
						[msgSyncContext startMsgSyncForFolder:currEmailFolder];
						NSLog(@"Sync PASS 2: Started synchronization to local database for folder: %@",
								msg.parentFolder.path);
					}
					[msgSyncContext syncOneMsg:msg];
				}
				// Note finishFolderSync will delete any local EmailInfo objects which are
				// were not in the list of messages that were synchronized. The "unnacounted for"
				// EmailInfo objects could either be objects which were deleted separately on
				// the server or ones which didn't make it into the limited list of chronologically
				// sorted messages.
				[msgSyncContext finishFolderSync];
			}

			[folderSyncContext deleteMsgsForFoldersNoLongerOnServer];
			
			self.connectionContext.emailAcctInfo.lastSync = [NSDate date];
				
			[self.connectionContext teardownConnection];

			if([self.syncProgressDelegate respondsToSelector:@selector(mailSyncComplete:)])
			{
				[self.syncProgressDelegate mailSyncComplete:TRUE];
			}
			
			// Update the number of messages matching each saved message filter
			// to reflect the sychronization.
			[[AppHelper theAppDelegate] updateMessageFilterCountsInBackground];
		}
		@catch (NSException *exception) 
		{
			[self performSelectorOnMainThread:@selector(syncFailedAlert) 
				withObject:self waitUntilDone:TRUE];
				
			if([self.syncProgressDelegate respondsToSelector:@selector(mailSyncComplete:)])
			{
				[self.syncProgressDelegate mailSyncComplete:FALSE];
			}	
		}
		@finally 
		{
			[allFoldersOnServer release];
			[folderSyncContext release];
			[msgSyncContext release];
			[msgSyncPriorityList release];
		}
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(syncFailedAlert) 
			withObject:self waitUntilDone:TRUE];
		if([self.syncProgressDelegate respondsToSelector:@selector(mailSyncComplete:)])
		{
			[self.syncProgressDelegate mailSyncComplete:FALSE];
		}
	}
	
	NSLog(@"MailSyncOperation: Mail sync execution finished");
}


@end
