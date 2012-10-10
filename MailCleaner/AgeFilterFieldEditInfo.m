//
//  AgeFilterFieldEditInfo.m
//
//  Created by Steve Roehling on 5/19/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "AgeFilterFieldEditInfo.h"
#import "AgeFilter.h"

@implementation AgeFilterFieldEditInfo

@synthesize ageFilter;

-(id)initWithAgeFilter:(AgeFilter *)theAgeFilter andCaption:(NSString *)theCaption andContent:(NSString *)theContent
	andSubtitle:(NSString*)theSubtitle
{
	self = [super initWithManagedObj:theAgeFilter andCaption:theCaption andContent:theContent andSubtitle:theSubtitle];
	if(self)
	{
		self.ageFilter = theAgeFilter;
		self.ageFilter.selectionFlagForSelectableObjectTableView = FALSE;
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
	return self.ageFilter.selectionFlagForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	self.ageFilter.selectionFlagForSelectableObjectTableView = isSelected;
}



@end
