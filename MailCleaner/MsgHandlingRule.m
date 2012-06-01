//
//  Rule.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgHandlingRule.h"
#import "AgeFilter.h"

NSString * const RULE_ENABLED_KEY = @"enabled";
NSString * const RULE_AGE_FILTER_KEY = @"ageFilter";

@implementation MsgHandlingRule

@dynamic enabled;
@dynamic ageFilter;

-(NSString*)ruleSynopsis
{
	assert(0); // must be overriden
	return nil;
}


@end
