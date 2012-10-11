//
//  FolderDeletionMsgSet.m
//
//  Created by Steve Roehling on 9/27/12.
//
//

static NSUInteger const FOLDER_DELETION_MSG_SET_BATCH_SIZE = 20;

#import "FolderDeletionMsgSet.h"
#import "EmailInfo.h"
#import "EmailFolder.h"

@implementation FolderDeletionMsgSet

@synthesize srcFolder;
@synthesize msgsToDeleteBatches;

-(id)initWithSrcFolder:(CTCoreFolder*)theSrcFolder
{
	self = [super init];
	if(self)
	{
		assert(theSrcFolder != nil);
		self.srcFolder = theSrcFolder;
		
		self.msgsToDeleteBatches = [[[NSMutableArray alloc] init] autorelease];
		NSMutableSet *firstBatch = [[[NSMutableSet alloc] init] autorelease];
		[self.msgsToDeleteBatches addObject:firstBatch];
	}
	return self;
}

-(void)addMsg:(EmailInfo*)msgToDelete
{
	assert(msgToDelete != nil);
	assert([msgToDelete.folderInfo.folderName isEqualToString:self.srcFolder.path]);

	assert(self.msgsToDeleteBatches.count >0);
	NSUInteger currentBatchIndex = self.msgsToDeleteBatches.count - 1;

	NSMutableSet *currentBatch = [self.msgsToDeleteBatches objectAtIndex:currentBatchIndex];
	assert(currentBatch != nil);
	if(currentBatch.count >= FOLDER_DELETION_MSG_SET_BATCH_SIZE)
	{
		currentBatch = [[[NSMutableSet alloc] init] autorelease];
		[self.msgsToDeleteBatches addObject:currentBatch];
	}
	
	[currentBatch addObject:msgToDelete];
	
	
}

-(void)dealloc
{
	[srcFolder release];
	[msgsToDeleteBatches release];
	
	[super dealloc];
}


@end
