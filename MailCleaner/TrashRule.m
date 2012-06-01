//
//  DeleteRule.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrashRule.h"
#import "AgeFilter.h"

NSString * const TRASH_RULE_ENTITY_NAME = @"TrashRule";

@implementation TrashRule

-(NSString*)ruleSynopsis
{
	return [NSString stringWithFormat:@"Trash messages if ... %@",[self.ageFilter filterSynopsis]];
}


@end
