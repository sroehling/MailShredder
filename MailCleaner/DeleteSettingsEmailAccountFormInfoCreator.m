//
//  DeleteSettingsEmailAccountFormInfoCreator.m
//
//  Created by Steve Roehling on 9/7/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "DeleteSettingsEmailAccountFormInfoCreator.h"
#import "EmailAccountFormPopulator.h"
#import "LocalizationHelper.h"
#import "FormContext.h"

@implementation DeleteSettingsEmailAccountFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    EmailAccountFormPopulator *formPopulator = [[[EmailAccountFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_VIEW_TITLE");
	[formPopulator populateWithHeader:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_SETTINGS_SECTION_HEADER") 
		andSubHeader:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_SETTINGS_TABLE_SUBHEADER") 
		andHelpFile:@"emailAcctDeleteSettings" 
		andParentController:parentContext.parentController];
	
	[formPopulator nextSection];
	[formPopulator populateSyncFoldersField:self.emailAccount]; 
	[formPopulator populateMoveToDeleteFolderSetting:self.emailAccount];
	[formPopulator populateDeleteMsgsField:self.emailAccount];

	return formPopulator.formInfo;

}



@end
