//
//  EmailAddrFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BasicEmailAccountFormInfoCreator.h"

#import "EmailAccountFormPopulator.h"
#import "LocalizationHelper.h"

@implementation BasicEmailAccountFormInfoCreator


- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    EmailAccountFormPopulator *formPopulator = [[[EmailAccountFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_VIEW_TITLE");
	[formPopulator populateWithHeader:@"" andSubHeader:LOCALIZED_STR(@"EMAIL_ACCOUNT_TABLE_BASIC_INFO_SUBHEADER")];

	[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_ACCOUNT_INFO_SECTION_TITLE")];
	[formPopulator populateEmailAccountNameField:self.emailAccount];
	[formPopulator populateEmailAddressField:self.emailAccount];

	[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_PASSWORD_SECTION")];		
	[formPopulator populatePasswordField:self.emailAccount];

	return formPopulator.formInfo;
}



@end
