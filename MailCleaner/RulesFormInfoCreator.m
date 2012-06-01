//
//  RulesFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RulesFormInfoCreator.h"
#import "LocalizationHelper.h"
#import "FormPopulator.h"
#import "RuleObjectAdder.h"
#import "FormContext.h"
#import "DataModelController.h"
#import "ExclusionRule.h"
#import "StaticNavFieldEditInfo.h"
#import "ExclusionRuleFormInfoCreator.h"
#import "SectionInfo.h"
#import "TrashRule.h"
#import "MsgHandlingRuleFieldEditInfo.h"
#import "TrashRuleFormInfoCreator.h"

@implementation RulesFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
    formPopulator.formInfo.title = LOCALIZED_STR(@"RULES_VIEW_TITLE");
	
	formPopulator.formInfo.objectAdder = [[[RuleObjectAdder alloc] init] autorelease];
	
	NSSet *trashRules = [parentContext.dataModelController
		fetchObjectsForEntityName:TRASH_RULE_ENTITY_NAME];
	if([trashRules count] > 0)
	{
		[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"RULES_TRASH_RULES_SECTION_TITLE")];

		for(TrashRule *trashRule in trashRules)
		{    
			TrashRuleFormInfoCreator *trashRuleFormInfoCreator = 
				[[[TrashRuleFormInfoCreator alloc] initWithTrashRule:trashRule] autorelease];
			MsgHandlingRuleFieldEditInfo *trashRuleFieldEditInfo = 
				[[[MsgHandlingRuleFieldEditInfo alloc] 
					initWithMsgHandlingRule:trashRule 
					andSubFormInfoCreator:trashRuleFormInfoCreator] autorelease];
			[formPopulator.currentSection addFieldEditInfo:trashRuleFieldEditInfo];
		}
	}
	
	
	NSSet *exclusionRules = [parentContext.dataModelController
		fetchObjectsForEntityName:EXCLUSION_RULE_ENTITY_NAME];
	if([exclusionRules count] > 0)
	{
		[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"RULES_EXCLUSION_RULES_SECTION_TITLE")];

		for(ExclusionRule *exclusionRule in exclusionRules)
		{    
			ExclusionRuleFormInfoCreator *exclusionRuleFormInfoCreator = 
				[[[ExclusionRuleFormInfoCreator alloc] initWithExclusionRule:exclusionRule] autorelease];
			MsgHandlingRuleFieldEditInfo *exclusionRuleFieldEditInfo = 
				[[[MsgHandlingRuleFieldEditInfo alloc] 
					initWithMsgHandlingRule:exclusionRule 
					andSubFormInfoCreator:exclusionRuleFormInfoCreator] autorelease];
			[formPopulator.currentSection addFieldEditInfo:exclusionRuleFieldEditInfo];
		}
	}


	return formPopulator.formInfo;

}


@end
