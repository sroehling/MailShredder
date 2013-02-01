//
//  SyncHelper.m
//  MailShredder
//
//  Created by Steve Roehling on 1/30/13.
//
//

#import "SyncHelper.h"

@implementation SyncHelper

+(NSUInteger)countOfMsgsToSyncForFolderWithMsgCount:(NSUInteger)folderMsgCount
                         andTotalMsgCountAllFolders:(NSUInteger)totalMsgCount
                                   andMaxMsgsToSync:(NSUInteger)maxMsgsSyncAllFolders
{
    if(folderMsgCount == 0)
    {
        return 0;
    }
    else
    {
        
        CGFloat folderMsgCountAsFloat = (CGFloat)folderMsgCount;
        CGFloat totalMsgCountAsFloat = (CGFloat)totalMsgCount;
        CGFloat maxMsgsSyncAllFoldersAsFloat = (CGFloat)maxMsgsSyncAllFolders;
        
        CGFloat fractionOfOverallMsgsToSync = folderMsgCountAsFloat/totalMsgCountAsFloat;
        
        // maxMsgsToSyncInFolder is the maximum number of messages to synchronize,
        // relative to the maximum synchronization count set by the user. This
        // number could be greater than the total number of messages currently/actually available in
        // the folder (folderMsgCount). If so, the count of messages to sync is capped at the current
        // count of messages in the folder (see below).
        NSUInteger maxMsgsToSyncInFolder =
            floorf(fractionOfOverallMsgsToSync * maxMsgsSyncAllFoldersAsFloat);
        
        NSUInteger msgsToSyncInFolder;
        if(maxMsgsToSyncInFolder > folderMsgCount)
        {
            msgsToSyncInFolder = folderMsgCount;
        }
        else
        {
            msgsToSyncInFolder = maxMsgsToSyncInFolder;
        }
        
        return msgsToSyncInFolder;
    }
}

+(void)calcSequenceNumbersForSyncWithTotalFolderMsgCount:(NSUInteger)totalMsgsInFolder
    andMsgsToSyncInFolder:(NSUInteger)msgsToSyncInFolder andSyncOldMsgsFirst:(BOOL)doSyncOldMsgsFirst
                andStartSeqNum:(NSUInteger*)startSeqNumber andStopSeqNum:(NSUInteger*)stopSeqNum
{
    assert(msgsToSyncInFolder <= totalMsgsInFolder);
    assert(msgsToSyncInFolder > 0);
    assert(totalMsgsInFolder > 0);
    
    if(doSyncOldMsgsFirst)
    {
        *startSeqNumber = 1;
        *stopSeqNum = 1 + (msgsToSyncInFolder-1);
    }
    else
    {
        *startSeqNumber = totalMsgsInFolder - (msgsToSyncInFolder-1);
        *stopSeqNum = totalMsgsInFolder;
        
    }
    
}


+(NSUInteger)folderMsgCount:(CTCoreFolder*)currFolder
{
    NSUInteger totalMessageCount;
    if(![currFolder totalMessageCount:&totalMessageCount])
    {
        @throw [NSException exceptionWithName:@"FailureRetrievingFolderMsgCount"
                                       reason:@"Failure retrieving message count for folder" userInfo:nil];
    }
    return totalMessageCount;
}


@end
