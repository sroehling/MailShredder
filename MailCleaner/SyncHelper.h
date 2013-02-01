//
//  SyncHelper.h
//  MailShredder
//
//  Created by Steve Roehling on 1/30/13.
//
//

#import <Foundation/Foundation.h>

@interface SyncHelper : NSObject

+(NSUInteger)countOfMsgsToSyncForFolderWithMsgCount:(NSUInteger)folderMsgCount
             andTotalMsgCountAllFolders:(NSUInteger)totalMsgCount
                       andMaxMsgsToSync:(NSUInteger)maxMsgsSyncAllFolders;

+(void)calcSequenceNumbersForSyncWithTotalFolderMsgCount:(NSUInteger)totalMsgsInFolder
           andMsgsToSyncInFolder:(NSUInteger)msgsToSyncInFolder andSyncOldMsgsFirst:(BOOL)doSyncOldMsgsFirst
                  andStartSeqNum:(NSUInteger*)startSeqNumber andStopSeqNum:(NSUInteger*)stopSeqNum;

+(NSUInteger)folderMsgCount:(CTCoreFolder*)currFolder;

@end
