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

@implementation RuleSelectionListFormInfoCreator

@synthesize emailInfoDmc;

-(id)initWithEmailInfoDataModelController:(DataModelController*)theEmailInfoDmc
{
	self = [super init];
	if(self)
	{
		assert(theEmailInfoDmc != nil);
		self.emailInfoDmc = theEmailInfoDmc;
	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}

-(void)dealloc
{
	[emailInfoDmc release];
	[super dealloc];
}

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
			initWithEmailInfoDataModelController:self.emailInfoDmc 
			andAppDataModelController:parentContext.dataModelController
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

	
	NSPredicate *enabledRulesPredicate = [NSPredicate predicateWithFormat:@"%K = %@",
		RULE_ENABLED_KEY,[NSNumber numberWithBool:TRUE]];
	NSArray *trashRules = [parentContext.dataModelController 
		fetchObjectsForEntityName:TRASH_RULE_ENTITY_NAME 
		andPredicate:enabledRulesPredicate andSortKey:RULE_NAME_KEY andSortAscending:TRUE];
	
	if([trashRules count] > 0)
	{
		[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"TRASH_RULE_LIST_SPECIFIC_RULE_SECTION_TITLE")];

		for(TrashRule *trashRule in trashRules)
		{    
			NSPredicate *trashRuleMsgsPredicate = [MsgPredicateHelper 
				trashedByOneRule:trashRule 
				inDataModelController:parentContext.dataModelController andBaseDate:baseDate];
			TrashMsgListViewInfo *trashRuleViewInfo = [[[TrashMsgListViewInfo alloc]
				initWithEmailInfoDataModelController:self.emailInfoDmc 
				andAppDataModelController:parentContext.dataModelController 
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
