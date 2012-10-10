//
//  MailDeleteOperation.m
//
//  Created by Steve Roehling on 8/10/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
#import "MailDeleteCompletionInfo.h"
#import "FolderDeletionMsgSet.h"
#import "FolderDeletionMsgs.h"

#import <libetpan/libetpan.h>
#import <libetpan/imapdriver_tools.h>

#define SYNC_PROGRESS_UPDATE_THRESHOLD 0.05

@interface CTCoreFolder()

// messagesForSet is defined internally to CTCoreFolder. This "class extension"
// suffices as an external declaration of this selector, even though the selector
// itself is not shared in the header file for CTCoreFolder.
-(NSArray *)messagesForSet:(struct mailimap_set *)set
	fetchAttributes:(CTFetchAttributes)attrs uidFetch:(BOOL)uidFetch;

@end

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


-(NSString*)messageLookupForSubject:(NSString*)subject sendDate:(NSDate*)sendDate msgSize:(NSUInteger)msgSize
{
	NSString *msgDateStr = [[DateHelper theHelper].longDateFormatter stringFromDate:sendDate];
	return [NSString stringWithFormat:@"%@-%d-%@",msgDateStr,msgSize,subject];
}

-(NSString*)messageLookupForCoreMsg:(CTCoreMessage*)coreMsg
{
	return [self messageLookupForSubject:coreMsg.subject
			sendDate:coreMsg.sentDateGMT msgSize:coreMsg.messageSize];

}

-(NSString*)messageLookupForEmailInfo:(EmailInfo*)emailInfo
{
	return [self messageLookupForSubject:emailInfo.subject
			sendDate:emailInfo.sendDate 
			msgSize:[emailInfo.size unsignedIntegerValue] ];
}

-(NSMutableDictionary*)msgsToDeleteByLookupValue:(NSArray*)msgsMarkedForDeletion
{
	NSMutableDictionary *msgsByLookupValue = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailInfo *markedForDeletion  in msgsMarkedForDeletion)
	{
		NSString *msgLookup = [self messageLookupForEmailInfo:markedForDeletion];
		NSLog(@"Lookup for msg to be deleted: %@",msgLookup);
		[msgsByLookupValue setObject:markedForDeletion forKey:msgLookup];
	}
	return msgsByLookupValue;
}


-(BOOL)copyCoreMessages:(NSArray*)msgList
	fromFolder:(CTCoreFolder*)srcFolder toFolder:(CTCoreFolder*)destFolder
{
	// This implementation is intended to be basically the same
	// as imapdriver_copy_message, but support the simultaneous
	// copy of multiple messages.
	
	struct mailimap_set * uid_set = mailimap_set_new_empty();
	for(CTCoreMessage *msg in msgList)
	{
		/* int add_ret_status =  */ mailimap_set_add_single(uid_set,msg.uid);

	}
	
	const char *dest_mb_path = [destFolder.path cStringUsingEncoding:NSUTF8StringEncoding];

	// The following manipulations are also found in imapdriver.c
	/* int copy_return_status  = */ mailimap_uid_copy(srcFolder.imapSession,
		uid_set, dest_mb_path);
		

	mailimap_set_free(uid_set);
	
	return TRUE;
}

-(BOOL)deleteCoreMsgs:(NSArray*)coreMsgList fromFolder:(CTCoreFolder*)msgFolder
{
	for(CTCoreMessage *coreMsg in coreMsgList)
	{
		[msgFolder setFlags:CTFlagDeleted forMessage:coreMsg];
	}
	[msgFolder expunge];
	return TRUE;
}

-(NSArray*)emailInfoToValidCoreMsgList:(NSSet*)emailInfoList
	withMsgFolder:(CTCoreFolder*)msgFolder
{

	struct mailimap_set * uid_set = mailimap_set_new_empty();
	
	for(EmailInfo *emailInfo in emailInfoList)
	{
		/* int add_ret_status =  */ mailimap_set_add_single(uid_set,[emailInfo.uid unsignedIntegerValue]);

	}

	NSArray *validCoreMsgs = [msgFolder messagesForSet:uid_set fetchAttributes:CTFetchAttrDefaultsOnly uidFetch:YES];

	// messagesForSet calls mailimap_set_free on the given set, so there's
	// no need to call the same function here.
	//	mailimap_set_free(uid_set); <--- Not needed!

	return validCoreMsgs;

  }

-(BOOL)deleteEmailInfoMsgList:(NSSet*)msgList fromFolder:(CTCoreFolder*)srcFolder
{
	NSArray *validMsgs = [self emailInfoToValidCoreMsgList:msgList withMsgFolder:srcFolder];

	[self deleteCoreMsgs:validMsgs fromFolder:srcFolder];

	return TRUE;
}

-(BOOL)moveEmailInfoMsgs:(NSSet*)emailInfoMsgList
	fromFolder:(CTCoreFolder*)srcFolder toFolder:(CTCoreFolder*)destFolder
{

	NSArray *validCoreMsgs = [self emailInfoToValidCoreMsgList:emailInfoMsgList withMsgFolder:srcFolder];
	
	[self copyCoreMessages:validCoreMsgs fromFolder:srcFolder toFolder:destFolder];

	[self.deleteProgressDelegate mailDeleteUpdateProgress:0.5];

	
	[self deleteCoreMsgs:validCoreMsgs fromFolder:srcFolder];

	[self.deleteProgressDelegate mailDeleteUpdateProgress:0.75];

	
	return TRUE;
}

-(MailDeleteCompletionInfo*)deleteMarkedMsgs
{
	NSDictionary *folderByPath = [self serverFoldersByName];
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
		
		
	// Limit the messages deleted to those which are both in the current
	// account and marked for deletion.
	NSPredicate *markedForDeletion = [MsgPredicateHelper markedForDeletion];
	NSPredicate *msgsInCurrentAcct = [NSPredicate predicateWithFormat:@"%K = %@",
		EMAIL_INFO_ACCT_KEY,
		self.connectionContext.acctInSyncObjectContext];
	NSPredicate *markedInCurrentAcct = [NSCompoundPredicate andPredicateWithSubpredicates:
		[NSArray arrayWithObjects:markedForDeletion,msgsInCurrentAcct, nil]];
		
	NSArray *msgsMarkedForDeletion = [self.connectionContext.syncDmc 
		fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME 
		andPredicate:markedInCurrentAcct];
		
	// folderDeletionMsgs an index of the messages by source folder. This
	// is used so the messages can be moved (copied then deleted) or deleted
	// in bulk from the source folder (rather than 1 by 1 as they appear
	// in msgsMarkedForDeletion.
	FolderDeletionMsgs *folderDeletionMsgs = [[[FolderDeletionMsgs alloc]
		initWithMsgsToDelete:msgsMarkedForDeletion
		andMailAcct:self.connectionContext.mailAcct] autorelease];
		
	[self.deleteProgressDelegate mailDeleteUpdateProgress:0.0];
		
	
	// The following dictionary is book-keeping when/if a message is 
	// first moved to a destination folder, then deleted from there.
	// Only messages which are new to thd delete folder and match a
	// the lookup value of a message marked for deletion will actually
	// be deleted.
	NSMutableDictionary *msgsToDeleteByLookupValue = 
		[self msgsToDeleteByLookupValue:msgsMarkedForDeletion];
		
	NSUInteger numMsgsDeleted = 0;
	for(FolderDeletionMsgSet *folderDeletionMsgSet in folderDeletionMsgs.folderDeletionMsgSets)
	{
	
		CTCoreFolder *origMsgFolder = folderDeletionMsgSet.srcFolder;
		if(deleteDestFolder != nil)
		{
			if(![origMsgFolder.path isEqualToString:deleteDestFolder.path])
			{
				// Different paths => move the messages
				
				[self moveEmailInfoMsgs:folderDeletionMsgSet.msgsToDelete
					fromFolder:origMsgFolder toFolder:deleteDestFolder];
				// After moving the message, we don't know exactly what UID it will have in the 
				// new folder, although nextUIDInDestFolder is a good guess. So, for this
				// reason we wait until the end to delete messages, then get a list of new
				// UIDs in the destination folder and delete the messages with these new
				// UIDs.
			}
			else 
			{
				// The message(s) is already in the destination delete folder, so there's no need 
				// to move the message. However, if the setting is still
				// to delete the message, we still need to delete it from from the destination
				// folder.
				if(doDeleteMsgs)
				{
					[self deleteEmailInfoMsgList:folderDeletionMsgSet.msgsToDelete fromFolder:origMsgFolder];
				}
			}
		}
		else if(doDeleteMsgs)
		{
			// There is not a destination folder, so we don't need to move the message.
			// However, if the messages are set for immediate deletion, still deleted
			// it immediately in place.
			[self deleteEmailInfoMsgList:folderDeletionMsgSet.msgsToDelete fromFolder:origMsgFolder];
		}

		
	} // For each Folder's deletion message set.
	
		
	// The messages have been moved to a destination folder. If the doDeleteMsgs (immediately)
	// flag has been set, then deleted the messages immediately from there.
	// 
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

		[self.deleteProgressDelegate mailDeleteUpdateProgress:0.5];

		// Need to disconnect, then reconnect to get an updated message count
		// and list of messages.
		[deleteDestFolder disconnect];
		[deleteDestFolder connect];
			
		NSArray *newMsgsInDeleteFolder = [deleteDestFolder messagesFromUID:nextUIDInDeleteFolder to:0 
			withFetchAttributes:CTFetchAttrEnvelope];
		NSMutableArray *msgsConfirmedForDeleteAfterMoving = [[[NSMutableArray alloc] init] autorelease];
		for(CTCoreMessage *candidateMsgToDeleteFromDestFolder in newMsgsInDeleteFolder)
		{
					
			// Although its a remote possibility (see comment [2] above), we also need
			// check that the a hash of the immutable message properties (such as 
			// date and subject) is the same as the candidate for deletion in the 
			// delete folder.
			EmailInfo *localEmailInfoForCandidateMsg = [msgsToDeleteByLookupValue
				objectForKey:[self messageLookupForCoreMsg:candidateMsgToDeleteFromDestFolder]];
			if(localEmailInfoForCandidateMsg != nil)
			{
				NSLog(@"Msg Permanently deleted: Message in dest folder: uid=%d subj=%@ size=%d",
					candidateMsgToDeleteFromDestFolder.uid,candidateMsgToDeleteFromDestFolder.subject,
					candidateMsgToDeleteFromDestFolder.messageSize);
				[msgsConfirmedForDeleteAfterMoving addObject:candidateMsgToDeleteFromDestFolder];
			}
			else 
			{
				NSLog(@"New msg in delete folder not matched with local msg marked for deletion: uid=%d subj=%@ size=%d",
					candidateMsgToDeleteFromDestFolder.uid,candidateMsgToDeleteFromDestFolder.subject,
					candidateMsgToDeleteFromDestFolder.messageSize);
			}
		}
		
		[self deleteCoreMsgs:msgsConfirmedForDeleteAfterMoving fromFolder:deleteDestFolder];
		
	}
	
	numMsgsDeleted = msgsMarkedForDeletion.count;
	
	[self.deleteProgressDelegate mailDeleteUpdateProgress:0.9];

	// Delete the local EmailInfo objects for the messages just deleted
	[self.connectionContext.syncDmc deleteObjects:msgsMarkedForDeletion];
	
	
	MailDeleteCompletionInfo *completionInfo = [[[MailDeleteCompletionInfo alloc] init] autorelease];
	completionInfo.didEraseMsgs = doDeleteMsgs;
	if(deleteDestFolder != nil)
	{
		completionInfo.destinationFolder = deleteDestFolder.path;
	}
	completionInfo.numMsgsDeleted = numMsgsDeleted;
	
	[self.deleteProgressDelegate mailDeleteUpdateProgress:1.0];
	[NSThread sleepForTimeInterval:0.5];

	
	
	return completionInfo;

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

	// Every time messages have been confirmed  for deletion, a new MailDeleteOperation is queued up.
	// However, if 2 or more operations are in the queue, then the first one will delete all the messages.
	// In this case, there won't be any messages left which are marked for deletion, and the
	// operation can be terminated before connecting to the mail server, etc.
	[self.connectionContext setupContext];
	
	NSUInteger countOfMsgsMarkedForDeletion = [self.connectionContext.syncDmc
		countObjectsForEntityName:EMAIL_INFO_ENTITY_NAME andPredicate:[MsgPredicateHelper markedForDeletion]];
	if(countOfMsgsMarkedForDeletion == 0)
	{
		NSLog(@"Message deletion operation: No messages currently marked for deletion: no operation needed");
		[self.connectionContext teardownContext];
		return;
	}

	MailDeleteCompletionInfo *deleteCompletionInfo = nil;
	if([self.connectionContext establishConnection])
	{
		BOOL deleteSuccessful = FALSE;
		@try 
		{
			deleteCompletionInfo = [self deleteMarkedMsgs];
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
			
			if([self.deleteProgressDelegate respondsToSelector:@selector(mailDeleteComplete:withCompletionInfo:)])
			{
				[self.deleteProgressDelegate mailDeleteComplete:deleteSuccessful
					withCompletionInfo:deleteCompletionInfo];
			}

			// Update the number of messages matching each saved message filter
			// to reflect messages just deleted.
			[[AppHelper theAppDelegate] updateMessageFilterCountsInBackground];

		}
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(deleteFailedAlert) 
			withObject:self waitUntilDone:TRUE];

		if([self.deleteProgressDelegate respondsToSelector:@selector(mailDeleteComplete:withCompletionInfo:)])
		{
			[self.deleteProgressDelegate mailDeleteComplete:FALSE withCompletionInfo:nil];
		}
		
	}

}

@end
