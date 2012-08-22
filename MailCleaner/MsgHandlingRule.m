//
//  Rule.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgHandlingRule.h"

#import "DataModelController.h"
#import "AgeFilter.h"
#import "EmailAddressFilter.h"
#import "FromAddressFilter.h"
#import "EmailFolderFilter.h"
#import "RecipientAddressFilter.h"
#import "SharedAppVals.h"
#import "AgeFilter.h"
#import "AgeFilterNone.h"
#import "EmailDomainFilter.h"
#import "EmailFolderFilter.h"

NSString * const RULE_ENABLED_KEY = @"enabled";
NSString * const RULE_AGE_FILTER_KEY = @"ageFilter";
NSString * const RULE_NAME_KEY = @"ruleName";
NSString * const RULE_EMAIL_ACCT_KEY = @"emailAcct";
NSInteger const RULE_NAME_MAX_LENGTH = 32;

@implementation MsgHandlingRule

@dynamic enabled;
@dynamic ageFilter;
@dynamic fromAddressFilter;
@dynamic recipientAddressFilter;
@dynamic emailDomainFilter;
@dynamic folderFilter;
@dynamic ruleName;
@dynamic emailAcct;

-(NSString*)ruleSynopsis
{
	assert(0); // must be overriden
	return nil;
}

-(NSString*)subFilterSynopsis
{

	NSMutableArray *synopsisParts = [[[NSMutableArray alloc] init] autorelease];
	
	[synopsisParts addObject:[self.ageFilter filterSynopsis]];
	[synopsisParts addObject:[self.fromAddressFilter filterSynopsis]];
	[synopsisParts addObject:[self.recipientAddressFilter filterSynopsis]];
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
		
		NSPredicate *emailAddressPredicate = [self.fromAddressFilter filterPredicate];
		assert(emailAddressPredicate != nil);
		[predicates addObject:emailAddressPredicate];
		
		NSPredicate *recipientAddressPredicate = [self.recipientAddressFilter filterPredicate];
		assert(recipientAddressPredicate != nil);
		[predicates addObject:recipientAddressPredicate]; 
		
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

+(void)populateDefaultRuleCriteria:(MsgHandlingRule*)msgHandlingRule 
	usingDataModelController:(DataModelController*)dmcForNewRule
{
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:dmcForNewRule];

	msgHandlingRule.ageFilter = sharedAppVals.defaultAgeFilterNone;
	
	msgHandlingRule.fromAddressFilter = (FromAddressFilter*)
		[dmcForNewRule insertObject:FROM_ADDRESS_FILTER_ENTITY_NAME];
		
	msgHandlingRule.recipientAddressFilter = (RecipientAddressFilter*)
			[dmcForNewRule insertObject:RECIPIENT_ADDRESS_FILTER_ENTITY_NAME];
			
	msgHandlingRule.emailDomainFilter = (EmailDomainFilter*)
		[dmcForNewRule insertObject:EMAIL_DOMAIN_FILTER_ENTITY_NAME];

	msgHandlingRule.folderFilter = (EmailFolderFilter*)
		[dmcForNewRule insertObject:EMAIL_FOLDER_FILTER_ENTITY_NAME];
		
	assert(sharedAppVals.currentEmailAcct != nil);
	msgHandlingRule.emailAcct = sharedAppVals.currentEmailAcct;
}

@end
