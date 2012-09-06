//
//  EmailAddrFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddrFormInfoCreator.h"

#import "FormPopulator.h"
#import "VariableHeightTableHeader.h"
#import "EmailAccount.h"
#import "LocalizationHelper.h"
#import "RegExpTextFieldValidator.h"
#import "TextFieldEditInfo.h"
#import "SectionInfo.h"
#import "EmailAccountFormPopulator.h"

@implementation EmailAddrFormInfoCreator

@synthesize emailAccount;

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

-(id)init
{
	assert(0); // must init with an EmailAccount
	return nil;
}

-(void)dealloc
{
	[emailAccount release];
	[super dealloc];
}

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct
{
	self = [super init];
	if(self)
	{
		self.emailAccount = theEmailAcct;
	}
	return self;
}


@end
