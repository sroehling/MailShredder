//
//  MoveToFolderForDeletionFormInfoCreator.m
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MoveToFolderForDeletionFormInfoCreator.h"
#import "LocalizationHelper.h"
#import "VariableHeightTableHeader.h"
#import "MailCleanerFormPopulator.h"
#import "FormInfo.h"
#import "EmailAccount.h"
#import "EmailFolder.h"
#import "StaticFieldEditInfo.h"
#import "SectionInfo.h"
#import "MoveToFolderSelectionFieldEditInfo.h"
#import "StaticFieldEditInfo.h"
#import "DontMoveToFolderSelectionFieldEditInfo.h"

@implementation MoveToFolderForDeletionFormInfoCreator

@synthesize emailAcct;
@synthesize dontMoveFieldEditInfo;

-(id)initWithEmailAcct:(EmailAccount*)theAcct
{
	self = [super init];
	if(self)
	{
		self.emailAcct = theAcct;
		self.dontMoveFieldEditInfo = [[[DontMoveToFolderSelectionFieldEditInfo alloc] init] autorelease];
	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{

	MailCleanerFormPopulator *formPopulator = [[[MailCleanerFormPopulator alloc]
		initWithFormContext:parentContext] autorelease];

    formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_TABLE_LIST_TITLE");

	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_TABLE_HEADER_TITLE");
	tableHeader.subHeader.text = LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_TABLE_HEADER_SUBTITLE");
	[tableHeader resizeForChildren];
	formPopulator.formInfo.headerView = tableHeader;

	[formPopulator nextSection];

	[formPopulator.currentSection addFieldEditInfo:self.dontMoveFieldEditInfo];
			
	[formPopulator nextSectionWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_MOVE_TO_FOLDER_SECTION_HEADER")];
		
	for(EmailFolder *acctFolder in self.emailAcct.foldersInAcct)
	{
		[formPopulator.currentSection addFieldEditInfo:[[[MoveToFolderSelectionFieldEditInfo alloc] 
			initWithEmailFolder:acctFolder] autorelease]]; 
	}
			
	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailAcct release];
	[dontMoveFieldEditInfo release];
	[super dealloc];
}


@end
