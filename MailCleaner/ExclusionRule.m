//
//  ExclusionRule.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExclusionRule.h"
#import "DataModelController.h"

NSString * const EXCLUSION_RULE_ENTITY_NAME = @"ExclusionRule";

@implementation ExclusionRule

-(NSString*)ruleSynopsis
{
	return [NSString stringWithFormat:@"Don't trash messages if ... %@",[self subFilterSynopsis]];
}

+(ExclusionRule*)createNewDefaultRule:(DataModelController*)dmcForNewRule
{
	ExclusionRule *newRule = (ExclusionRule*)
		[dmcForNewRule insertObject:EXCLUSION_RULE_ENTITY_NAME];
		
	[MsgHandlingRule populateDefaultRuleCriteria:newRule usingDataModelController:dmcForNewRule];
	
	return newRule;

}


@end
