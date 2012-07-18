//
//  EmailAccountListFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAccountListFormInfoCreator.h"
#import "EmailAccountFormInfoCreator.h"
#import "LocalizationHelper.h"
#import "FormPopulator.h"
#import "FormInfo.h"
#import "EmailAccountAdder.h"
#import "EmailAccount.h"
#import "FormContext.h"
#import "DataModelController.h"
#import "EmailAcctFieldEditInfo.h"
#import "SectionInfo.h"
#import "VariableHeightTableHeader.h"

@implementation EmailAccountListFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_LIST_VIEW_TITLE");
	formPopulator.formInfo.objectAdder = [[[EmailAccountAdder alloc] init] autorelease];
	
	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = @"";
	tableHeader.subHeader.text = LOCALIZED_STR(@"EMAIL_ACCOUNT_LIST_TABLE_SUBHEADER");
	[tableHeader resizeForChildren];
	formPopulator.formInfo.headerView = tableHeader;

	
	[formPopulator nextSection];
	
	NSArray *emailAccounts = [parentContext.dataModelController 
				fetchSortedObjectsWithEntityName:EMAIL_ACCOUNT_ENTITY_NAME sortKey:EMAIL_ACCOUNT_NAME_KEY];
	for(EmailAccount *acct in emailAccounts)
	{    			
		EmailAcctFieldEditInfo *acctFieldEditInfo = 
			[[[EmailAcctFieldEditInfo alloc] initWithEmailAcct:acct andAppDmc:parentContext.dataModelController] autorelease];
		[formPopulator.currentSection addFieldEditInfo:acctFieldEditInfo];
	
	}

	return formPopulator.formInfo;

}


@end
