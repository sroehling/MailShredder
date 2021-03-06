//
//  SharedAppVals.h
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const SHARED_APP_VALS_ENTITY_NAME;
extern NSString * const SHARED_APP_VALS_CURRENT_EMAIL_ACCOUNT_KEY;
extern NSString * const SHARED_APP_VALS_MAX_DELETE_INCREMENT_KEY;

@class MessageFilter;
@class AgeFilterNone;
@class DataModelController;
@class AgeFilterComparison;
@class EmailAccount;
@class ReadFilter;
@class StarredFilter;
@class SentReceivedFilter;

@interface SharedAppVals : NSManagedObject

@property (nonatomic, retain) EmailAccount *currentEmailAcct;
@property (nonatomic, retain) NSNumber * maxDeleteIncrement;


// Defaults and "singleton" objects only
// needing one instance.
@property (nonatomic, retain) AgeFilterNone *defaultAgeFilterNone;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder1Month;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder1Year;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder2Years;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder3Months;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder6Months;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder3Years;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder4Years;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder5Years;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder18Months;


@property (nonatomic, retain) ReadFilter *defaultReadFilterRead;
@property (nonatomic, retain) ReadFilter *defaultReadFilterReadOrUnread;
@property (nonatomic, retain) ReadFilter *defaultReadFilterUnread;

@property (nonatomic, retain) StarredFilter *defaultStarredFilterStarred;
@property (nonatomic, retain) StarredFilter *defaultStarredFilterStarredOrUnstarred;
@property (nonatomic, retain) StarredFilter *defaultStarredFilterUnstarred;

@property (nonatomic, retain) SentReceivedFilter *defaultSentReceivedFilterEither;
@property (nonatomic, retain) SentReceivedFilter *defaultSentReceivedFilterReceived;
@property (nonatomic, retain) SentReceivedFilter *defaultSentReceivedFilterSent;


+(BOOL)initFromDatabase;
+(SharedAppVals*)getUsingDataModelController:(DataModelController*)dataModelController;
+(SharedAppVals*)createWithDataModelController:(DataModelController*)dataModelController;

@end
