//
//  MoreFormInfoCreator.m
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MoreFormInfoCreator.h"
#import "HelpPageFormPopulator.h"
#import "LocalizationHelper.h"
#import "EmailAccountListFormInfoCreator.h"
#import "ManagedObjectFieldInfo.h"
#import "SharedAppVals.h"
#import "SelectableObjectTableEditViewController.h"
#import "StaticNavFieldEditInfo.h"
#import "SelectableObjectTableViewControllerFactory.h"
#import "GenericFieldBasedTableEditViewControllerFactory.h"
#import "FormContext.h"
#import "SectionInfo.h"
#import "SavedMessageFilterListFormInfoCreator.h"
#import "PasscodeFieldInfo.h"
#import "BoolFieldEditInfo.h"

@implementation MoreFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    HelpPageFormPopulator *formPopulator = [[[HelpPageFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"SETTINGS_VIEW_TITLE");

	[formPopulator nextSection];
	
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:parentContext.dataModelController];
	
	ManagedObjectFieldInfo *currentAcctFieldInfo = 
		[[[ManagedObjectFieldInfo alloc] initWithManagedObject:sharedAppVals 
		andFieldKey:SHARED_APP_VALS_CURRENT_EMAIL_ACCOUNT_KEY 
			andFieldLabel:@"dummy" andFieldPlaceholder:@"dummy"] autorelease];
			
	if(TRUE)
	{
		EmailAccountListFormInfoCreator *emailAcctListFormInfoCreator = 
			[[[EmailAccountListFormInfoCreator alloc] init] autorelease];		
				
		SelectableObjectTableViewControllerFactory *selectCurrentAcctControllerFactory = 
			[[[SelectableObjectTableViewControllerFactory alloc] 
			initWithFormInfoCreator:emailAcctListFormInfoCreator andAssignedField:currentAcctFieldInfo] autorelease];
		selectCurrentAcctControllerFactory.saveAfterSelection = TRUE;
			
		StaticNavFieldEditInfo *acctListFieldEditInfo = 
			[[[StaticNavFieldEditInfo alloc] initWithCaption:LOCALIZED_STR(@"EMAIL_ACCOUNT_LIST_VIEW_TITLE") 
			andSubtitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_LIST_FIELD_SUBTITLE") 
			andContentDescription:nil andSubViewFactory:selectCurrentAcctControllerFactory] autorelease];
		
		[formPopulator.currentSection addFieldEditInfo:acctListFieldEditInfo];
	}		
	
	if(TRUE)
	{
		SavedMessageFilterListFormInfoCreator *savedFilterFormInfoCreator = [[[SavedMessageFilterListFormInfoCreator alloc] init] autorelease];
		GenericFieldBasedTableEditViewControllerFactory *savedFiltersViewControllerFactory = 
			[[[GenericFieldBasedTableEditViewControllerFactory alloc] initWithFormInfoCreator:savedFilterFormInfoCreator] autorelease];
		StaticNavFieldEditInfo *savedFiltersFieldEditInfo = 
			[[[StaticNavFieldEditInfo alloc] initWithCaption:LOCALIZED_STR(@"SAVED_FILTERS_FIELD_CAPTION") 
			andSubtitle:LOCALIZED_STR(@"SAVED_FILTERS_FIELD_SUBTITLE") 
			andContentDescription:nil andSubViewFactory:savedFiltersViewControllerFactory] autorelease];
		[formPopulator.currentSection addFieldEditInfo:savedFiltersFieldEditInfo];
	}
	
	[formPopulator nextSection];
	PasscodeFieldInfo *passcodeFieldInfo  = [[[PasscodeFieldInfo alloc] 
				initWithParentController:parentContext.parentController] autorelease];
	BoolFieldEditInfo *passcodeFieldEditInfo = 
		[[[BoolFieldEditInfo alloc] 
			initWithFieldInfo: passcodeFieldInfo
			andSubtitle:nil] autorelease];
	[formPopulator.currentSection addFieldEditInfo:passcodeFieldEditInfo];

	[formPopulator nextSection];
	
	[formPopulator populateHelpPageWithTitle:LOCALIZED_STR(@"HELP_ABOUT") andPageRef:@"about"];

	
	return formPopulator.formInfo;

}

@end
