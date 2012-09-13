//
//  StarredFilterFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StarredFilterFieldEditInfo.h"
#import "StarredFilter.h"
#import "LocalizationHelper.h"

@implementation StarredFilterFieldEditInfo

@synthesize starredFilter;

-(id)initWithStarredFilter:(StarredFilter *)theStarredFilter
{
	assert(theStarredFilter != nil);
	self = [super initWithManagedObj:theStarredFilter 
		andCaption:[theStarredFilter filterSynopsis]
		andContent:nil andSubtitle:nil];
	if(self)
	{
		self.starredFilter = theStarredFilter;
		self.starredFilter.selectionFlagForSelectableObjectTableView = FALSE;
	}
	return self;
}


-(id)initWithManagedObj:(NSManagedObject *)theFieldObj andCaption:(NSString *)theCaption andContent:(NSString *)theContent
{
	assert(0);
	return nil;
}

-(id)initWithManagedObj:(NSManagedObject *)theFieldObj andCaption:(NSString *)theCaption andContent:(NSString *)theContent andSubtitle:(NSString *)theSubtitle
{
	assert(0);
	return nil;
}


- (BOOL)isSelected
{
	return self.starredFilter.selectionFlagForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	self.starredFilter.selectionFlagForSelectableObjectTableView = isSelected;
}



@end
