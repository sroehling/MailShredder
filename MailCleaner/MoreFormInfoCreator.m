//
//  MoreFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
#import "FormContext.h"
#import "SectionInfo.h"

@implementation MoreFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    HelpPageFormPopulator *formPopulator = [[[HelpPageFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"MORE_VIEW_TITLE");

	[formPopulator nextSection];
	
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:parentContext.dataModelController];
	
	
	ManagedObjectFieldInfo *currentAcctFieldInfo = 
		[[[ManagedObjectFieldInfo alloc] initWithManagedObject:sharedAppVals 
		andFieldKey:SHARED_APP_VALS_CURRENT_EMAIL_ACCOUNT_KEY 
			andFieldLabel:@"dummy" andFieldPlaceholder:@"dummy"] autorelease];
			
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

	[formPopulator nextSection];
	
	[formPopulator populateHelpPageWithTitle:LOCALIZED_STR(@"HELP_ABOUT") andPageRef:@"about"];

	
	return formPopulator.formInfo;

}

@end
