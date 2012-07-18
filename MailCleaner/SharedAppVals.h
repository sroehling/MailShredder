//
//  SharedAppVals.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const SHARED_APP_VALS_ENTITY_NAME;
extern NSString * const SHARED_APP_VALS_CURRENT_EMAIL_ACCOUNT_KEY;

@class MessageFilter;
@class AgeFilterNone;
@class DataModelController;
@class AgeFilterComparison;
@class EmailAccount;

@interface SharedAppVals : NSManagedObject

@property (nonatomic, retain) MessageFilter *msgListFilter;
@property (nonatomic, retain) EmailAccount *currentEmailAcct;

// Defaults and "singleton" objects only
// needing one instance.
@property (nonatomic, retain) AgeFilterNone *defaultAgeFilterNone;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterNewer1Month;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterNewer1Year;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterNewer3Months;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterNewer6Months;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder1Month;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder1Year;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder2Years;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder3Months;
@property (nonatomic, retain) AgeFilterComparison *defaultAgeFilterOlder6Months;


+(void)initFromDatabase;
+(SharedAppVals*)getUsingDataModelController:(DataModelController*)dataModelController;
+(SharedAppVals*)createWithDataModelController:(DataModelController*)dataModelController;

@end
