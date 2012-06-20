//
//  MessageFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilter.h"
#import "AgeFilter.h"
#import "EmailAddressFilter.h"

NSString * const MESSAGE_FILTER_ENTITY_NAME = @"MessageFilter";
NSString * const MESSAGE_FILTER_AGE_FILTER_KEY = @"ageFilter";

@implementation MessageFilter

@dynamic filterName;
@dynamic ageFilter;
@dynamic emailAddressFilter;

// Inverse
@dynamic sharedAppValsMsgListFilter;

-(NSPredicate*)filterPredicate:(NSDate*)baseDate
{
	NSMutableArray *predicates = [[[NSMutableArray alloc] init] autorelease];

	NSPredicate *agePredicate = [self.ageFilter filterPredicate:baseDate];
	assert(agePredicate != nil);
	[predicates addObject:agePredicate];

	NSPredicate *emailAddressPredicate = [self.emailAddressFilter filterPredicate];
	assert(emailAddressPredicate != nil);
	[predicates addObject:emailAddressPredicate];

	
	NSPredicate *compoundPredicate = [NSCompoundPredicate 
			andPredicateWithSubpredicates:predicates];
	return compoundPredicate;
}

@end
