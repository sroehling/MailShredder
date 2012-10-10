//
//  SyncFolderSelectionFieldEditInfo.m
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "SyncFolderSelectionFieldEditInfo.h"

#import "EmailAccount.h"
#import "EmailFolder.h"

@implementation SyncFolderSelectionFieldEditInfo

@synthesize emailAcct;
@synthesize emailFolder;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct andFolder:(EmailFolder*)theEmailFolder
{
	self = [super initWithManagedObj:theEmailFolder 
		andCaption:theEmailFolder.folderName andContent:@""];
	if(self)
	{
		self.emailFolder = theEmailFolder;
		self.emailAcct = theEmailAcct;
	}
	return self;

}

-(id)initWithManagedObj:(NSManagedObject *)theFieldObj andCaption:(NSString *)theCaption 
	andContent:(NSString *)theContent
{
	assert(0);
	return nil;
}

-(void)dealloc
{
	[emailFolder release];
	[emailAcct release];
	[super dealloc];
}  


- (BOOL)isSelected
{
	return [self.emailAcct.onlySyncFolders containsObject:self.emailFolder];
}

- (void)updateSelection:(BOOL)isSelected
{
	if(isSelected == TRUE)
	{
		[self.emailAcct addOnlySyncFoldersObject:self.emailFolder];
	}
	else {
		[self.emailAcct removeOnlySyncFoldersObject:self.emailFolder];
	}
}


@end

