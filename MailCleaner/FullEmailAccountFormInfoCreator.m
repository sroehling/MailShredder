//
//  FullEmailAccountFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FullEmailAccountFormInfoCreator.h"
#import "EmailAccountFormPopulator.h"
#import "LocalizationHelper.h"

@implementation FullEmailAccountFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    EmailAccountFormPopulator *formPopulator = [[[EmailAccountFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_VIEW_TITLE");
	[formPopulator populateWithHeader:@"" andSubHeader:LOCALIZED_STR(@"EMAIL_ACCOUNT_TABLE_SUBHEADER")];
	
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
	
	[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_SETTINGS_SECTION")
		 andHelpFile:@"emailAcctDeleteSettings"];
	[formPopulator populateDeleteMsgsField:self.emailAccount];
	[formPopulator populateSyncFoldersField:self.emailAccount]; 
	[formPopulator populateMoveToDeleteFolderSetting:self.emailAccount];

	return formPopulator.formInfo;

}


@end
