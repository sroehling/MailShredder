//
//  EmailAddressSelectionFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddressSelectionFormInfoCreator.h"

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
#import "FormInfo.h"

@implementation EmailAddressSelectionFormInfoCreator

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
	
	formPopulator.formInfo.objectAdder = [[[EmailAddressFilterAddressAdder alloc] 
		initWithEmailAddressFilter:self.emailAddressFilter] autorelease];
		
	[formPopulator nextSection];
		
	NSSet *senderAddresses = [parentContext.dataModelController 
		fetchObjectsForEntityName:EMAIL_ADDRESS_ENTITY_NAME];
	for(EmailAddress *senderAddress in senderAddresses)
	{
		// Only display the address for selection if 
		// it is not already in the set of selected addresses.
		if([self.emailAddressFilter.selectedAddresses member:senderAddress] == nil)
		{
			EmailAddressFieldEditInfo *senderAddrFieldEditInfo = 
				[[[EmailAddressFieldEditInfo alloc] 
					initWithEmailAddress:senderAddress] autorelease];
			[formPopulator.currentSection addFieldEditInfo:senderAddrFieldEditInfo];
		}
	}

			
	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailAddressFilter release];
	[super dealloc];
}

@end
