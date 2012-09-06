//
//  EmailAccountFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAccountFormInfoCreator.h"
#import "FormPopulator.h"
#import "LocalizationHelper.h"
#import "EmailAccount.h"
#import "NumberHelper.h"
#import "NumberFieldEditInfo.h"
#import "PortNumberValidator.h"
#import "TextFieldEditInfo.h"
#import "SectionInfo.h"
#import "RegExpTextFieldValidator.h"
#import "VariableHeightTableHeader.h"
#import "PortNumFieldEditInfo.h"
#import "SyncFoldersFieldEditInfo.h"

#import "KeychainFieldInfo.h"
#import "SelectableObjectTableViewControllerFactory.h"
#import "MoveToFolderForDeletionFormInfoCreator.h"
#import "ManagedObjectFieldInfo.h"
#import "EmailFolder.h"
#import "EmailAccountFormPopulator.h"


@implementation EmailAccountFormInfoCreator

@synthesize emailAccount;

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
