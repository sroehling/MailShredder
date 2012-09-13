//
//  AgeFilterComparison.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AgeFilterComparison.h"
#import "LocalizationHelper.h"
#import "DataModelController.h"
#import "DateHelper.h"
#import "EmailInfo.h"

NSString * const AGE_FILTER_COMPARISON_ENTITY_NAME = @"AgeFilterComparison";
NSUInteger const AGE_FILTER_COMPARISON_TIME_UNIT_WEEKS = 0;
NSUInteger const AGE_FILTER_COMPARISON_TIME_UNIT_MONTHS = 1;
NSUInteger const AGE_FILTER_COMPARISON_TIME_UNIT_YEARS = 2;
NSUInteger const AGE_FILTER_COMPARISON_OLDER = 0;
NSUInteger const AGE_FILTER_COMPARISON_NEWER = 1;


@implementation AgeFilterComparison

@dynamic interval;
@dynamic timeUnit;
@dynamic comparison;

// Inverse relationships
@dynamic sharedAppValsDefaultAgeFilterNewer1Month;
@dynamic sharedAppValsDefaultAgeFilterNewer1Year;
@dynamic sharedAppValsDefaultAgeFilterNewer3Months;
@dynamic sharedAppValsDefaultAgeFilterNewer6Months;
@dynamic sharedAppValsDefaultAgeFilterOlder1Month;
@dynamic sharedAppValsDefaultAgeFilterOlder1Year;
@dynamic sharedAppValsDefaultAgeFilterOlder2Years;
@dynamic sharedAppValsDefaultAgeFilterOlder3Months;
@dynamic sharedAppValsDefaultAgeFilterOlder6Months;


+(AgeFilterComparison*)filterWithDataModelController:(DataModelController*)dmc
	andComparisonType:(NSUInteger)theComparison
	andInterval:(NSUInteger)theInterval
	andTimeUnit:(NSUInteger)theTimeUnit
{
	AgeFilterComparison *theComparisonFilter = (AgeFilterComparison*)
		[dmc insertObject:AGE_FILTER_COMPARISON_ENTITY_NAME];
		
		
	assert((theTimeUnit == AGE_FILTER_COMPARISON_TIME_UNIT_WEEKS) ||
		(theTimeUnit == AGE_FILTER_COMPARISON_TIME_UNIT_MONTHS) ||
		(theTimeUnit == AGE_FILTER_COMPARISON_TIME_UNIT_YEARS));
	theComparisonFilter.timeUnit = [NSNumber numberWithInteger:theTimeUnit];

	assert((theComparison == AGE_FILTER_COMPARISON_OLDER) ||
		(theComparison == AGE_FILTER_COMPARISON_NEWER));
	theComparisonFilter.comparison = [NSNumber numberWithInteger:theComparison];

	assert(theInterval > 0);
	theComparisonFilter.interval = [NSNumber numberWithInteger:theInterval];



	return theComparisonFilter;
}


-(NSString*)comparisonAsString
{
	if([self.comparison integerValue] == AGE_FILTER_COMPARISON_OLDER)
	{
		return LOCALIZED_STR(@"AGE_FILTER_COMPARISON_OLDER");
	}
	else 
	{
		return LOCALIZED_STR(@"AGE_FILTER_COMPARISON_NEWER");
	}
}

-(NSString*)timeUnitAsString
{
	NSInteger timeInterval = [self.interval integerValue];
	if([self.timeUnit integerValue] == AGE_FILTER_COMPARISON_TIME_UNIT_WEEKS)
	{
		return (timeInterval > 1)?LOCALIZED_STR(@"TIME_UNIT_WEEKS"):LOCALIZED_STR(@"TIME_UNIT_WEEK");
	}
	else if ([self.timeUnit integerValue] == AGE_FILTER_COMPARISON_TIME_UNIT_MONTHS)
	{
		return (timeInterval > 1)?LOCALIZED_STR(@"TIME_UNIT_MONTHS"):LOCALIZED_STR(@"TIME_UNIT_MONTH");
	}
	else 
	{
		return (timeInterval > 1)?LOCALIZED_STR(@"TIME_UNIT_YEARS"):LOCALIZED_STR(@"TIME_UNIT_YEAR");
	}
}

-(NSString*)filterSynopsis
{
	return [NSString stringWithFormat:LOCALIZED_STR(@"AGE_FILTER_SYNOPSIS_FORMAT"),
		[self comparisonAsString],[self.interval integerValue],[self timeUnitAsString]];
}

-(NSPredicate*)filterPredicate:(NSDate*)baseDate
{
	assert(baseDate != nil);
	
	NSDateComponents *filterCompareComponents = [[[NSDateComponents alloc] init] autorelease];
	NSInteger relativeIntervalValue = [self.interval integerValue] * -1;
	if([self.timeUnit integerValue] == AGE_FILTER_COMPARISON_TIME_UNIT_WEEKS)
	{
		[filterCompareComponents setWeek:relativeIntervalValue];
	}
	else if ([self.timeUnit integerValue] == AGE_FILTER_COMPARISON_TIME_UNIT_MONTHS)
	{
		[filterCompareComponents setMonth:relativeIntervalValue];
	}
	else 
	{
		[filterCompareComponents setYear:relativeIntervalValue];
	}
	NSDate *compareDate = [[DateHelper theHelper].gregorian 
		dateByAddingComponents:filterCompareComponents 
                 toDate:baseDate options:0];
	NSLog(@"Compare date: %@",[DateHelper stringFromDate:compareDate]);

	NSString *comparisonOperatorAsString;
	if([self.comparison integerValue] == AGE_FILTER_COMPARISON_OLDER)
	{
		comparisonOperatorAsString = @"<=";
	}
	else 
	{
		comparisonOperatorAsString = @">=";
	}

	
	NSString *predicateFormat = [NSString stringWithFormat:@"(%@ %@ %%@)",
		EMAIL_INFO_SEND_DATE_KEY,comparisonOperatorAsString];
	NSLog(@"Predicate format: %@",predicateFormat);
	NSPredicate *predicate = [NSPredicate
			predicateWithFormat:predicateFormat,compareDate];

	return predicate;
}

-(BOOL)filterMatchesAnyAge
{
	return FALSE;
}



@end
