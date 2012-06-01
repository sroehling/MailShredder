//
//  RuleObjectAdder.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RuleObjectAdder.h"
#import "TableViewObjectAdder.h"
#import "PopupButtonListView.h"
#import "PopupButtonListItemInfo.h"
#import "LocalizationHelper.h"
#import "FormContext.h"
#import "GenericFieldBasedTableAddViewController.h"
#import "ExclusionRuleFormInfoCreator.h"
#import "AppHelper.h"
#import "DataModelController.h"
#import "ExclusionRule.h"
#import "SharedAppVals.h"
#import "TrashRule.h"
#import "AgeFilterNone.h"
#import "TrashRuleFormInfoCreator.h"

@implementation RuleObjectAdder 

@synthesize currentContext;


-(void)addTrashRuleButtonPressed
{
	NSLog(@"new Trash rule");
	assert(currentContext != nil);
	
	DataModelController *dmcForNewRule = [AppHelper appDataModelController];
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:dmcForNewRule];
	
	TrashRule *newRule = (TrashRule*)
		[dmcForNewRule insertObject:TRASH_RULE_ENTITY_NAME];
	newRule.ageFilter = sharedAppVals.defaultAgeFilterNone;
	
	TrashRuleFormInfoCreator *ruleFormCreator = 
		[[[TrashRuleFormInfoCreator alloc] initWithTrashRule:newRule] autorelease];
	
    GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
        initWithFormInfoCreator:ruleFormCreator andNewObject:newRule
		andDataModelController:dmcForNewRule] autorelease];
	addView.popDepth = 1;

	[self.currentContext.parentController.navigationController
		pushViewController:addView animated:TRUE];
}

-(void)addExclusionRuleButtonPressed
{
	NSLog(@"new Exclusion rule");	
	assert(currentContext != nil);
	
	DataModelController *dmcForNewRule = [AppHelper appDataModelController];
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:dmcForNewRule];
	
	ExclusionRule *newRule = (ExclusionRule*)
		[dmcForNewRule insertObject:EXCLUSION_RULE_ENTITY_NAME];
	newRule.ageFilter = sharedAppVals.defaultAgeFilterNone;
	
	ExclusionRuleFormInfoCreator *ruleFormCreator = 
		[[[ExclusionRuleFormInfoCreator alloc] initWithExclusionRule:newRule] autorelease];
	
    GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
        initWithFormInfoCreator:ruleFormCreator andNewObject:newRule
		andDataModelController:dmcForNewRule] autorelease];
	addView.popDepth = 1;

	[self.currentContext.parentController.navigationController
		pushViewController:addView animated:TRUE];
}

-(void)addObjectFromTableView:(FormContext*)parentContext
{

	NSLog(@"Adding rule");
	
	NSMutableArray *actionButtonInfo = [[[NSMutableArray alloc] init] autorelease];
	
	[actionButtonInfo addObject:[[[PopupButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"RULES_ADD_TRASH_RULE_BUTTON_PRESSED")
		 andTarget:self andSelector:@selector(addTrashRuleButtonPressed)] autorelease]];

	[actionButtonInfo addObject:[[[PopupButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"RULES_ADD_EXCLUDE_RULE_BUTTON_PRESSED")
		 andTarget:self andSelector:@selector(addExclusionRuleButtonPressed)] autorelease]];
	
	PopupButtonListView *popupActionList = [[[PopupButtonListView alloc]
		initWithFrame:parentContext.parentController.navigationController.view.frame 
		andButtonListItemInfo:actionButtonInfo] autorelease];
	
	self.currentContext = parentContext;
	[parentContext.parentController.view addSubview:popupActionList];
	
}

-(BOOL)supportsAddOutsideEditMode
{
	return FALSE;
}

-(void)dealloc
{
	[currentContext release];
	[super dealloc];
}


@end
