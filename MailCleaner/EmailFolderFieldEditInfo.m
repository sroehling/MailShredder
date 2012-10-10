//
//  EmailFolderFieldEditInfo.m
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "EmailFolderFieldEditInfo.h"
#import "EmailFolder.h"
#import "EmailFolderFilter.h"

@implementation EmailFolderFieldEditInfo

@synthesize emailFolder;
@synthesize parentFilter;

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
	[parentFilter release];
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


-(BOOL)supportsDelete
{
	return (self.parentFilter != nil)?TRUE:FALSE;
}


-(void)deleteObject:(DataModelController*)dataModelController
{
	assert([self supportsDelete]);
	[self.parentFilter removeSelectedFoldersObject:self.emailFolder];
}

@end
