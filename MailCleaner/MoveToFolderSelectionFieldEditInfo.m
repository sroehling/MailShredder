//
//  MoveToFolderSelectionFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoveToFolderSelectionFieldEditInfo.h"
#import "EmailFolder.h"

@implementation MoveToFolderSelectionFieldEditInfo

@synthesize emailFolder;

-(id)initWithEmailFolder:(EmailFolder*)theEmailFolder
{
	self = [super initWithManagedObj:theEmailFolder 
		andCaption:theEmailFolder.folderName andContent:@""];
	if(self)
	{
		self.emailFolder = theEmailFolder;
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
	[super dealloc];
}  


- (BOOL)isSelected
{
	return self.emailFolder.isSelectedForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	self.emailFolder.isSelectedForSelectableObjectTableView = isSelected;
}

@end
