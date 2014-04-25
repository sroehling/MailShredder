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

-(BOOL)isWellFormedCoreMsg:(CTCoreMessage*)msg
{
	if((msg.sentDateGMT != nil) &&
       (msg.sender.email != nil) && (msg.sender.email.length > 0))
	{
		return TRUE;
	}
	else
	{
        DateHelper *dateHelper = [[[DateHelper alloc] init] autorelease];
		NSString *dateStr = (msg.sentDateGMT!=nil)?
        [dateHelper.longDateFormatter stringFromDate:msg.sentDateGMT]:
        @"[GMT Date Missing]";
		NSString *senderDateStr = (msg.senderDate != nil)?
        [dateHelper.longDateFormatter stringFromDate:msg.senderDate]:
        @"[Sender Date Missing]";
		NSString *senderStr = (msg.sender.email != nil)?msg.sender.email:@"[sender missing]";
		
		NSString *subjectStr = (msg.subject != nil)?msg.subject:@"[Subject Missing]";
        
		NSLog(@"Skipping sync for malformed message: sender date=%@, gmt date=%@, subj=%@, sender=%@",
              senderDateStr,dateStr,subjectStr,senderStr);
        
		return FALSE;
	}
}


-(void)addWellFormedMsgs:(NSArray*)coreMsgs
{
    assert(coreMsgs != nil);
    for(CTCoreMessage *msg in coreMsgs)
    {
        // Add the CTCoreMessage object msg
        // to a sorted list of messages. The messages are sorted in chronological
        // order, so only the most recent EmailInfo objects, up to a maximum, will be
        // cached locally and presented to the user.
        if([self isWellFormedCoreMsg:msg])
        {
            [self addMsg:msg];
        }
    } // For each message in the folder

}

-(NSArray*)syncMsgsSortedByFolder
{
	[self resortMsgList];
	[CollectionHelper sortMutableArrayInPlace:self.msgListForSync
		withKey:CORE_MSG_SORT_BY_FOLDER_KEY_PATH ascending:TRUE];
	return [[[NSArray alloc] initWithArray:self.msgListForSync] autorelease];
}

@end
