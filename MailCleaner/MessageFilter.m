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
#import "EmailDomainFilter.h"

NSString * const MESSAGE_FILTER_ENTITY_NAME = @"MessageFilter";
NSString * const MESSAGE_FILTER_AGE_FILTER_KEY = @"ageFilter";

@implementation MessageFilter

@dynamic filterName;
@dynamic ageFilter;
@dynamic emailAddressFilter;
@dynamic emailDomainFilter;
@dynamic folderFilter;


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

	NSPredicate *emailDomainPredicate = [self.emailDomainFilter filterPredicate];
	assert(emailDomainPredicate != nil);
	[predicates addObject:emailDomainPredicate];
	
	NSPredicate *emailFolderPredicate = [self.folderFilter filterPredicate];
	assert(emailFolderPredicate != nil);
	[predicates addObject:emailFolderPredicate];
		
	NSPredicate *compoundPredicate = [NSCompoundPredicate 
			andPredicateWithSubpredicates:predicates];
	return compoundPredicate;
}

@end
