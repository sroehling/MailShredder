//
//  MsgSyncPriorityList.m
//  MailShredder
//
//  Created by Steve Roehling on 10/12/12.
//
//

#import "MsgSyncPriorityList.h"
#import "DateHelper.h"
#import "CollectionHelper.h"

static NSUInteger const MSG_SYNC_LIST_SORT_THRESHOLD = 2000;
static NSString * const CORE_MSG_SORT_BY_SEND_DATE_KEY = @"sentDateGMT";
static NSString * const CORE_MSG_SORT_BY_FOLDER_KEY_PATH = @"parentFolder.path";

@implementation MsgSyncPriorityList

@synthesize msgListForSync;

-(void)dealloc
{
	[msgListForSync release];
	[super dealloc];
}

-(id)initWithMaxMsgsToSync:(NSUInteger)theMaxMsgsToSync
	andSyncOlderMsgsFirst:(BOOL)doSyncOlderMsgsFirst
{
	self = [super init];
	if(self)
	{
		self.msgListForSync = [[[NSMutableArray alloc] init] autorelease];
		
		assert(theMaxMsgsToSync > 0);
		maxMsgsToSync = theMaxMsgsToSync;

		syncOldMsgsFirst = doSyncOlderMsgsFirst;

		resortThreshold = maxMsgsToSync + MSG_SYNC_LIST_SORT_THRESHOLD;
	}
	return self;
}

-(void)resortMsgList
{
	[CollectionHelper sortMutableArrayInPlace:self.msgListForSync
		withKey:CORE_MSG_SORT_BY_SEND_DATE_KEY ascending:syncOldMsgsFirst];
	while(self.msgListForSync.count > maxMsgsToSync)
	{
		[self.msgListForSync removeLastObject];
	}
}

-(void)addMsg:(CTCoreMessage*)candidateMsgForSync
{
	assert(candidateMsgForSync != nil);
	
	[self.msgListForSync addObject:candidateMsgForSync];
	
	if(self.msgListForSync.count > resortThreshold)
	{
		[self resortMsgList];
 	}
}

-(NSArray*)syncMsgsSortedByFolder
{
	[self resortMsgList];
	[CollectionHelper sortMutableArrayInPlace:self.msgListForSync
		withKey:CORE_MSG_SORT_BY_FOLDER_KEY_PATH ascending:TRUE];
	return [[[NSArray alloc] initWithArray:self.msgListForSync] autorelease];
}

@end
