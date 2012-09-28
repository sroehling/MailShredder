//
//  FolderDeletionMsgSet.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/27/12.
//
//

#import "FolderDeletionMsgSet.h"
#import "EmailInfo.h"
#import "EmailFolder.h"

@implementation FolderDeletionMsgSet

@synthesize msgsToDelete;
@synthesize srcFolder;

-(id)initWithSrcFolder:(CTCoreFolder*)theSrcFolder
{
	self = [super init];
	if(self)
	{
		assert(theSrcFolder != nil);
		self.srcFolder = theSrcFolder;
		
		self.msgsToDelete = [[[NSMutableSet alloc] init] autorelease];
	}
	return self;
}

-(void)addMsg:(EmailInfo*)msgToDelete
{
	assert(msgToDelete != nil);
	assert([msgToDelete.folderInfo.folderName isEqualToString:self.srcFolder.path]);
	
	[self.msgsToDelete addObject:msgToDelete];
}

-(void)dealloc
{
	[srcFolder release];
	[msgsToDelete release];
	
	[super dealloc];
}


@end
