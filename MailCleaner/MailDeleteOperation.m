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

#define SYNC_PROGRESS_UPDATE_THRESHOLD 0.05

@implementation MailDeleteOperation

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

-(NSSet*)uidsInFolder:(CTCoreFolder *)theFolder
{
	NSMutableSet *uids = [[[NSMutableSet alloc] init] autorelease];
	if(theFolder == nil)
	{
		return uids;
	}
	NSArray *coreMsgsWithUID = [theFolder messagesFromUID:1 to:0 
		withFetchAttributes:CTFetchAttrDefaultsOnly];
	for(CTCoreMessage *folderMsg in coreMsgsWithUID)
	{
		[uids addObject:[NSNumber numberWithInt:folderMsg.uid]];
	}
	
	return uids;
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
			// Same path, no need to move the message. However, if the setting is still
			// to delete the message, we can delete it in place.
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


-(void)deleteMarkedMsgs
{
	NSDictionary *folderByPath = [[self serverFoldersByName] retain];
	NSMutableSet *serverFoldersToExpunge = [[NSMutableSet alloc] init];
		
	CGFloat deleteProgress = 0.0;
	NSUInteger numMsgsDeleted = 0;
	
	CTCoreFolder *deleteDestFolder = [self destFolderForDelete:folderByPath];
	NSSet *uidsInDeleteFolderBeforeDeletion = [self uidsInFolder:deleteDestFolder];
	BOOL doDeleteMsgs = [[self.connectionContext acctInSyncObjectContext].deleteHandlingDeleteMsg boolValue];
		
	NSArray *msgsMarkedForDeletion = [self.connectionContext.syncDmc 
		fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME 
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
		
		
	// In the destination folder, get the list of messages which are new since the 
	// delete operation started and delete them.
	if((deleteDestFolder != nil) && doDeleteMsgs)
	{
		// Need to disconnect, then reconnect to get an updated message count 
		// and list of messages.
		[deleteDestFolder disconnect];
		[deleteDestFolder connect];
	
		NSSet *uidsInDeleteFolderAfterDeletions = [self uidsInFolder:deleteDestFolder];
		NSLog(@"uids in delete folder: before =%d, after =%d",
			[uidsInDeleteFolderBeforeDeletion count],[uidsInDeleteFolderAfterDeletions count]);
		for(NSNumber *uidAfterDeletions in uidsInDeleteFolderAfterDeletions)
		{
			if(![uidsInDeleteFolderBeforeDeletion containsObject:uidAfterDeletions])
			{
				// UID is new since delete, since it is not in  the list of UIDs from before deletion
				CTCoreMessage *msgToDeleteFromDestFolder = [deleteDestFolder
					messageWithUID:[uidAfterDeletions unsignedIntegerValue]];

				NSLog(@"Msg Delete: Message in dest folder: uid=%d %@",
					msgToDeleteFromDestFolder.uid,msgToDeleteFromDestFolder.subject);

				[deleteDestFolder setFlags:CTFlagDeleted forMessage:msgToDeleteFromDestFolder];
				[serverFoldersToExpunge addObject:deleteDestFolder];
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
		@try 
		{
			[self deleteMarkedMsgs];
			[self.connectionContext.progressDelegate mailSyncComplete:TRUE];
		}
		@catch (NSException *exception) {
			[self performSelectorOnMainThread:@selector(deleteFailedAlert) 
				withObject:self waitUntilDone:TRUE];

			[self.connectionContext.progressDelegate mailSyncComplete:FALSE];
		}
		@finally 
		{
			[self.connectionContext teardownConnection];
		}
	}
	else 
	{
		[self performSelectorOnMainThread:@selector(deleteFailedAlert) 
			withObject:self waitUntilDone:TRUE];

		[self.connectionContext.progressDelegate mailSyncComplete:FALSE];
	}

}

@end
