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
#import "EmailAccount.h"
#import "AppHelper.h"
#import "AppDelegate.h"

#define SYNC_PROGRESS_UPDATE_THRESHOLD 0.05

@implementation MailDeleteOperation

@synthesize deleteProgressDelegate;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
	andProgressDelegate:(id<MailDeleteProgressDelegate>)theDeleteProgressDelegate
{
	self = [super initWithConnectionContext:theConnectionContext];
	if(self)
	{
		assert(theDeleteProgressDelegate != nil);
		self.deleteProgressDelegate = theDeleteProgressDelegate;
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

-(NSDictionary*)serverFoldersByName
{
	NSSet *allFolders = [self.connectionContext.mailAcct allFolders];
	NSMutableDictionary *folderByPath = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *folderName in allFolders)
	{
		CTCoreFolder *serverFolder = [self.connectionContext.mailAcct folderWithPath:folderName];
		[folderByPath setObject:serverFolder forKey:folderName];
	}
	return folderByPath;
}

-(CTCoreFolder*)destFolderForDelete:(NSDictionary*)foldersByPath
{
	EmailAccount *acctInSyncContext = [self.connectionContext acctInSyncObjectContext];
	EmailFolder *destFolderInfo = acctInSyncContext.deleteHandlingMoveToFolder;
	if(destFolderInfo != nil)
	{
		CTCoreFolder *destFolder = (CTCoreFolder*)[foldersByPath 
			objectForKey:destFolderInfo.folderName];
		return destFolder;
	}
	return nil;
}


-(void)deleteOneMsg:(CTCoreMessage*)msgToDelete 
	fromOriginalFolder:(CTCoreFolder*)origMsgFolder
	moveToDestFolderForDelete:(CTCoreFolder*)destDeleteFolder
	andDoDeleteMsg:(BOOL)doDeleteMsg
	andExpungeFolders:(NSMutableSet*)expungeFolders
{

	if(destDeleteFolder != nil)
	{
		NSLog(@"Msg Delete: Message in orig folder: uid=%d %@",
			msgToDelete.uid,msgToDelete.subject);

		if(![origMsgFolder.path isEqualToString:destDeleteFolder.path])
		{
			// Different paths, move the message
			NSUInteger nextUIDInDestFolder = [destDeleteFolder uidNext];
			BOOL moveSuccessful = [origMsgFolder moveMessageWithUID:msgToDelete.uid 
				toPath:destDeleteFolder.path];
			NSLog(@"next UID in dest folder = %d",nextUIDInDestFolder);
				
			if(!moveSuccessful)
			{
				@throw [NSException exceptionWithName:@"FailureMovingMessage" 
					reason:@"Couldn't move message to deletion folder" userInfo:nil];
			}
			// After moving the message, we don't know exactly what UID it will have in the 
			// new folder, although nextUIDInDestFolder is a good guess. So, for this
			// reason we wait until the end to delete messages, then get a list of new
			// UIDs in the destination folder and delete the messages with these new
			// UIDs.
		}
		else 
		{
			// The message is already in the destination delete folder, so there's no need 
			// to move the message. However, if the setting is still
			// to delete the message, we still need to delete it from from the destination
			// folder.
			if(doDeleteMsg)
			{
				[origMsgFolder setFlags:CTFlagDeleted forMessage:msgToDelete];
				[expungeFolders addObject:origMsgFolder];
			}
		}
	}
	else if(doDeleteMsg) 
	{
		[origMsgFolder setFlags:CTFlagDeleted forMessage:msgToDelete];
		[expungeFolders addObject:origMsgFolder];
	}

}

-(NSString*)messageLookupForSubject:(NSString*)subject sendDate:(NSDate*)sendDate msgSize:(NSUInteger)msgSize
{
	NSString *msgDateStr = [[DateHelper theHelper].longDateFormatter stringFromDate:sendDate];
	return [NSString stringWithFormat:@"%@-%d-%@",msgDateStr,msgSize,subject];
}

-(NSMutableDictionary*)msgsToDeleteByLookupValue:(NSArray*)msgsMarkedForDeletion
{
	NSMutableDictionary *msgsByLookupValue = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailInfo *markedForDeletion  in msgsMarkedForDeletion)
	{
		NSString *msgLookup = [self messageLookupForSubject:markedForDeletion.subject 
			sendDate:markedForDeletion.sendDate 
			msgSize:[markedForDeletion.size unsignedIntegerValue] ];
		NSLog(@"Lookup for msg to be deleted: %@",msgLookup);
		[msgsByLookupValue setObject:markedForDeletion forKey:msgLookup];
	}
	return msgsByLookupValue;
}


-(void)deleteMarkedMsgs
{
	NSDictionary *folderByPath = [[self serverFoldersByName] retain];
	NSMutableSet *serverFoldersToExpunge = [[NSMutableSet alloc] init];
		
	CGFloat deleteProgress = 0.0;
	NSUInteger numMsgsDeleted = 0;
	
	CTCoreFolder *deleteDestFolder = [self destFolderForDelete:folderByPath];
	NSUInteger nextUIDInDeleteFolder = 0;
	if(deleteDestFolder != nil)
	{
		// If a delete folder is specified (i.e., a folder where the message is moved
		// and then optionally deleted from there), uidNext before moving any
		// messages serves as a starting point for the UID's of messages to retrieve and
		// delete after the delete operation.
		nextUIDInDeleteFolder = deleteDestFolder.uidNext;
	}
	
	BOOL doDeleteMsgs = [[self.connectionContext acctInSyncObjectContext].deleteHandlingDeleteMsg boolValue];
		
	NSArray *msgsMarkedForDeletion = [self.connectionContext.syncDmc 
		fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME 
		andPredicate:[MsgPredicateHelper markedForDeletion]];
	
	// The following dictionary is book-keeping when/if a message is 
	// first moved to a destination folder, then deleted from there.
	// Only messages which are new to thd delete folder and match a
	// the lookup value of a message marked for deletion will actually
	// be deleted.
	NSMutableDictionary *msgsToDeleteByLookupValue = 
		[self msgsToDeleteByLookupValue:msgsMarkedForDeletion];

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
				[self deleteOneMsg:msgMarkedForDeletion fromOriginalFolder:msgFolder 
					moveToDestFolderForDelete:deleteDestFolder andDoDeleteMsg:doDeleteMsgs
					andExpungeFolders:serverFoldersToExpunge];
			}
		}
		
		numMsgsDeleted ++;
		CGFloat currentProgress = (CGFloat)numMsgsDeleted/((CGFloat)[msgsMarkedForDeletion count]);
		if((currentProgress - deleteProgress) >= SYNC_PROGRESS_UPDATE_THRESHOLD)
		{
			deleteProgress = currentProgress;
			[self.deleteProgressDelegate mailDeleteUpdateProgress:deleteProgress];
		}
			
	}
	
	if([serverFoldersToExpunge count] > 0)
	{
		for(CTCoreFolder *sererFolderWithDeletedMsgs in serverFoldersToExpunge)
		{
			[sererFolderWithDeletedMsgs expunge];
		}
	}
		
		
	// [1] In the destination folder, get the list of messages which are new since the 
	// delete operation started and delete them. 
	// 
	// [2] There's a remote possibility that while the messages are being moved 
	// to the destination folder, other
	// IMAP clients have also moved one or more messages to the same folder.
	// In this case. we don't want to delete the new messages which are not
	// the ones which were just moved.
	if((deleteDestFolder != nil) && doDeleteMsgs)
	{
		// Need to disconnect, then reconnect to get an updated message count 
		// and list of messages.
		[deleteDestFolder disconnect];
		[deleteDestFolder connect];
			
		NSArray *newMsgsInDeleteFolder = [deleteDestFolder messagesFromUID:nextUIDInDeleteFolder to:0 
			withFetchAttributes:CTFetchAttrEnvelope];
		for(CTCoreMessage *candidateMsgToDeleteFromDestFolder in newMsgsInDeleteFolder)
		{
					
			// Although its a remote possibility (see comment [2] above), we also need
			// check that the a hash of the immutable message properties (such as 
			// date and subject) is the same as the candidate for deletion in the 
			// delete folder.
			NSString *candidateMsgToDeleteLookup = 
				[self messageLookupForSubject:candidateMsgToDeleteFromDestFolder.subject 
					sendDate:candidateMsgToDeleteFromDestFolder.sentDateGMT 
					msgSize:candidateMsgToDeleteFromDestFolder.messageSize];
			EmailInfo *localEmailInfoForCandidateMsg = 
				[msgsToDeleteByLookupValue objectForKey:candidateMsgToDeleteLookup];
			if(localEmailInfoForCandidateMsg != nil)
			{
				NSLog(@"Msg Permanently deleted: Message in dest folder: uid=%d subj=%@ size=%d",
					candidateMsgToDeleteFromDestFolder.uid,candidateMsgToDeleteFromDestFolder.subject,
					candidateMsgToDeleteFromDestFolder.messageSize);

				[deleteDestFolder setFlags:CTFlagDeleted forMessage:candidateMsgToDeleteFromDestFolder];
				[serverFoldersToExpunge addObject:deleteDestFolder];
			}
			else 
			{
				NSLog(@"New msg in delete folder not matched with local msg marked for deletion: uid=%d subj=%@ size=%d",
					candidateMsgToDeleteFromDestFolder.uid,candidateMsgToDeleteFromDestFolder.subject,
					candidateMsgToDeleteFromDestFolder.messageSize);
			}
		}
		
	}
	
	// Delete the local EmailInfo objects for the messages just deleted
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
		BOOL deleteSuccessful = FALSE;
		@try 
		{
			[self deleteMarkedMsgs];
			deleteSuccessful = TRUE;

		}
		@catch (NSException *exception) {
			[self performSelectorOnMainThread:@selector(deleteFailedAlert) 
				withObject:self waitUntilDone:TRUE];

			deleteSuccessful = FALSE;
		}
		@finally 
		{
			[self.connectionContext teardownConnection];
			
			[self.deleteProgressDelegate mailDeleteComplete:deleteSuccessful];

			// Update the number of messages matching each saved message filter
			// to reflect messages just deleted.
			[[AppHelper theAppDelegate] updateMessageFilterCountsInBackground];

		}
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(deleteFailedAlert) 
			withObject:self waitUntilDone:TRUE];

		[self.deleteProgressDelegate mailDeleteComplete:FALSE];
	}

}

@end
