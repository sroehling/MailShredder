//
//  DontMoveToFolderSelectionFieldEditInfo.m
//
//  Created by Steve Roehling on 8/29/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "DontMoveToFolderSelectionFieldEditInfo.h"
#import "LocalizationHelper.h"

@implementation DontMoveToFolderSelectionFieldEditInfo

-(id)init
{
	self = [super initWithManagedObj:nil 
		andCaption:LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_NONE") andContent:nil];
	if(self)
	{
		isSelectedForTableView = FALSE;
	}
	return self;
}

- (BOOL)isSelected
{
	return isSelectedForTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	isSelectedForTableView = isSelected;
}


@end
