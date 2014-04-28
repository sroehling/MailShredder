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
#import "RateAppFieldEditInfo.h"
#import "NumberPickerFieldEditInfo.h"

@implementation MoreFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    HelpPageFormPopulator *formPopulator = [[[HelpPageFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
    
    
    [formPopulator populateWithHeader:LOCALIZED_STR(@"SETTINGS_VIEW_HEADER")
                         andSubHeader:LOCALIZED_STR(@"SETTINGS_VIEW_SUBHEADER")
                          andHelpFile:@"settings" andParentController:parentContext.parentController ];
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
    
    if(TRUE)
	{
        
        ManagedObjectFieldInfo *maxDeleteIncrementAcctFieldInfo =
		[[[ManagedObjectFieldInfo alloc] initWithManagedObject:sharedAppVals
                andFieldKey:SHARED_APP_VALS_MAX_DELETE_INCREMENT_KEY
                andFieldLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_MAX_DELETE_INCREMENT_FIELD_LABEL")
                andFieldPlaceholder:@"dummy"] autorelease];

        
        NSArray *selectableMaxValues = [NSArray arrayWithObjects:
                                        [NSNumber numberWithUnsignedInteger:25],
                                        [NSNumber numberWithUnsignedInteger:50],
                                        [NSNumber numberWithUnsignedInteger:100],
                                        [NSNumber numberWithUnsignedInteger:250],
                                        [NSNumber numberWithUnsignedInteger:500],
                                        [NSNumber numberWithUnsignedInteger:1000],
                                        nil];
        
        NumberPickerFieldEditInfo *maxDeletMsgsIncrementFieldEditInfo = [[[NumberPickerFieldEditInfo alloc]
                    initWithFieldInfo:maxDeleteIncrementAcctFieldInfo andNumberVals:selectableMaxValues andTitle:
                    LOCALIZED_STR(@"EMAIL_ACCOUNT_MAX_DELETE_INCREMENT_FIELD_LABEL")] autorelease];
        maxDeletMsgsIncrementFieldEditInfo.fieldSubtitle =
            LOCALIZED_STR(@"EMAIL_ACCOUNT_MAX_DELETE_INCREMENT_FIELD_SUBTITLE");
		
        [formPopulator.currentSection addFieldEditInfo:maxDeletMsgsIncrementFieldEditInfo];
        
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
	[formPopulator.currentSection addFieldEditInfo:[[[RateAppFieldEditInfo alloc] init] autorelease]];

	
	return formPopulator.formInfo;

}

@end
