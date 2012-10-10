//
//  FolderSyncContext.m
//
//  Created by Steve Roehling on 8/16/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "FolderSyncContext.h"
#import "EmailFolder.h"
#import "EmailAccount.h"
#import "MailSyncConnectionContext.h"
#import "DataModelController.h"

@implementation FolderSyncContext

@synthesize connectionContext;
@synthesize currFolderByFolderName;
@synthesize foldersNoLongerOnServer;
@synthesize syncFoldersByName;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
{
	self = [super init];
	if(self)
	{
		self.connectionContext = theConnectionContext;
		
		EmailAccount *currAcct = self.connectionContext.acctInSyncObjectContext;
		
		self.currFolderByFolderName = [currAcct foldersByName];
		self.foldersNoLongerOnServer = [currAcct foldersByName];
		self.syncFoldersByName = [currAcct syncFoldersByName];

	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}

-(BOOL)folderIsSynchronized:(NSString*)folderName
{
	if([self.syncFoldersByName count] == 0)
	{
		return TRUE;
	}
	else if ([self.syncFoldersByName objectForKey:folderName] != nil)
	{
		return TRUE;
	}
	else 
	{
		return FALSE;
	}
}

-(NSUInteger)totalServerMsgCountInAllFolders
{
	CGFloat totalMsgs = 0;
	NSSet *allFoldersOnServer = [self.connectionContext.mailAcct allFolders];
	for (NSString *folderName in allFoldersOnServer)
	{
		if([self folderIsSynchronized:folderName])
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
		else 
		{
			NSLog(@"Skipping msg count for folder: %@",folderName);
		}
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
			withDataModelController:self.connectionContext.syncDmc
			andFolderAcct:self.connectionContext.acctInSyncObjectContext];
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

	NSMutableArray *foldersToDelete = [[[NSMutableArray alloc] init] autorelease];
	
	// After processing all the folders, remove the local messages from folders which
	// are no longer on the server. We keep the local folder object, since it 
	// may be referenced within matching rules (the alternative would be to delete
	// the folder, cascading to any rules including the folder).
	for(EmailFolder *folderNoLongerOnServer in [self.foldersNoLongerOnServer allValues])
	{
		NSLog(@"Folder removed or renamed on server, deleting messages from local folder");
		[self.connectionContext.syncDmc deleteObjects:[folderNoLongerOnServer.emailInfoFolder allObjects]];
		// If the folder is no longer on the server and also is not referenced
		// by any local filters, then delete it locally.
		if(![folderNoLongerOnServer isReferencedByFiltersOrSyncFolders])
		{
			NSLog(@"Deleting local folder object: %@",folderNoLongerOnServer.folderName);
			[foldersToDelete addObject:folderNoLongerOnServer];
		}
		else 
		{
			NSLog(@"Keeping local folder object referenced by filter or sync folder: %@",
				folderNoLongerOnServer.folderName);

		}
	}
	
	[self.connectionContext.syncDmc deleteObjects:foldersToDelete];

}

-(void)dealloc
{
	[connectionContext release];
	[currFolderByFolderName release];
	[foldersNoLongerOnServer release];
	[syncFoldersByName release];
	[super dealloc];
}

@end
