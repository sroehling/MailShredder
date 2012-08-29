//
//  SyncFoldersFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SyncFoldersFormInfoCreator.h"

#import "FormInfo.h"
#import "FormContext.h"
#import "MailCleanerFormPopulator.h"
#import "LocalizationHelper.h"
#import "VariableHeightTableHeader.h"
#import "EmailAccount.h"
#import "SectionInfo.h"
#import "SyncFolderSelectionFieldEditInfo.h"
#import "StaticFieldEditInfo.h"

@implementation SyncFoldersFormInfoCreator

@synthesize emailAcct;

-(id)initWithEmailAcct:(EmailAccount*)theAcct
{
	self = [super init];
	if(self)
	{
		self.emailAcct = theAcct;
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

    formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_SYNC_FOLDER_LIST_TITLE");

	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = LOCALIZED_STR(@"EMAIL_ACCOUNT_SYNC_FOLDER_TABLE_HEADER_TITLE");
	tableHeader.subHeader.text = LOCALIZED_STR(@"EMAIL_ACCOUNT_SYNC_FOLDER_TABLE_HEADER_SUBTITLE");
	[tableHeader resizeForChildren];
	formPopulator.formInfo.headerView = tableHeader;
	
	formPopulator.formInfo.objectAdder = nil; // TBD - Set with adder for synchronization folders
		
	[formPopulator nextSection];
		
	for(EmailFolder *acctFolder in self.emailAcct.foldersInAcct)
	{
		[formPopulator.currentSection addFieldEditInfo:
			[[[SyncFolderSelectionFieldEditInfo alloc] 
			initWithEmailAcct:self.emailAcct andFolder:acctFolder] autorelease]]; 
	}
			
			
	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailAcct release];
	[super dealloc];
}


@end
