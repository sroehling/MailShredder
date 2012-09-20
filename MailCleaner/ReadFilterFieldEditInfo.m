//
//  ReadFilterFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReadFilterFieldEditInfo.h"
#import "ReadFilter.h"
#import "LocalizationHelper.h"

@implementation ReadFilterFieldEditInfo

@synthesize readFilter;

-(id)initWithReadFilter:(ReadFilter *)theReadFilter
{
	assert(theReadFilter != nil);
	self = [super initWithManagedObj:theReadFilter 
		andCaption:[theReadFilter filterSynopsis] 
		andContent:nil andSubtitle:[theReadFilter filterSubtitle]];
	if(self)
	{
		self.readFilter = theReadFilter;
		self.readFilter.selectionFlagForSelectableObjectTableView = FALSE;
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
	return self.readFilter.selectionFlagForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	self.readFilter.selectionFlagForSelectableObjectTableView = isSelected;
}


@end
