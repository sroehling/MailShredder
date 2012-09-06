//
//  EmailAddrFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddrFormInfoCreator.h"

#import "EmailAccountFormPopulator.h"
#import "LocalizationHelper.h"

@implementation EmailAddrFormInfoCreator


- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    EmailAccountFormPopulator *formPopulator = [[[EmailAccountFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_VIEW_TITLE");
	
	[formPopulator populateWithHeader:@"" andSubHeader:LOCALIZED_STR(@"EMAIL_ACCOUNT_TABLE_SUBHEADER")];
	
	[formPopulator nextSectionWithTitle:
		LOCALIZED_STR(@"EMAIL_ACCOUNT_ACCOUNT_INFO_SECTION_TITLE")];
	[formPopulator populateEmailAddressField:self.emailAccount];
		
	return formPopulator.formInfo;

}



@end
