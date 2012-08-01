//
//  EmailDomainFilterFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailDomainFilterFormInfoCreator.h"

#import "FormInfoCreator.h"
#import "MailCleanerFormPopulator.h"
#import "HelpPagePopoverCaptionInfo.h"
#import "FormContext.h"
#import "LocalizationHelper.h"
#import "EmailDomainFilterDomainAdder.h"
#import "EmailDomainFilter.h"
#import "DataModelController.h"
#import "EmailDomain.h"
#import "EmailDomainFieldEditInfo.h"
#import "SectionInfo.h"
#import "VariableHeightTableHeader.h"

@implementation EmailDomainFilterFormInfoCreator


@synthesize emailDomainFilter;

-(id)initWithEmailDomainFilter:(EmailDomainFilter*)theEmailDomainFilter
{
	self = [super init];
	if(self)
	{
		assert(theEmailDomainFilter != nil);
		self.emailDomainFilter = theEmailDomainFilter;
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

    formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_DOMAIN_LIST_TITLE");

	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_TABLE_HEADER_TITLE");
	tableHeader.subHeader.text = LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_TABLE_HEADER_SUBTITLE");
	[tableHeader resizeForChildren];
	formPopulator.formInfo.headerView = tableHeader;

	formPopulator.formInfo.objectAdder = [[[EmailDomainFilterDomainAdder alloc] 
		initWithEmailDomainFilter:self.emailDomainFilter] autorelease];		
		
	NSSet *senderDomains = self.emailDomainFilter.selectedDomains;
	if([senderDomains count] > 0)
	{
		[formPopulator nextSectionWithTitle:
				LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_ADDRESS_LIST_SECTION_TITLE")];
			
		for(EmailDomain *senderDomain in senderDomains)
		{
			EmailDomainFieldEditInfo *senderDomainFieldEditInfo = 
				[[[EmailDomainFieldEditInfo alloc] 
					initWithEmailDomain:senderDomain] autorelease];
			senderDomainFieldEditInfo.parentFilter = self.emailDomainFilter;
			[formPopulator.currentSection addFieldEditInfo:senderDomainFieldEditInfo];
		}

		[formPopulator nextSection];
		
		[formPopulator populateBoolFieldInParentObj:self.emailDomainFilter 
			withBoolField:EMAIL_DOMAIN_FILTER_MATCH_UNSELECTED_KEY 
			andFieldLabel:LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_MATCH_UNSELECTED_FIELD_LABEL") 
			andSubTitle:LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_MATCH_UNSELECTED_FIELD_SUBTITLE")];


	}
		

			
	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailDomainFilter release];
	[super dealloc];
}

@end
