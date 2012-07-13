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

@implementation EmailAccountListFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_LIST_VIEW_TITLE");
	formPopulator.formInfo.objectAdder = [[[EmailAccountAdder alloc] init] autorelease];
	
	[formPopulator nextSection];
	
	NSSet *emailAccounts = [parentContext.dataModelController 
				fetchObjectsForEntityName:EMAIL_ACCOUNT_ENTITY_NAME];
	for(EmailAccount *acct in emailAccounts)
	{    
		EmailAccountFormInfoCreator *emailAcctFormInfoCreator = [[[EmailAccountFormInfoCreator alloc] 
			initWithEmailAcct:acct] autorelease];
		[formPopulator populateStaticNavFieldWithFormInfoCreator:emailAcctFormInfoCreator 
			andFieldCaption:acct.acctName andSubTitle:acct.emailAddress];
	
	}

	return formPopulator.formInfo;

}


@end
