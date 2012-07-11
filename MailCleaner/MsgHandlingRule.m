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
#import "EmailFolderFilter.h"

NSString * const RULE_ENABLED_KEY = @"enabled";
NSString * const RULE_AGE_FILTER_KEY = @"ageFilter";
NSString * const RULE_NAME_KEY = @"ruleName";
NSInteger const RULE_NAME_MAX_LENGTH = 32;

@implementation MsgHandlingRule

@dynamic enabled;
@dynamic ageFilter;
@dynamic emailAddressFilter;
@dynamic emailDomainFilter;
@dynamic folderFilter;
@dynamic ruleName;


-(NSString*)ruleSynopsis
{
	assert(0); // must be overriden
	return nil;
}

-(NSString*)subFilterSynopsis
{

	NSMutableArray *synopsisParts = [[[NSMutableArray alloc] init] autorelease];
	[synopsisParts addObject:[self.ageFilter filterSynopsis]];
	[synopsisParts addObject:[self.emailAddressFilter filterSynopsis]];
	[synopsisParts addObject:[self.emailDomainFilter filterSynopsis]];
	[synopsisParts addObject:[self.folderFilter filterSynopsis]];
	return [synopsisParts componentsJoinedByString:@", "];

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

		NSPredicate *emailFolderPredicate = [self.folderFilter filterPredicate];
		assert(emailFolderPredicate != nil);
		[predicates addObject:emailFolderPredicate];
		
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
