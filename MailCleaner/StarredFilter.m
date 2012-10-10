//
//  StarredFilter.m
//
//  Created by Steve Roehling on 9/12/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "StarredFilter.h"
#import "DataModelController.h"
#import "EmailInfo.h"
#import "LocalizationHelper.h"

NSString * const STARRED_FILTER_ENTITY_NAME = @"StarredFilter";

NSUInteger const STARRED_FILTER_MATCH_LOGIC_STARRED = 0;
NSUInteger const STARRED_FILTER_MATCH_LOGIC_UNSTARRED = 1;
NSUInteger const STARRED_FILTER_MATCH_LOGIC_STARRED_OR_UNSTARRED = 2;

@implementation StarredFilter

@dynamic matchLogic;

@dynamic sharedAppValsDefaultStarredFilterStarred;
@dynamic sharedAppValsDefaultStarredFilterStarredOrUnstarred;
@dynamic sharedAppValsDefaultStarredFilterUnstarred;

@dynamic messageFilterStarredFilter;

@synthesize selectionFlagForSelectableObjectTableView;

+(StarredFilter*)starredFilterInDataModelController:(DataModelController*)dmcForNewFilter
	andMatchLogic:(NSUInteger)theMatchLogic
{
	StarredFilter *theFilter = [dmcForNewFilter insertObject:STARRED_FILTER_ENTITY_NAME];
	assert((theMatchLogic == STARRED_FILTER_MATCH_LOGIC_STARRED) ||
		(theMatchLogic == STARRED_FILTER_MATCH_LOGIC_UNSTARRED) ||
		(theMatchLogic == STARRED_FILTER_MATCH_LOGIC_STARRED_OR_UNSTARRED));
	theFilter.matchLogic = [NSNumber numberWithUnsignedInteger:theMatchLogic];
	return theFilter;
}

-(NSString*)filterSynopsis
{
	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];
	
	if(matchLogic == STARRED_FILTER_MATCH_LOGIC_STARRED)
	{
		return LOCALIZED_STR(@"EMAIL_STARRED_FILTER_MATCH_STARRED");
	}
	else if(matchLogic == STARRED_FILTER_MATCH_LOGIC_UNSTARRED)
	{
		return LOCALIZED_STR(@"EMAIL_STARRED_FILTER_MATCH_UNSTARRED");
	}
	else 
	{		
		assert(matchLogic == STARRED_FILTER_MATCH_LOGIC_STARRED_OR_UNSTARRED);
		return LOCALIZED_STR(@"EMAIL_STARRED_FILTER_MATCH_STARRED_OR_UNSTARRED");
	}
}

-(NSString*)filterSubtitle
{
	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];
	
	if(matchLogic == STARRED_FILTER_MATCH_LOGIC_STARRED)
	{
		return @"";
	}
	else if(matchLogic == STARRED_FILTER_MATCH_LOGIC_UNSTARRED)
	{
		return @"";
	}
	else 
	{		
		assert(matchLogic == STARRED_FILTER_MATCH_LOGIC_STARRED_OR_UNSTARRED);
		return LOCALIZED_STR(@"EMAIL_STARRED_FILTER_MATCH_STARRED_OR_UNSTARRED_SUBTITLE");
	}
}


-(NSPredicate*)filterPredicate
{

	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];
	
	if(matchLogic == STARRED_FILTER_MATCH_LOGIC_STARRED)
	{
		return [NSPredicate predicateWithFormat:@"%K == %@",
			EMAIL_INFO_STARRED_KEY,[NSNumber numberWithBool:TRUE]];
	
	}
	else if(matchLogic == STARRED_FILTER_MATCH_LOGIC_UNSTARRED)
	{
		return [NSPredicate predicateWithFormat:@"%K == %@",
			EMAIL_INFO_STARRED_KEY,[NSNumber numberWithBool:FALSE]];
	}
	else 
	{
		assert(matchLogic == STARRED_FILTER_MATCH_LOGIC_STARRED_OR_UNSTARRED);
		return [NSPredicate predicateWithValue:TRUE];
		
	}

}

-(BOOL)filterMatchesAnyStarredStatus
{
	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];

	return (matchLogic == STARRED_FILTER_MATCH_LOGIC_STARRED_OR_UNSTARRED)?TRUE:FALSE;
}

@end
