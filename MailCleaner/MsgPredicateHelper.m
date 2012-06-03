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

+(NSPredicate*)lockedByUser:(BOOL)isLocked
{
	return [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_LOCKED_KEY,[NSNumber numberWithBool:isLocked]];
}

+(NSPredicate*)trashedByUser:(BOOL)isTrashed
{
	return [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_TRASHED_KEY,[NSNumber numberWithBool:isTrashed]];
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
			
			NSPredicate *allTrashPredicate = 
				[NSCompoundPredicate orPredicateWithSubpredicates:trashPredicates];
			NSPredicate *allExclusionsPredicate = 
				[NSCompoundPredicate orPredicateWithSubpredicates:exclusionPredicates];
			NSPredicate *negateAllExclusionsPredicate = 
				[NSCompoundPredicate notPredicateWithSubpredicate:allExclusionsPredicate];
			NSPredicate *trashedByRulesPredicate = 
				[NSCompoundPredicate andPredicateWithSubpredicates:
					[NSArray arrayWithObjects:allTrashPredicate, 
						negateAllExclusionsPredicate,nil]];
			return trashedByRulesPredicate;
		}
		else
		{
			// If there's no exclusion rules, build a predicate matching any of the
			// of the messages matched by the trash predicate.
			return [NSCompoundPredicate orPredicateWithSubpredicates:trashPredicates];
		}
	}
	else
	{
		return [NSPredicate predicateWithValue:FALSE];
	}
}

+(NSPredicate*)trashedByUserOrRules:(DataModelController*)appDmc andBaseDate:(NSDate*)baseDate
{
	// ((Trashed by User) || (Trashed by Rules)) && (not (Locked by user))

	NSPredicate *trashedByUserPredicate = [MsgPredicateHelper trashedByUser:TRUE];
	assert(trashedByUserPredicate != nil);
	
	NSPredicate *trashedByRulesPredicate = [MsgPredicateHelper trashedByMsgRules:appDmc
		andBaseDate:baseDate];
	assert(trashedByRulesPredicate != nil);
	
	NSPredicate *trashedByUserOrRulesPredicate = 
		[NSCompoundPredicate orPredicateWithSubpredicates:[NSArray arrayWithObjects:
			trashedByUserPredicate,trashedByRulesPredicate, nil]];
	
	NSPredicate *notLocked = [MsgPredicateHelper lockedByUser:FALSE];
	assert(notLocked != nil);
	
	NSPredicate *trashListPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:
		[NSArray arrayWithObjects:trashedByUserOrRulesPredicate,notLocked, nil]];
	
	return trashListPredicate;

}

+(NSPredicate*)notTrashedByUserOrRules:(DataModelController*)appDmc
	andBaseDate:(NSDate*)baseDate
{
	return [NSCompoundPredicate notPredicateWithSubpredicate:
		[MsgPredicateHelper trashedByUserOrRules:appDmc andBaseDate:baseDate]];
}

@end
