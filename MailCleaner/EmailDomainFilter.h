//
//  EmailDomainFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmailDomain, MessageFilter, MsgHandlingRule;

extern NSString * const EMAIL_DOMAIN_FILTER_ENTITY_NAME;

@interface EmailDomainFilter : NSManagedObject

@property (nonatomic, retain) NSSet *selectedDomains;

// Inverse relationships
@property (nonatomic, retain) MessageFilter *messageFilterDomainFilter;
@property (nonatomic, retain) MsgHandlingRule *msgHandlingRuleDomainFilter;

-(NSString*)filterSynopsis;
-(NSPredicate*)filterPredicate;

@end

@interface EmailDomainFilter (CoreDataGeneratedAccessors)

- (void)addSelectedDomainsObject:(EmailDomain *)value;
- (void)removeSelectedDomainsObject:(EmailDomain *)value;
- (void)addSelectedDomains:(NSSet *)values;
- (void)removeSelectedDomains:(NSSet *)values;

@end
