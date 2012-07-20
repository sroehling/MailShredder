//
//  MessageFilterFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilterFormInfoCreator.h"
#import "MessageFilter.h"
#import "LocalizationHelper.h"
#import "FormPopulator.h"
#import "StaticNavFieldEditInfo.h"
#import "SectionInfo.h"
#import "SelectableObjectTableViewControllerFactory.h"
#import "AgeFilterFormInfoCreator.h"
#import "ManagedObjectFieldInfo.h"
#import "AgeFilter.h"
#import "MailCleanerFormPopulator.h"
#import "FormContext.h"
#import "VariableHeightTableHeader.h"
#import "MessageFilterTableFooterController.h"


@implementation MessageFilterFormInfoCreator

@synthesize msgFilter;

-(id)initWithMsgFilter:(MessageFilter *)theMsgFilter
{
	self = [super init];
	if(self)
	{
		assert(theMsgFilter != nil);
		self.msgFilter = theMsgFilter;

	}
	return self;
}


- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    MailCleanerFormPopulator *formPopulator = [[[MailCleanerFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
			
    formPopulator.formInfo.title = LOCALIZED_STR(@"MESSAGE_FILTER_TITLE");
	
	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = @"";
	tableHeader.subHeader.text = LOCALIZED_STR(@"MESSAGE_FILTER_FORM_SUBHEADER_TEXT");
	[tableHeader resizeForChildren];
	formPopulator.formInfo.headerView = tableHeader;
	
	[formPopulator nextSection];
	
	[formPopulator populateAgeFilterInParentObj:self.msgFilter 
		withAgeFilterPropertyKey:MESSAGE_FILTER_AGE_FILTER_KEY];
		
	[formPopulator populateEmailAddressFilter:self.msgFilter.emailAddressFilter];

	[formPopulator populateEmailDomainFilter:self.msgFilter.emailDomainFilter];

	[formPopulator populateEmailFolderFilter:self.msgFilter.folderFilter];
	 
	formPopulator.formInfo.footerController = 
		[[[MessageFilterTableFooterController alloc] initWithMessageFilter:self.msgFilter 
			andFilterDataModelController:parentContext.dataModelController] autorelease];
	
	return formPopulator.formInfo;
}


-(void)dealloc
{
	[msgFilter release];
	[super dealloc];
}


@end
