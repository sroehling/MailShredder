//
//  SharedAppVals.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SharedAppVals.h"
#import "MessageFilter.h"
#import "DataModelController.h"
#import "AppHelper.h"
#import "FromAddressFilter.h"
#import "AgeFilterNone.h"
#import "CoreDataHelper.h"
#import "AgeFilterComparison.h"
#import "EmailAddressFilter.h"
#import "RecipientAddressFilter.h"
#import "EmailDomainFilter.h"
#import "EmailFolderFilter.h"
#import "ReadFilter.h"
#import "StarredFilter.h"

NSString * const SHARED_APP_VALS_ENTITY_NAME = @"SharedAppVals";
NSString * const SHARED_APP_VALS_CURRENT_EMAIL_ACCOUNT_KEY = @"currentEmailAcct";

@implementation SharedAppVals

@dynamic currentEmailAcct;

@dynamic defaultAgeFilterNone;

@dynamic defaultAgeFilterOlder1Month;
@dynamic defaultAgeFilterOlder1Year;
@dynamic defaultAgeFilterOlder2Years;
@dynamic defaultAgeFilterOlder3Months;
@dynamic defaultAgeFilterOlder6Months;
@dynamic defaultAgeFilterOlder3Years;
@dynamic defaultAgeFilterOlder4Years;
@dynamic defaultAgeFilterOlder5Years;
@dynamic defaultAgeFilterOlder18Months;


@dynamic defaultReadFilterRead;
@dynamic defaultReadFilterReadOrUnread;
@dynamic defaultReadFilterUnread;
@dynamic defaultStarredFilterStarred;
@dynamic defaultStarredFilterStarredOrUnstarred;
@dynamic defaultStarredFilterUnstarred;

+(SharedAppVals*)createWithDataModelController:(DataModelController*)dataModelController
{
	SharedAppVals *sharedVals = [dataModelController createDataModelObject:SHARED_APP_VALS_ENTITY_NAME];
	
	sharedVals.defaultAgeFilterNone = (AgeFilterNone*)[dataModelController insertObject:AGE_FILTER_NONE_ENTITY_NAME];
	
	sharedVals.defaultAgeFilterOlder1Month = [AgeFilterComparison filterWithDataModelController:dataModelController 
		andComparisonType:AGE_FILTER_COMPARISON_OLDER andInterval:1 andTimeUnit:AGE_FILTER_COMPARISON_TIME_UNIT_MONTHS];
	sharedVals.defaultAgeFilterOlder1Year = [AgeFilterComparison filterWithDataModelController:dataModelController 
		andComparisonType:AGE_FILTER_COMPARISON_OLDER andInterval:1 andTimeUnit:AGE_FILTER_COMPARISON_TIME_UNIT_YEARS];
	sharedVals.defaultAgeFilterOlder1Year.showInFilterPopupMenu = [NSNumber numberWithBool:TRUE];
	sharedVals.defaultAgeFilterOlder2Years = [AgeFilterComparison filterWithDataModelController:dataModelController 
		andComparisonType:AGE_FILTER_COMPARISON_OLDER andInterval:2 andTimeUnit:AGE_FILTER_COMPARISON_TIME_UNIT_YEARS];
	sharedVals.defaultAgeFilterOlder3Months = [AgeFilterComparison filterWithDataModelController:dataModelController 
		andComparisonType:AGE_FILTER_COMPARISON_OLDER andInterval:3 andTimeUnit:AGE_FILTER_COMPARISON_TIME_UNIT_MONTHS];
	sharedVals.defaultAgeFilterOlder3Months.showInFilterPopupMenu = [NSNumber numberWithBool:TRUE];
	sharedVals.defaultAgeFilterOlder6Months = [AgeFilterComparison filterWithDataModelController:dataModelController 
		andComparisonType:AGE_FILTER_COMPARISON_OLDER andInterval:6 andTimeUnit:AGE_FILTER_COMPARISON_TIME_UNIT_MONTHS];
	sharedVals.defaultAgeFilterOlder6Months.showInFilterPopupMenu = [NSNumber numberWithBool:TRUE];
	
	sharedVals.defaultAgeFilterOlder3Years = [AgeFilterComparison filterWithDataModelController:dataModelController
		andComparisonType:AGE_FILTER_COMPARISON_OLDER andInterval:3 andTimeUnit:AGE_FILTER_COMPARISON_TIME_UNIT_YEARS];
	sharedVals.defaultAgeFilterOlder4Years = [AgeFilterComparison filterWithDataModelController:dataModelController
		andComparisonType:AGE_FILTER_COMPARISON_OLDER andInterval:4 andTimeUnit:AGE_FILTER_COMPARISON_TIME_UNIT_YEARS];
	sharedVals.defaultAgeFilterOlder5Years = [AgeFilterComparison filterWithDataModelController:dataModelController
		andComparisonType:AGE_FILTER_COMPARISON_OLDER andInterval:5 andTimeUnit:AGE_FILTER_COMPARISON_TIME_UNIT_YEARS];
	sharedVals.defaultAgeFilterOlder18Months = [AgeFilterComparison filterWithDataModelController:dataModelController
		andComparisonType:AGE_FILTER_COMPARISON_OLDER andInterval:18 andTimeUnit:AGE_FILTER_COMPARISON_TIME_UNIT_MONTHS];
	
	
		
	sharedVals.defaultReadFilterRead = [ReadFilter readFilterInDataModelController:dataModelController 
				andMatchLogic:READ_FILTER_MATCH_LOGIC_READ];
	sharedVals.defaultReadFilterReadOrUnread = [ReadFilter readFilterInDataModelController:dataModelController 
				andMatchLogic:READ_FILTER_MATCH_LOGIC_READ_OR_UNREAD];;
	sharedVals.defaultReadFilterUnread = [ReadFilter readFilterInDataModelController:dataModelController 
				andMatchLogic:READ_FILTER_MATCH_LOGIC_UNREAD];
	
	sharedVals.defaultStarredFilterStarred = [StarredFilter starredFilterInDataModelController:dataModelController 
		andMatchLogic:STARRED_FILTER_MATCH_LOGIC_STARRED];
	sharedVals.defaultStarredFilterStarredOrUnstarred = [StarredFilter starredFilterInDataModelController:dataModelController 
		andMatchLogic:STARRED_FILTER_MATCH_LOGIC_STARRED_OR_UNSTARRED];
	sharedVals.defaultStarredFilterUnstarred = [StarredFilter starredFilterInDataModelController:dataModelController 
		andMatchLogic:STARRED_FILTER_MATCH_LOGIC_UNSTARRED];

	return sharedVals;
}

+(BOOL)initFromDatabase
{
    NSLog(@"Initializing database with default data ...");
	
	DataModelController *dmcForInit = [AppHelper appDataModelController];
    
    if(![dmcForInit entitiesExistForEntityName:SHARED_APP_VALS_ENTITY_NAME])
	{
		NSLog(@"Initializing shared values ...");

		[SharedAppVals createWithDataModelController:dmcForInit];
		[dmcForInit saveContext];
		return TRUE; // Database was initialized
	}
	else {
		return FALSE; // No initialization was done
    }
        
}

+(SharedAppVals*)getUsingDataModelController:(DataModelController*)dataModelController
{
	SharedAppVals *theAppValues = (SharedAppVals*)[CoreDataHelper fetchSingleObjectForEntityName:SHARED_APP_VALS_ENTITY_NAME 
		inManagedObectContext:dataModelController.managedObjectContext];
	assert(theAppValues != nil);
	return theAppValues;
}



@end
