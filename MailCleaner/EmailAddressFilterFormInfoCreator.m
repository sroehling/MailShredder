//
//  EmailAddressFilterFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddressFilterFormInfoCreator.h"

#import "FormInfoCreator.h"
#import "MailCleanerFormPopulator.h"
#import "HelpPagePopoverCaptionInfo.h"
#import "FormContext.h"
#import "LocalizationHelper.h"
#import "EmailAddressFilterAddressAdder.h"
#import "EmailAddressFilter.h"
#import "DataModelController.h"
#import "EmailAddress.h"
#import "EmailAddressFieldEditInfo.h"
#import "SectionInfo.h"
#import "VariableHeightTableHeader.h"

@implementation EmailAddressFilterFormInfoCreator

@synthesize emailAddressFilter;

-(id)initWithEmailAddressFilter:(EmailAddressFilter*)theEmailAddrFilter
{
	self = [super init];
	if(self)
	{
		assert(theEmailAddrFilter != nil);
		self.emailAddressFilter = theEmailAddrFilter;
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

    formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_ADDRESS_LIST_TITLE");

	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_TABLE_HEADER_TITLE");
	tableHeader.subHeader.text = LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_TABLE_HEADER_SUBTITLE");
	[tableHeader resizeForChildren];
	formPopulator.formInfo.headerView = tableHeader;


	
	formPopulator.formInfo.objectAdder = [[[EmailAddressFilterAddressAdder alloc] 
		initWithEmailAddressFilter:self.emailAddressFilter] autorelease];
		
	[formPopulator nextSection];
		
	NSSet *senderAddresses = self.emailAddressFilter.selectedAddresses;
	for(EmailAddress *senderAddress in senderAddresses)
	{
		EmailAddressFieldEditInfo *senderAddrFieldEditInfo = 
			[[[EmailAddressFieldEditInfo alloc] 
				initWithEmailAddress:senderAddress] autorelease];
		senderAddrFieldEditInfo.parentFilter = self.emailAddressFilter;
		[formPopulator.currentSection addFieldEditInfo:senderAddrFieldEditInfo];
	}

			
	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailAddressFilter release];
	[super dealloc];
}

@end
