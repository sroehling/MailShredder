//
//  AgeFilterComparison.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AgeFilter.h"

@class SharedAppVals;
@class DataModelController;


extern NSString * const AGE_FILTER_COMPARISON_ENTITY_NAME;
extern NSUInteger const AGE_FILTER_COMPARISON_TIME_UNIT_WEEKS;
extern NSUInteger const AGE_FILTER_COMPARISON_TIME_UNIT_MONTHS;
extern NSUInteger const AGE_FILTER_COMPARISON_TIME_UNIT_YEARS;
extern NSUInteger const AGE_FILTER_COMPARISON_OLDER;
extern NSUInteger const AGE_FILTER_COMPARISON_NEWER;

@interface AgeFilterComparison : AgeFilter

@property (nonatomic, retain) NSNumber * interval;
@property (nonatomic, retain) NSNumber * timeUnit;
@property (nonatomic, retain) NSNumber * comparison;
@property (nonatomic, retain) NSNumber * showInFilterPopupMenu;

// Inverse Relationships
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterOlder1Month;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterOlder1Year;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterOlder2Years;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterOlder3Months;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterOlder6Months;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterOlder3Years;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterOlder4Years;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterOlder5Years;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterOlder18Months;


+(AgeFilterComparison*)filterWithDataModelController:(DataModelController*)dmc
	andComparisonType:(NSUInteger)theComparison
	andInterval:(NSUInteger)theInterval
	andTimeUnit:(NSUInteger)theTimeUnit;

@end
