//
//  AgeFilterNone.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AgeFilterNone.h"
#import "LocalizationHelper.h"

NSString * const AGE_FILTER_NONE_ENTITY_NAME = @"AgeFilterNone";

@implementation AgeFilterNone

@dynamic sharedAppValsDefaultAgeFilterNone;

-(NSString*)filterSynopsis
{
	return LOCALIZED_STR(@"AGE_FILTER_NONE_TITLE");
}

-(NSPredicate*)filterPredicate:(NSDate*)baseDate
{
	return [NSPredicate predicateWithValue:TRUE];
}


@end
