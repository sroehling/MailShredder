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


@implementation EmailAccountFormInfoCreator

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
	
	[formPopulator populateNameFieldInParentObj:self.emailAccount 
		withNameField:EMAIL_ACCOUNT_NAME_KEY 
		andPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_NAME_PLACEHOLDER") 
		andMaxLength:EMAIL_ACCOUNT_NAME_MAX_LENGTH];

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

		
	[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_MAIL_SERVER_SECTION")];
	
	if(TRUE)
	{
		NSString *hostNameRegExpPattern = 
			@"^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])(\\.([a-zA-Z0-9]|"
			@"[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9]))*$";
		TextFieldValidator *hostnameValidator = [[[RegExpTextFieldValidator alloc] 
			initWithValidationMsg:LOCALIZED_STR(@"EMAIL_ACCOUNT_HOSTNAME_VALIDATION_MSG")
			andPattern:hostNameRegExpPattern] autorelease];
		TextFieldEditInfo *hostnameFieldEditInfo = [TextFieldEditInfo 
			createForObject:self.emailAccount andKey:EMAIL_ACCOUNT_IMAPSERVER_KEY 
			andLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_IMAP_SERVER_FIELD_LABEL") 
			andPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_IMAP_SERVER_PLACEHOLDER") 
			andValidator:hostnameValidator andSecureTextEntry:NO 
			andAutoCorrectType:UITextAutocorrectionTypeNo];
		[formPopulator.currentSection addFieldEditInfo:hostnameFieldEditInfo];
	}

	if(TRUE)
	{
		// User name regular expression is same as email, but optionally includes
		// the part after the @ character.
		NSString *userNameRegExPattern = 
			@"^(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
			@"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
			@"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")(@(?:(?:[a-z0-9](?:[a-"
			"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
			@"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
			@"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
			@"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\]))?$";
		TextFieldValidator *userNameValidator = [[[RegExpTextFieldValidator alloc] 
			initWithValidationMsg:LOCALIZED_STR(@"EMAIL_ACCOUNT_USERNAME_VALIDATION_MSG")
			andPattern:userNameRegExPattern] autorelease];
		TextFieldEditInfo *userNameFieldEditInfo = [TextFieldEditInfo 
			createForObject:self.emailAccount andKey:EMAIL_ACCOUNT_USERNAME_KEY 
			andLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_USERNAME_FIELD_LABEL") 
			andPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_USERNAME_PLACEHOLDER") 
			andValidator:userNameValidator andSecureTextEntry:NO 
			andAutoCorrectType:UITextAutocorrectionTypeNo];
		[formPopulator.currentSection addFieldEditInfo:userNameFieldEditInfo];
	}


	if(TRUE)
	{
		// User name regular expression is same as email, but optionally includes
		// the part after the @ character.
		NSString *passwordRegExPattern = @"^.+$";
		TextFieldValidator *passwordValidator = [[[RegExpTextFieldValidator alloc] 
			initWithValidationMsg:LOCALIZED_STR(@"EMAIL_ACCOUNT_PASSWORD_VALIDATION_MSG")
			andPattern:passwordRegExPattern] autorelease];
		KeychainFieldInfo *passwordFieldInfo = [self.emailAccount passwordFieldInfo];		
		TextFieldEditInfo *passwordFieldEditInfo = [[[TextFieldEditInfo alloc]
			initWithFieldInfo:passwordFieldInfo andValidator:passwordValidator 
			andSecureTextEntry:YES andAutoCorrection:UITextAutocorrectionTypeNo] autorelease];
			
		[formPopulator.currentSection addFieldEditInfo:passwordFieldEditInfo];
	}

		
	[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_ADVANCED_SECTION")];

	[formPopulator populateBoolFieldInParentObj:self.emailAccount withBoolField:EMAIL_ACCOUNT_USESSL_KEY 
		andFieldLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_USESSL_FIELD_TITLE") 
		andSubTitle:@""];
		
	if(TRUE)
	{
		PortNumFieldEditInfo *portNumFieldEditInfo = 
			[[[PortNumFieldEditInfo alloc] initWithEmailAcct:self.emailAccount] autorelease];
		[formPopulator.currentSection addFieldEditInfo:portNumFieldEditInfo];
	}
	
	[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_SETTINGS_SECTION")
		 andHelpFile:@"emailAcctDeleteSettings"];
	
	[formPopulator populateBoolFieldInParentObj:self.emailAccount 
		withBoolField:EMAIL_ACCOUNT_DELETE_HANDLING_DELETE_MSG_KEY 
		andFieldLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_MSGS_FIELD_LABEL") 
		andSubTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_MSGS_FIELD_SUBTITLE")];
		
	[formPopulator.currentSection addFieldEditInfo:
		[[[SyncFoldersFieldEditInfo alloc] initWithEmailAcct:self.emailAccount] autorelease]];
		
	if(TRUE)
	{
		// Setup editing for the 'Move to Folder' setting
		ManagedObjectFieldInfo *assignmentFieldInfo = [[[ManagedObjectFieldInfo alloc] 
			initWithManagedObject:self.emailAccount
			andFieldKey:EMAIL_ACCOUNT_DELETE_HANDLING_MOVE_TO_FOLDER_KEY 
			andFieldLabel:@"N/A"
			andFieldPlaceholder:@"N/A"] autorelease];
		assignmentFieldInfo.nilValueAssignmentOK = TRUE;

		MoveToFolderForDeletionFormInfoCreator *moveToFolderFormInfoCreator = 
				[[[MoveToFolderForDeletionFormInfoCreator alloc] initWithEmailAcct:self.emailAccount] autorelease];
		SelectableObjectTableViewControllerFactory *moveToFolderViewFactory = 
			[[[SelectableObjectTableViewControllerFactory alloc] initWithFormInfoCreator:moveToFolderFormInfoCreator 
				andAssignedField:assignmentFieldInfo] autorelease];
		moveToFolderViewFactory.closeAfterSelection = TRUE;
		moveToFolderViewFactory.supportsEditing = FALSE;
		
				
		NSString *moveToFolderDesc;
		if(self.emailAccount.deleteHandlingMoveToFolder == nil)
		{
			moveToFolderDesc = LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_NONE");
		}
		else 
		{
			moveToFolderDesc = self.emailAccount.deleteHandlingMoveToFolder.folderName;
		}
		
		StaticNavFieldEditInfo *moveToFolderFieldEditInfo = 
			[[[StaticNavFieldEditInfo alloc] 
				initWithCaption:LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_FIELD_CAPTION")
				andSubtitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_FIELD_SUBTITLE") 
				andContentDescription:moveToFolderDesc
				andSubViewFactory:moveToFolderViewFactory] autorelease];
		[formPopulator.currentSection addFieldEditInfo:moveToFolderFieldEditInfo];		
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
