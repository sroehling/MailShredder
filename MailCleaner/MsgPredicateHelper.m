//
//  MsgPredicateHelper.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgPredicateHelper.h"
#import "TrashRule.h"
#import "ExclusionRule.h"
#import "DataModelController.h"
#import "EmailInfo.h"

@implementation MsgPredicateHelper

+(NSPredicate*)markedForDeletion
{
	return [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_DELETED_KEY,[NSNumber numberWithBool:TRUE]];
}

+(NSPredicate*)notExcludedInDataModelController:(DataModelController*)appDmc 
	forBaseDate:(NSDate*)baseDate
{
	NSPredicate *enabledExclusionRulesPredicate = [NSPredicate 
		predicateWithFormat:@"%K == %@",
		RULE_ENABLED_KEY,[NSNumber numberWithBool:TRUE]];

	NSArray *exclusionRules = [appDmc fetchObjectsForEntityName:EXCLUSION_RULE_ENTITY_NAME
		andPredicate:enabledExclusionRulesPredicate];
		
	if([exclusionRules count] > 0)
	{
		NSMutableArray *exclusionPredicates = [[[NSMutableArray alloc] init] autorelease];
		for(ExclusionRule *exclusionRule in exclusionRules)
		{
			NSPredicate *exclusionPredicate = [exclusionRule rulePredicate:baseDate];
			assert(exclusionPredicate != nil);
			[exclusionPredicates addObject:exclusionPredicate];
		} // For each exclusion rule
		NSPredicate *allExclusionsPredicate = 
			[NSCompoundPredicate orPredicateWithSubpredicates:exclusionPredicates];
		NSPredicate *negateAllExclusionsPredicate = 
			[NSCompoundPredicate notPredicateWithSubpredicate:allExclusionsPredicate];
		return negateAllExclusionsPredicate;
	}
	else 
	{
		// If there are no enabled exclusion rules, then the value for excluded is always
		// FALSE (i.e., no messages excluded). Then, negating this FALSE value 
		// always yields TRUE.
		return [NSPredicate predicateWithValue:TRUE];
	}

}

+(NSPredicate*)trashedByOneRule:(TrashRule*)theTrashRule 
	inDataModelController:(DataModelController*)appDmc andBaseDate:(NSDate*)baseDate
{
		NSPredicate *trashPredicate = [theTrashRule rulePredicate:baseDate];
		assert(trashPredicate != nil);
		
		NSPredicate *notExcluded = [MsgPredicateHelper 
			notExcludedInDataModelController:appDmc forBaseDate:baseDate];

		return [NSCompoundPredicate andPredicateWithSubpredicates:
			[NSArray arrayWithObjects:trashPredicate, notExcluded,nil]];

}

+(NSPredicate*)trashedByMsgRules:(DataModelController*)appDmc andBaseDate:(NSDate*)baseDate
{

	NSPredicate *enabledTrashRulesPredicate = [NSPredicate predicateWithFormat:@"%K == %@",
		RULE_ENABLED_KEY,[NSNumber numberWithBool:TRUE]];
	NSArray *trashRules = [appDmc fetchObjectsForEntityName:TRASH_RULE_ENTITY_NAME
		andPredicate:enabledTrashRulesPredicate];
		
	if([trashRules count] > 0)
	{
		NSMutableArray *trashPredicates = [[[NSMutableArray alloc] init] autorelease];
		
		for(TrashRule *trashRule in trashRules)
		{
			NSPredicate *trashPredicate = [trashRule rulePredicate:baseDate];
			assert(trashPredicate != nil);
			[trashPredicates addObject:trashPredicate];
		}
		NSPredicate *allTrashPredicate = 
				[NSCompoundPredicate orPredicateWithSubpredicates:trashPredicates];
		
		NSPredicate *notExcluded = [MsgPredicateHelper notExcludedInDataModelController:appDmc 
			forBaseDate:baseDate];
		
		return [NSCompoundPredicate andPredicateWithSubpredicates:
					[NSArray arrayWithObjects:allTrashPredicate, 
						notExcluded,nil]];
		
	}
	else
	{
		// No trash rules, so don't match any messages
		return [NSPredicate predicateWithValue:FALSE];
	}
}



@end
