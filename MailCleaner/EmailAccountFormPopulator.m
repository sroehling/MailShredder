//
//  EmailAccountFormPopulator.m
//
//  Created by Steve Roehling on 9/6/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "EmailAccountFormPopulator.h"
#import "LocalizationHelper.h"
#import "TextFieldValidator.h"
#import "RegExpTextFieldValidator.h"
#import "KeychainFieldInfo.h"
#import "EmailAccount.h"
#import "TextFieldEditInfo.h"
#import "SectionInfo.h"
#import "ManagedObjectFieldInfo.h"
#import "MoveToFolderForDeletionFormInfoCreator.h"
#import "SelectableObjectTableViewControllerFactory.h"
#import "StaticNavFieldEditInfo.h"
#import "EmailFolder.h"
#import "PortNumFieldEditInfo.h"
#import "SyncFoldersFieldEditInfo.h"
#import "ManagedObjectFieldInfo.h"
#import "NumberFieldEditInfo.h"
#import "NumberHelper.h"
#import "NumberPickerFieldEditInfo.h"

@implementation EmailAccountFormPopulator

-(void)populateEmailAccountNameField:(EmailAccount*)emailAccount
{
	[self populateNameFieldInParentObj:emailAccount 
		withNameField:EMAIL_ACCOUNT_NAME_KEY 
		andPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_NAME_PLACEHOLDER") 
		andMaxLength:EMAIL_ACCOUNT_NAME_MAX_LENGTH];
}

-(void)populatePasswordField:(EmailAccount*)emailAccount
{
	// User name regular expression is same as email, but optionally includes
	// the part after the @ character.
	NSString *passwordRegExPattern = @"^.+$";
	TextFieldValidator *passwordValidator = [[[RegExpTextFieldValidator alloc] 
		initWithValidationMsg:LOCALIZED_STR(@"EMAIL_ACCOUNT_PASSWORD_VALIDATION_MSG")
		andPattern:passwordRegExPattern] autorelease];
	KeychainFieldInfo *passwordFieldInfo = [emailAccount passwordFieldInfo];		
	TextFieldEditInfo *passwordFieldEditInfo = [[[TextFieldEditInfo alloc]
		initWithFieldInfo:passwordFieldInfo andValidator:passwordValidator 
		andSecureTextEntry:YES andAutoCorrection:UITextAutocorrectionTypeNo
		andAutoCapitalizationType:UITextAutocapitalizationTypeNone] autorelease];
		
	[self.currentSection addFieldEditInfo:passwordFieldEditInfo];
}

-(void)populateUserNameField:(EmailAccount*)emailAccount
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
		createForObject:emailAccount andKey:EMAIL_ACCOUNT_USERNAME_KEY 
		andLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_USERNAME_FIELD_LABEL") 
		andPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_USERNAME_PLACEHOLDER") 
		andValidator:userNameValidator andSecureTextEntry:NO 
		andAutoCorrectType:UITextAutocorrectionTypeNo
		andAutoCapitalizationType:UITextAutocapitalizationTypeNone];
	[self.currentSection addFieldEditInfo:userNameFieldEditInfo];

}

-(void)populateIMAPHostNameField:(EmailAccount*)emailAccount
{
	NSString *hostNameRegExpPattern = 
		@"^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9])(\\.([a-zA-Z0-9]|"
		@"[a-zA-Z0-9][a-zA-Z0-9\\-]{0,61}[a-zA-Z0-9]))*$";
	TextFieldValidator *hostnameValidator = [[[RegExpTextFieldValidator alloc] 
		initWithValidationMsg:LOCALIZED_STR(@"EMAIL_ACCOUNT_HOSTNAME_VALIDATION_MSG")
		andPattern:hostNameRegExpPattern] autorelease];
	TextFieldEditInfo *hostnameFieldEditInfo = [TextFieldEditInfo 
		createForObject:emailAccount andKey:EMAIL_ACCOUNT_IMAPSERVER_KEY 
		andLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_IMAP_SERVER_FIELD_LABEL") 
		andPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_IMAP_SERVER_PLACEHOLDER") 
		andValidator:hostnameValidator andSecureTextEntry:NO 
		andAutoCorrectType:UITextAutocorrectionTypeNo
		andAutoCapitalizationType:UITextAutocapitalizationTypeNone];
	[self.currentSection addFieldEditInfo:hostnameFieldEditInfo];
}

-(void)populateEmailAddressField:(EmailAccount*)emailAccount
{
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
		createForObject:emailAccount andKey:EMAIL_ACCOUNT_ADDRESS_KEY 
		andLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_ADDRESS_FIELD_LABEL") 
		andPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_ADDRESS_PLACEHOLDER") 
		andValidator:addressValidator andSecureTextEntry:NO 
		andAutoCorrectType:UITextAutocorrectionTypeNo
		andAutoCapitalizationType:UITextAutocapitalizationTypeNone];
	[self.currentSection addFieldEditInfo:emailAddrFieldEditInfo];

}


-(void)populateMoveToDeleteFolderSetting:(EmailAccount*)emailAccount
{
	// Setup editing for the 'Move to Folder' setting
	ManagedObjectFieldInfo *assignmentFieldInfo = [[[ManagedObjectFieldInfo alloc] 
		initWithManagedObject:emailAccount
		andFieldKey:EMAIL_ACCOUNT_DELETE_HANDLING_MOVE_TO_FOLDER_KEY 
		andFieldLabel:@"N/A"
		andFieldPlaceholder:@"N/A"] autorelease];
	assignmentFieldInfo.nilValueAssignmentOK = TRUE;

	MoveToFolderForDeletionFormInfoCreator *moveToFolderFormInfoCreator = 
			[[[MoveToFolderForDeletionFormInfoCreator alloc] initWithEmailAcct:emailAccount] autorelease];
	SelectableObjectTableViewControllerFactory *moveToFolderViewFactory = 
		[[[SelectableObjectTableViewControllerFactory alloc] initWithFormInfoCreator:moveToFolderFormInfoCreator 
			andAssignedField:assignmentFieldInfo] autorelease];
	moveToFolderViewFactory.closeAfterSelection = TRUE;
	moveToFolderViewFactory.supportsEditing = FALSE;
	
			
	NSString *moveToFolderDesc;
	if(emailAccount.deleteHandlingMoveToFolder == nil)
	{
		moveToFolderDesc = LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_NONE");
	}
	else 
	{
		moveToFolderDesc = emailAccount.deleteHandlingMoveToFolder.folderName;
	}
	
	StaticNavFieldEditInfo *moveToFolderFieldEditInfo = 
		[[[StaticNavFieldEditInfo alloc] 
			initWithCaption:LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_FIELD_CAPTION")
			andSubtitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_FIELD_SUBTITLE") 
			andContentDescription:moveToFolderDesc
			andSubViewFactory:moveToFolderViewFactory] autorelease];
	[self.currentSection addFieldEditInfo:moveToFolderFieldEditInfo];		
}

-(void)populateUseSSL:(EmailAccount*)emailAccount
{
	[self populateBoolFieldInParentObj:emailAccount withBoolField:EMAIL_ACCOUNT_USESSL_KEY 
		andFieldLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_USESSL_FIELD_TITLE") 
		andSubTitle:@""];
}

-(void)populateSyncOldMsgsFirst:(EmailAccount*)emailAccount
{
	[self populateBoolFieldInParentObj:emailAccount withBoolField:EMAIL_ACCOUNT_SYNC_OLD_MSGS_FIRST_KEY 
		andFieldLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_SYNC_OLD_MSGS_FIRST_FIELD_CAPTION") 
		andSubTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_SYNC_OLD_MSGS_FIRST_FIELD_SUBTITLE")];
}

-(void)populateMaxSyncMsgs:(EmailAccount*)emailAccount
{
    ManagedObjectFieldInfo *fieldInfo = [[[ManagedObjectFieldInfo alloc] 
              initWithManagedObject:emailAccount andFieldKey:EMAIL_ACCOUNT_MAX_SYNC_MSGS_KEY
			  andFieldLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_MAX_SYNC_MESSAGES_FIELD_LABEL")
			  andFieldPlaceholder:@"N/A"] autorelease];
			 
	NSArray *selectableMaxValues = [NSArray arrayWithObjects:
			[NSNumber numberWithUnsignedInteger:500],
			[NSNumber numberWithUnsignedInteger:1000],
			[NSNumber numberWithUnsignedInteger:2500],
			[NSNumber numberWithUnsignedInteger:5000],
			[NSNumber numberWithUnsignedInteger:EMAIL_ACCOUNT_DEFAULT_MAX_SYNC_MSGS],
			[NSNumber numberWithUnsignedInteger:25000],
		nil];
	
	NumberPickerFieldEditInfo *maxSyncMsgsFieldEditInfo = [[[NumberPickerFieldEditInfo alloc]
		initWithFieldInfo:fieldInfo andNumberVals:selectableMaxValues andTitle:
		LOCALIZED_STR(@"EMAIL_ACCOUNT_MAX_SYNC_MESSAGES_PICKER_TITLE")] autorelease];
		
	[self.currentSection addFieldEditInfo:maxSyncMsgsFieldEditInfo];
}

-(void)populatePortNumberField:(EmailAccount *)emailAccount
{
	PortNumFieldEditInfo *portNumFieldEditInfo = 
		[[[PortNumFieldEditInfo alloc] initWithEmailAcct:emailAccount] autorelease];
	[self.currentSection addFieldEditInfo:portNumFieldEditInfo];

}


-(void)populateDeleteMsgsField:(EmailAccount*)emailAccount
{
	[self populateBoolFieldInParentObj:emailAccount 
		withBoolField:EMAIL_ACCOUNT_DELETE_HANDLING_DELETE_MSG_KEY 
		andFieldLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_MSGS_FIELD_LABEL") 
		andSubTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_MSGS_FIELD_SUBTITLE")];
}

-(void)populateSyncFoldersField:(EmailAccount*)emailAccount
{
	[self.currentSection addFieldEditInfo:
		[[[SyncFoldersFieldEditInfo alloc] initWithEmailAcct:emailAccount] autorelease]];

}


@end
