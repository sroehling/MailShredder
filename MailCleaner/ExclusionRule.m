//
//  ExclusionRule.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExclusionRule.h"
#import "AgeFilter.h"
#import "DataModelController.h"
#import "SharedAppVals.h"
#import "EmailAddressFilter.h"
#import "AgeFilter.h"
#import "AgeFilterNone.h"
#import "EmailDomainFilter.h"

NSString * const EXCLUSION_RULE_ENTITY_NAME = @"ExclusionRule";

@implementation ExclusionRule

-(NSString*)ruleSynopsis
{
	return [NSString stringWithFormat:@"Don't trash messages if ... %@",[self.ageFilter filterSynopsis]];
}

+(ExclusionRule*)createNewDefaultRule:(DataModelController*)dmcForNewRule
{
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:dmcForNewRule];

	ExclusionRule *newRule = (ExclusionRule*)
		[dmcForNewRule insertObject:EXCLUSION_RULE_ENTITY_NAME];
	newRule.ageFilter = sharedAppVals.defaultAgeFilterNone;
	newRule.emailAddressFilter = (EmailAddressFilter*)
		[dmcForNewRule insertObject:EMAIL_ADDRESS_FILTER_ENTITY_NAME];
	newRule.emailDomainFilter = (EmailDomainFilter*)
		[dmcForNewRule insertObject:EMAIL_DOMAIN_FILTER_ENTITY_NAME];
		
	return newRule;

}


@end
