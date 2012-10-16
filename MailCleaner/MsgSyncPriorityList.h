//
//  MsgSyncPriorityList.h
//  MailShredder
//
//  Created by Steve Roehling on 10/12/12.
//
//

#import <Foundation/Foundation.h>

@interface MsgSyncPriorityList : NSObject
{
	@private
		NSMutableArray *msgListForSync;
		NSUInteger maxMsgsToSync;
		BOOL syncOldMsgsFirst;
		NSUInteger resortThreshold;
}

@property(nonatomic,retain) NSMutableArray *msgListForSync;

-(id)initWithMaxMsgsToSync:(NSUInteger)theMaxMsgsToSync
	andSyncOlderMsgsFirst:(BOOL)doSyncOlderMsgsFirst;

-(void)addMsg:(CTCoreMessage*)candidateMsgForSync;
-(NSArray*)syncMsgsSortedByFolder;

@end
