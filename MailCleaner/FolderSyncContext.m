//
//  FolderSyncContext.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FolderSyncContext.h"
#import "EmailFolder.h"
#import "MailSyncConnectionContext.h"
#import "DataModelController.h"

@implementation FolderSyncContext

@synthesize connectionContext;
@synthesize currFolderByFolderName;
@synthesize foldersNoLongerOnServer;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
{
	self = [super init];
	if(self)
	{
		self.connectionContext = theConnectionContext;
		
		self.currFolderByFolderName = [EmailFolder foldersByName:self.connectionContext.syncDmc];
		self.foldersNoLongerOnServer = [EmailFolder foldersByName:self.connectionContext.syncDmc];

	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}

-(NSUInteger)totalServerMsgCountInAllFolders
{
	CGFloat totalMsgs = 0;
	NSSet *allFoldersOnServer = [self.connectionContext.mailAcct allFolders];
	for (NSString *folderName in allFoldersOnServer)
	{
		CTCoreFolder *currFolder = [self.connectionContext.mailAcct
			folderWithPath:folderName];
		
		NSUInteger messagesInFolder;
		if(![currFolder totalMessageCount:&messagesInFolder])
		{
			@throw [NSException exceptionWithName:@"FailureRetrievingFolderMsgCount" 
				reason:@"Failure retrievig message count for folder" userInfo:nil];
		}
		NSLog(@"total messages in folder %@:%d",folderName,messagesInFolder);
	
		totalMsgs += messagesInFolder;
		
		[currFolder disconnect];
	}
	return totalMsgs;
}


-(EmailFolder*)findOrCreateLocalEmailFolderForServerFolderWithName:(NSString*)folderName
{
	EmailFolder *emailFolder = [self.currFolderByFolderName objectForKey:folderName];
	if(emailFolder == nil)
	{
		emailFolder = [EmailFolder findOrAddFolder:folderName 
			inExistingFolders:currFolderByFolderName 
			withDataModelController:self.connectionContext.syncDmc];
	}
	else 
	{
		// There is an existing EmailFolder object for the folder on the server,
		// so we "account for" the folder and remove it from the set of folders
		// not on the server.
		[foldersNoLongerOnServer removeObjectForKey:folderName];
	}
	return emailFolder;

}

-(void)deleteMsgsForFoldersNoLongerOnServer
{
	// After processing all the folders, remove the local messages from folders which
	// are no longer on the server. We keep the local folder object, since it 
	// may be referenced within matching rules (the alternative would be to delete
	// the folder, cascading to any rules including the folder).
	for(EmailFolder *folderNoLongerOnServer in [self.foldersNoLongerOnServer allValues])
	{
		NSLog(@"Folder removed or renamed on server, deleting messages from local folder");
		[self.connectionContext.syncDmc deleteObjects:[folderNoLongerOnServer.emailInfoFolder allObjects]];
	}

}

-(void)dealloc
{
	[connectionContext release];
	[currFolderByFolderName release];
	[foldersNoLongerOnServer release];
	[super dealloc];
}

@end
