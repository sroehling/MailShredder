//
//  Rule.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgHandlingRule.h"
#import "AgeFilter.h"
#import "EmailAddressFilter.h"
#import "EmailDomainFilter.h"

NSString * const RULE_ENABLED_KEY = @"enabled";
NSString * const RULE_AGE_FILTER_KEY = @"ageFilter";

@implementation MsgHandlingRule

@dynamic enabled;
@dynamic ageFilter;
@dynamic emailAddressFilter;
@dynamic emailDomainFilter;

-(NSString*)ruleSynopsis
{
	assert(0); // must be overriden
	return nil;
}

-(NSPredicate*)rulePredicate:(NSDate*)baseDate
{
	if([self.enabled boolValue])
	{
		NSMutableArray *predicates = [[[NSMutableArray alloc] init] autorelease];

		NSPredicate *agePredicate = [self.ageFilter filterPredicate:baseDate];
		assert(agePredicate != nil);
		[predicates addObject:agePredicate];
		
		NSPredicate *emailAddressPredicate = [self.emailAddressFilter filterPredicate];
		assert(emailAddressPredicate != nil);
		[predicates addObject:emailAddressPredicate];
		
		NSPredicate *emailDomainPredicate = [self.emailDomainFilter filterPredicate];
		assert(emailDomainPredicate != nil);
		[predicates addObject:emailDomainPredicate];
		
		NSPredicate *compoundPredicate = [NSCompoundPredicate 
				andPredicateWithSubpredicates:predicates];
		return compoundPredicate;
	}
	else 
	{
		return [NSPredicate predicateWithValue:FALSE];
	}
}

@end
