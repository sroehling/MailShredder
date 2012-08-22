//
//  RuleSelectionListFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RuleSelectionListFormInfoCreator.h"
#import "FormPopulator.h"
#import "TrashRule.h"
#import "FormContext.h"
#import "LocalizationHelper.h"
#import "DataModelController.h"
#import "FormInfo.h"
#import "VariableHeightTableHeader.h"
#import "TrashMsgListViewFactory.h"
#import "StaticNavFieldEditInfo.h"
#import "SectionInfo.h"
#import "MsgPredicateHelper.h"
#import "DateHelper.h"
#import "TrashMsgListViewInfo.h"
#import "MsgHandlingRule.h"
#import "SharedAppVals.h"

@implementation RuleSelectionListFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
    formPopulator.formInfo.title = LOCALIZED_STR(@"TRASH_RULE_LIST_VIEW_TITLE");
	
	
	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = LOCALIZED_STR(@"TRASH_RULE_LIST_VIEW_HEADER");
	tableHeader.subHeader.text = LOCALIZED_STR(@"TRASH_RULE_LIST_VIEW_SUBHEADER");
	[tableHeader resizeForChildren];
	formPopulator.formInfo.headerView = tableHeader;

	[formPopulator nextSection];
	
	
	NSDate *baseDate = [DateHelper today];
	
	
	if(TRUE)
	{
		NSPredicate *allMsgsPredicate = [MsgPredicateHelper 
			trashedByMsgRules:parentContext.dataModelController andBaseDate:baseDate];
		TrashMsgListViewInfo *allMsgsViewInfo = [[[TrashMsgListViewInfo alloc]
			initWithAppDataModelController:parentContext.dataModelController
			andMsgListPredicate:allMsgsPredicate
			andListHeader:LOCALIZED_STR(@"TRASH_RULE_LIST_ALL_MESSAGES_FIELD_CAPTION") 
			andListSubheader:LOCALIZED_STR(@"TRASH_RULE_LIST_ALL_MESSAGES_FIELD_SUBTITLE")] autorelease];
		TrashMsgListViewFactory *allMsgsViewFactory = [[[TrashMsgListViewFactory alloc] 
			initWithViewInfo:allMsgsViewInfo] autorelease];
		StaticNavFieldEditInfo *allMsgsFieldEditInfo = 
			[[[StaticNavFieldEditInfo alloc] initWithCaption:LOCALIZED_STR(@"TRASH_RULE_LIST_ALL_MESSAGES_FIELD_CAPTION")
			 andSubtitle:LOCALIZED_STR(@"TRASH_RULE_LIST_ALL_MESSAGES_FIELD_SUBTITLE")
			andContentDescription:nil
			andSubViewFactory:allMsgsViewFactory] autorelease];
		[formPopulator.currentSection addFieldEditInfo:allMsgsFieldEditInfo];
	}

	
	NSPredicate *enabledInCurrentAcctPredicate = [MsgPredicateHelper 
		enabledInCurrentAcctPredicate:parentContext.dataModelController];
		
	NSArray *trashRules = [parentContext.dataModelController 
		fetchObjectsForEntityName:TRASH_RULE_ENTITY_NAME 
		andPredicate:enabledInCurrentAcctPredicate andSortKey:RULE_NAME_KEY andSortAscending:TRUE];
	
	if([trashRules count] > 0)
	{
		[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"TRASH_RULE_LIST_SPECIFIC_RULE_SECTION_TITLE")];

		for(TrashRule *trashRule in trashRules)
		{    
			NSPredicate *trashRuleMsgsPredicate = [MsgPredicateHelper 
				trashedByOneRule:trashRule 
				inDataModelController:parentContext.dataModelController andBaseDate:baseDate];
			TrashMsgListViewInfo *trashRuleViewInfo = [[[TrashMsgListViewInfo alloc]
				initWithAppDataModelController:parentContext.dataModelController 
				andMsgListPredicate:trashRuleMsgsPredicate 
				andListHeader:trashRule.ruleName 
				andListSubheader:trashRule.ruleSynopsis] autorelease];
			TrashMsgListViewFactory *trashRuleMsgsViewFactory = [[[TrashMsgListViewFactory alloc] 
				initWithViewInfo:trashRuleViewInfo] autorelease];
			StaticNavFieldEditInfo *trashRuleMsgsFieldEditInfo = 
				[[[StaticNavFieldEditInfo alloc] initWithCaption:trashRule.ruleName
				 andSubtitle:trashRule.ruleSynopsis
				andContentDescription:nil
				andSubViewFactory:trashRuleMsgsViewFactory] autorelease];
			[formPopulator.currentSection addFieldEditInfo:trashRuleMsgsFieldEditInfo];
		}
	}
	
	return formPopulator.formInfo;

}


@end
