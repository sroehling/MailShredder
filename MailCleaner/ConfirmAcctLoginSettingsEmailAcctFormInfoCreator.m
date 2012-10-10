//
//  ConfirmAcctLoginSettingsEmailAcctFormInfoCreator.m
//
//  Created by Steve Roehling on 9/7/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "ConfirmAcctLoginSettingsEmailAcctFormInfoCreator.h"
#import "EmailAccountFormPopulator.h"
#import "LocalizationHelper.h"

@implementation ConfirmAcctLoginSettingsEmailAcctFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    EmailAccountFormPopulator *formPopulator = [[[EmailAccountFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_VIEW_TITLE");
	[formPopulator populateWithHeader:LOCALIZED_STR(@"EMAIL_ACCOUNT_TABLE_CONFIRM_SETTINGS_HEADER") 
		andSubHeader:LOCALIZED_STR(@"EMAIL_ACCOUNT_TABLE_CONFIRM_SETTINGS_SUBHEADER")];
	
	[formPopulator nextSectionWithTitle: LOCALIZED_STR(@"EMAIL_ACCOUNT_ACCOUNT_INFO_SECTION_TITLE")];
	[formPopulator populateEmailAccountNameField:self.emailAccount];
	[formPopulator populateEmailAddressField:self.emailAccount];
		
	[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_MAIL_SERVER_SECTION")];		
	[formPopulator populateIMAPHostNameField:self.emailAccount];
	[formPopulator populateUserNameField:self.emailAccount];
	[formPopulator populatePasswordField:self.emailAccount];

	[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_ADVANCED_SECTION")];
	[formPopulator populateUseSSL:self.emailAccount];
	[formPopulator populatePortNumberField:self.emailAccount];
	
	return formPopulator.formInfo;

}


@end
