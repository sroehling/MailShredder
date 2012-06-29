//
//  EmailFolderFilterFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailFolderFilterFormInfoCreator.h"
#import "MailCleanerFormPopulator.h"
#import "LocalizationHelper.h"
#import "VariableHeightTableHeader.h"
#import "EmailFolderFilterFolderAdder.h"
#import "EmailFolderFilter.h"
#import "EmailFolderFieldEditInfo.h"
#import "SectionInfo.h"

@implementation EmailFolderFilterFormInfoCreator


@synthesize emailFolderFilter;

-(id)initWithEmailFolderFilter:(EmailFolderFilter*)theEmailFolderFilter
{
	self = [super init];
	if(self)
	{
		assert(theEmailFolderFilter != nil);
		self.emailFolderFilter = theEmailFolderFilter;
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

    formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_DOMAIN_LIST_TITLE");

	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_TABLE_HEADER_TITLE");
	tableHeader.subHeader.text = LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_TABLE_HEADER_SUBTITLE");
	[tableHeader resizeForChildren];
	formPopulator.formInfo.headerView = tableHeader;


	formPopulator.formInfo.objectAdder = [[[EmailFolderFilterFolderAdder alloc] 
		initWithEmailFolderFilter:self.emailFolderFilter] autorelease];
		
	[formPopulator nextSection];
		
	NSSet *folders = self.emailFolderFilter.selectedFolders;
	for(EmailFolder *folder in folders)
	{
		EmailFolderFieldEditInfo *folderFieldEditInfo = 
			[[[EmailFolderFieldEditInfo alloc] 
				initWithEmailFolder:folder] autorelease];
		folderFieldEditInfo.parentFilter = self.emailFolderFilter;
		[formPopulator.currentSection addFieldEditInfo:folderFieldEditInfo];
	}

			
	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailFolderFilter release];
	[super dealloc];
}

@end
