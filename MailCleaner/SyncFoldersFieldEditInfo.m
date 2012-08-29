//
//  SyncFoldersFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncFoldersFieldEditInfo.h"

#import "LocalizationHelper.h"
#import "EmailAccount.h"
#import "MultipleSelectionTableViewControllerFactory.h"
#import "SyncFoldersFormInfoCreator.h"
#import "EmailFolder.h"

@implementation SyncFoldersFieldEditInfo

@synthesize emailAcct;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct
{
	SyncFoldersFormInfoCreator *syncFoldersFormInfoCreator = 
		[[[SyncFoldersFormInfoCreator alloc] initWithEmailAcct:theEmailAcct] autorelease];

	MultipleSelectionTableViewControllerFactory *folderSelectionViewFactory = 
		[[[MultipleSelectionTableViewControllerFactory alloc] initWithFormInfoCreator:syncFoldersFormInfoCreator] autorelease];
	folderSelectionViewFactory.supportsEditing = FALSE;
		
	NSString *folderCountDesc;
	NSString *specificFolderDesc = nil;
	if([theEmailAcct.onlySyncFolders count] == 0)
	{
		folderCountDesc = LOCALIZED_STR(@"EMAIL_ACCOUNT_SYNCHRONIZED_FOLDERS_ALL_FOLDERS");
	}
	else 
	{
		folderCountDesc = LOCALIZED_STR(@"EMAIL_ACCOUNT_SYNCHRONIZED_FOLDERS_SPECIFIC_FOLDERS");

		NSMutableArray *specificFolderNames = [[[NSMutableArray alloc] init] autorelease];
		for(EmailFolder *syncFolder in theEmailAcct.onlySyncFolders)
		{
			[specificFolderNames addObject:syncFolder.folderName];
		}
		specificFolderDesc = [specificFolderNames componentsJoinedByString:@", "];
	}

	self = [super initWithCaption:LOCALIZED_STR(@"EMAIL_ACCOUNT_SYNCHRONIZED_FOLDERS_FIELD_CAPTION") 
		andSubtitle:specificFolderDesc andContentDescription:folderCountDesc 
		andSubViewFactory:folderSelectionViewFactory];
	if(self)
	{
		self.emailAcct = theEmailAcct;
	}
	return self;
}

-(id)initWithManagedObj:(NSManagedObject *)theFieldObj 
	andCaption:(NSString *)theCaption 
	andContent:(NSString *)theContent
{
	assert(0);
	return nil;
}



-(void)dealloc
{
	[emailAcct release];
	[super dealloc];
}  


@end
