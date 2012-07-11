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
@class EmailDomainFilter;
@class EmailFolderFilter;

extern NSString * const RULE_ENABLED_KEY;
extern NSString * const RULE_AGE_FILTER_KEY;
extern NSString * const RULE_NAME_KEY;
extern NSInteger const RULE_NAME_MAX_LENGTH;

@interface MsgHandlingRule : NSManagedObject

@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) AgeFilter *ageFilter;
@property (nonatomic, retain) EmailAddressFilter *emailAddressFilter;
@property (nonatomic, retain) EmailDomainFilter *emailDomainFilter;
@property (nonatomic, retain) EmailFolderFilter *folderFilter;
@property (nonatomic, retain) NSString * ruleName;

-(NSString*)ruleSynopsis;
-(NSString*)subFilterSynopsis;
-(NSPredicate*)rulePredicate:(NSDate*)baseDate;

@end
