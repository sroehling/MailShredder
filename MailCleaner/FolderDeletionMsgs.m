//
//  FolderDeletionMsgs.m
//
//  Created by Steve Roehling on 9/27/12.
//
//

#import "FolderDeletionMsgs.h"
#import "EmailInfo.h"
#import "EmailFolder.h"
#import "FolderDeletionMsgSet.h"

@implementation FolderDeletionMsgs

@synthesize deletionMsgsByFolderName;

-(NSDictionary*)serverFoldersByName:(CTCoreAccount*)mailAcct
{
	NSSet *allFolders = [mailAcct allFolders];
	NSMutableDictionary *folderByPath = [[[NSMutableDictionary alloc] init] autorelease];
	for (NSString *folderName in allFolders)
	{
		CTCoreFolder *serverFolder = [mailAcct folderWithPath:folderName];
		[folderByPath setObject:serverFolder forKey:folderName];
	}
	return folderByPath;
}


-(id)initWithMsgsToDelete:(NSArray*)msgsMarkedForDeletion
	andMailAcct:(CTCoreAccount*)mailAcct
{
	self = [super init];
	if(self)
	{
		self.deletionMsgsByFolderName = [[[NSMutableDictionary alloc] init] autorelease];
		
		NSDictionary *foldersByName = [self serverFoldersByName:mailAcct];
		
		for(EmailInfo* msgToDelete in msgsMarkedForDeletion)
		{
			NSString *msgFolderName = msgToDelete.folderInfo.folderName;
			FolderDeletionMsgSet *folderMsgSet =
				[self.deletionMsgsByFolderName objectForKey:msgFolderName];
			if(folderMsgSet == nil)
			{
				CTCoreFolder *srcFolder = [foldersByName objectForKey:msgFolderName];
				NSLog(@"Setting up folder set for deletion: %@",msgFolderName);
				assert(srcFolder != nil);
				folderMsgSet = [[[FolderDeletionMsgSet alloc] initWithSrcFolder:srcFolder] autorelease];
				[self.deletionMsgsByFolderName setObject:folderMsgSet forKey:msgFolderName];
			}
			[folderMsgSet addMsg:msgToDelete];
		}
		
	}
	return self;
}

-(NSArray*)folderDeletionMsgSets
{
	return [self.deletionMsgsByFolderName allValues];
}

-(void)dealloc
{
	[deletionMsgsByFolderName release];
	[super dealloc];
}

@end
