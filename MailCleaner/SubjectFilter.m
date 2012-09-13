//
//  SubjectFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SubjectFilter.h"
#import "LocalizationHelper.h"
#import "EmailInfo.h"

NSString * const SUBJECT_FILTER_ENTITY_NAME = @"SubjectFilter";
NSString * const SUBJECT_FILTER_SEARCH_STRING_KEY = @"searchString";
NSString * const SUBJECT_FILTER_CASE_SENSITIVE_KEY = @"caseSensitive";

@implementation SubjectFilter

@dynamic searchString;
@dynamic caseSensitive;


@dynamic messageFilterSubjectFilters;

-(BOOL)emptyMatchString
{
	return ((self.searchString == nil) || (self.searchString.length == 0))?TRUE:FALSE;
}

-(BOOL)filterMatchesAnySubject
{
	return ([self emptyMatchString])?TRUE:FALSE;
}

-(NSString*)filterSynopsis
{
	if([self emptyMatchString])
	{
		return LOCALIZED_STR(@"EMAIL_SUBJECT_FILTER_MATCH_ANY");
	}
	else 
	{
		return [NSString stringWithFormat:
					LOCALIZED_STR(@"EMAIL_SUBJECT_FILTER_MATCH_CONTAINS"),
					self.searchString];
	}

}

-(NSString*)filterSynopsisShort
{
	if([self emptyMatchString])
	{
		return LOCALIZED_STR(@"EMAIL_SUBJECT_FILTER_MATCH_ANY");
	}
	else 
	{
		return LOCALIZED_STR(@"SUBJECT_FILTER_MATCH_CONTAINS_SEARCH_STRING");
	}
}

-(NSString*)subFilterSynopsis
{
	if([self emptyMatchString])
	{
		return @"";
	}
	else 
	{
		return [NSString stringWithFormat:
					LOCALIZED_STR(@"EMAIL_SUBJECT_FILTER_MATCH_CONTAINS"),
					self.searchString];
	}

}

-(NSPredicate*)filterPredicate
{

	if([self emptyMatchString])
	{
		return [NSPredicate predicateWithValue:TRUE];
	}
	else if([self.caseSensitive boolValue])
	{
		return [NSPredicate predicateWithFormat:@"%K CONTAINS %@",
			EMAIL_INFO_SUBJECT_KEY,self.searchString];
	}
	else 
	{
		return [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",
			EMAIL_INFO_SUBJECT_KEY,self.searchString];
	}

}



@end
