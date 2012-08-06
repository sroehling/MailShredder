//
//  DeleteRule.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrashRule.h"
#import "DataModelController.h"

NSString * const TRASH_RULE_ENTITY_NAME = @"TrashRule";

@implementation TrashRule

-(NSString*)ruleSynopsis
{
	return [NSString stringWithFormat:@"Trash messages if ... %@",[self subFilterSynopsis]];
}

+(TrashRule*)createNewDefaultRule:(DataModelController*)dmcForNewRule
{
	TrashRule *newRule = (TrashRule*)
		[dmcForNewRule insertObject:TRASH_RULE_ENTITY_NAME];
		
	[MsgHandlingRule populateDefaultRuleCriteria:newRule usingDataModelController:dmcForNewRule];

	return newRule;
}


@end
