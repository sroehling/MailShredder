//
//  IMAPServerEmailAccountFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IMAPServerEmailAccountFormInfoCreator.h"
#import "EmailAccountFormPopulator.h"
#import "LocalizationHelper.h"

@implementation IMAPServerEmailAccountFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    EmailAccountFormPopulator *formPopulator = [[[EmailAccountFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];

	formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_VIEW_TITLE");
	[formPopulator populateWithHeader:LOCALIZED_STR(@"EMAIL_ACCOUNT_TABLE_IMAP_SERVER_HEADER") 
			andSubHeader:LOCALIZED_STR(@"EMAIL_ACCOUNT_TABLE_IMAP_SERVER_SUBHEADER")];

	[formPopulator nextSection];		
	[formPopulator populateIMAPHostNameField:self.emailAccount];

	return formPopulator.formInfo;
}



@end
