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

@implementation EmailAddrFormInfoCreator

@synthesize emailAccount;

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_VIEW_TITLE");
	
	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = @"";
	tableHeader.subHeader.text = LOCALIZED_STR(@"EMAIL_ACCOUNT_TABLE_SUBHEADER");
	[tableHeader resizeForChildren];
	formPopulator.formInfo.headerView = tableHeader;

	
	[formPopulator nextSectionWithTitle:
		LOCALIZED_STR(@"EMAIL_ACCOUNT_ACCOUNT_INFO_SECTION_TITLE")];
	
	if(TRUE)
	{
		// TODO - Make the population of email address field reusable.
		NSString *emailRegExPattern = 
			@"^(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
			@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
			@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
			"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
			@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
			@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
			@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])$";
		TextFieldValidator *addressValidator = [[[RegExpTextFieldValidator alloc] 
			initWithValidationMsg:LOCALIZED_STR(@"EMAIL_ACCOUNT_ADDRESS_VALIDATION_MSG")
			andPattern:emailRegExPattern] autorelease];
		TextFieldEditInfo *emailAddrFieldEditInfo = [TextFieldEditInfo 
			createForObject:self.emailAccount andKey:EMAIL_ACCOUNT_ADDRESS_KEY 
			andLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_ADDRESS_FIELD_LABEL") 
			andPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_ADDRESS_PLACEHOLDER") 
			andValidator:addressValidator andSecureTextEntry:NO 
			andAutoCorrectType:UITextAutocorrectionTypeNo];
		[formPopulator.currentSection addFieldEditInfo:emailAddrFieldEditInfo];
	}
		
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
