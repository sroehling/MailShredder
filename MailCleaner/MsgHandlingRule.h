//
//  Rule.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AgeFilter;
@class EmailAddressFilter;

extern NSString * const RULE_ENABLED_KEY;
extern NSString * const RULE_AGE_FILTER_KEY;

@interface MsgHandlingRule : NSManagedObject

@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) AgeFilter *ageFilter;
@property (nonatomic, retain) EmailAddressFilter *emailAddressFilter;

-(NSString*)ruleSynopsis;
-(NSPredicate*)rulePredicate:(NSDate*)baseDate;

@end
