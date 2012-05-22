//
//  AgeFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AgeFilter.h"
#import "MessageFilter.h"


@implementation AgeFilter

@synthesize selectionFlagForSelectableObjectTableView;

@dynamic messageFilterAgeFilter;

-(NSString*)filterSynopsis
{
	assert(0); // must be overriden
	return nil;
}

-(NSPredicate*)filterPredicate
{
	assert(0); // must be overriden
	return nil;
}

@end
