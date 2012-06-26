//
//  DeleteRule.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrashRule.h"
#import "AgeFilter.h"
#import "DataModelController.h"
#import "AgeFilterNone.h"
#import "EmailAddressFilter.h"
#import "SharedAppVals.h"

NSString * const TRASH_RULE_ENTITY_NAME = @"TrashRule";

@implementation TrashRule

-(NSString*)ruleSynopsis
{
	return [NSString stringWithFormat:@"Trash messages if ... %@",[self.ageFilter filterSynopsis]];
}

+(TrashRule*)createNewDefaultRule:(DataModelController*)dmcForNewRule
{

	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:dmcForNewRule];

	TrashRule *newRule = (TrashRule*)
		[dmcForNewRule insertObject:TRASH_RULE_ENTITY_NAME];
	newRule.ageFilter = sharedAppVals.defaultAgeFilterNone;
	newRule.emailAddressFilter = (EmailAddressFilter*)
		[dmcForNewRule insertObject:EMAIL_ADDRESS_FILTER_ENTITY_NAME];
		
	return newRule;
}


@end
