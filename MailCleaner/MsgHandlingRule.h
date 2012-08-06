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
@class FromAddressFilter;
@class RecipientAddressFilter;
@class EmailDomainFilter;
@class EmailFolderFilter;
@class DataModelController;

extern NSString * const RULE_ENABLED_KEY;
extern NSString * const RULE_AGE_FILTER_KEY;
extern NSString * const RULE_NAME_KEY;
extern NSInteger const RULE_NAME_MAX_LENGTH;

@interface MsgHandlingRule : NSManagedObject

@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) AgeFilter *ageFilter;
@property (nonatomic, retain) EmailDomainFilter *emailDomainFilter;
@property (nonatomic, retain) EmailFolderFilter *folderFilter;
@property (nonatomic, retain) NSString * ruleName;
@property (nonatomic, retain) FromAddressFilter *fromAddressFilter;
@property (nonatomic, retain) RecipientAddressFilter *recipientAddressFilter;

-(NSString*)ruleSynopsis;
-(NSString*)subFilterSynopsis;
-(NSPredicate*)rulePredicate:(NSDate*)baseDate;

+(void)populateDefaultRuleCriteria:(MsgHandlingRule*)msgHandlingRule 
	usingDataModelController:(DataModelController*)dmcForNewRule;

@end
