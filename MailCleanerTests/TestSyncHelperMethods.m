//
//  TestSyncHelperMethods.m
//  MailShredder
//
//  Created by Steve Roehling on 1/30/13.
//
//

#import "TestSyncHelperMethods.h"
#import "SyncHelper.h"

@implementation TestSyncHelperMethods

-(void)checkStartAndStopSequences:(NSUInteger)totalMsgCount andMsgsToSyncInFolder:(NSUInteger)folderMsgsToSync
              andSyncOldMsgsFirst:(BOOL)doSyncOldMsgsFirst
                 andExpectedStart:(NSUInteger)expectedStartSeq andExpectedStopSeq:(NSUInteger)expectedStopSeq
{
    NSUInteger startSeq, stopSeq;
        
    [SyncHelper calcSequenceNumbersForSyncWithTotalFolderMsgCount:totalMsgCount
        andMsgsToSyncInFolder:folderMsgsToSync andSyncOldMsgsFirst:doSyncOldMsgsFirst
        andStartSeqNum:&startSeq andStopSeqNum:&stopSeq];
  
    STAssertTrue(startSeq <= stopSeq,@"Starting sequence number must be less than stop sequence number");
    STAssertTrue(startSeq >= 1,@"Starting sequence number must be at least 1");
    STAssertTrue(stopSeq <= totalMsgCount,@"Stop sequence number must be less than or equal folder's message count (= %d)",totalMsgCount);
    
    
    STAssertTrue(startSeq == expectedStartSeq,
         @"Start sequence of %d expected, got %d",expectedStartSeq,startSeq);
    STAssertTrue(stopSeq == expectedStopSeq,
                 @"Start sequence of %d expected, got %d",expectedStopSeq,stopSeq);

}

-(void)testStartAndStopSequences
{
    NSLog(@"Testing start and stop sequences for message sync");
    
    [self checkStartAndStopSequences:5 andMsgsToSyncInFolder:5 andSyncOldMsgsFirst:FALSE
                    andExpectedStart:1 andExpectedStopSeq:5];
    [self checkStartAndStopSequences:5 andMsgsToSyncInFolder:5 andSyncOldMsgsFirst:TRUE
                    andExpectedStart:1 andExpectedStopSeq:5];

    [self checkStartAndStopSequences:5 andMsgsToSyncInFolder:3 andSyncOldMsgsFirst:TRUE
                    andExpectedStart:1 andExpectedStopSeq:3];
    [self checkStartAndStopSequences:5 andMsgsToSyncInFolder:3 andSyncOldMsgsFirst:FALSE
                    andExpectedStart:3 andExpectedStopSeq:5];

    [self checkStartAndStopSequences:5 andMsgsToSyncInFolder:1 andSyncOldMsgsFirst:FALSE
                    andExpectedStart:5 andExpectedStopSeq:5];
    [self checkStartAndStopSequences:5 andMsgsToSyncInFolder:1 andSyncOldMsgsFirst:TRUE
                    andExpectedStart:1 andExpectedStopSeq:1];

}

-(void)checkMsgsToSyncForFolder:(NSUInteger)folderMsgCount
      andTotalMsgCountAllFolder:(NSUInteger)totalMsgCount
               andMaxMsgsToSync:(NSUInteger)maxMsgsSyncAllFolders
        andExpectedMsgSyncCount:(NSUInteger)expectedMsgsToSync
{
    NSUInteger msgsToSync = [SyncHelper countOfMsgsToSyncForFolderWithMsgCount:folderMsgCount
            andTotalMsgCountAllFolders:totalMsgCount andMaxMsgsToSync:maxMsgsSyncAllFolders];
    
    STAssertTrue(msgsToSync == expectedMsgsToSync,
                 @"Number of messages to sync = %d expected, got %d",expectedMsgsToSync,msgsToSync);

}

-(void)testFolderMsgSyncCount
{
    // If there's just one folder to synchronize, all of the messages should be retrieved for that folder.
    [self checkMsgsToSyncForFolder:1000 andTotalMsgCountAllFolder:1000 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:1000];

    // If there's one folder, and the count of available messages to sync is less than the
    // maximum, then the available messages should by synced.
    [self checkMsgsToSyncForFolder:1000 andTotalMsgCountAllFolder:1000 andMaxMsgsToSync:2000 andExpectedMsgSyncCount:1000];

    
    // If there are multiple folders, each with messages to sync, the number of messages allocated to the given
    // folder should be in proportion to the message count for all folders.
    [self checkMsgsToSyncForFolder:1000 andTotalMsgCountAllFolder:2000 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:500];
    [self checkMsgsToSyncForFolder:1000 andTotalMsgCountAllFolder:3000 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:333];
    
    // If the current folder has no availabled messages, but other folders have messages to sync, then
    // the number of messages to sync from the current folder should be 0.
    [self checkMsgsToSyncForFolder:0 andTotalMsgCountAllFolder:3000 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:0];

    // If the folder's message count is less than the maximum, the count of messages to sync is capped at the maximum.
    [self checkMsgsToSyncForFolder:100 andTotalMsgCountAllFolder:100 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:100];

    
    // If the folder's message count is less than the maximum, the count of messages to sync is capped at the maximum
    // (even if there are more messages in other folders.
    [self checkMsgsToSyncForFolder:100 andTotalMsgCountAllFolder:200 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:100];

    // If the current folder's message count is less than the maximum, but other folders have messages to sync
    // then the # of messages alloced for sync should still be in proportion to the messages across all
    // folders.
    [self checkMsgsToSyncForFolder:100 andTotalMsgCountAllFolder:2000 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:50];
    [self checkMsgsToSyncForFolder:1900 andTotalMsgCountAllFolder:2000 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:950];

    
    [self checkMsgsToSyncForFolder:0 andTotalMsgCountAllFolder:2000 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:0];

    
    [self checkMsgsToSyncForFolder:100 andTotalMsgCountAllFolder:200 andMaxMsgsToSync:1000 andExpectedMsgSyncCount:100];

}

@end
