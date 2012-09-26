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
#import "SharedAppVals.h"
#import "CollectionHelper.h"

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

-(NSString*)emailAddressSectionName:(EmailAddress*)theAddress
{
	NSString *nameOrAddr = theAddress.nameOrAddress;
	
	if(nameOrAddr.length > 1)
	{
		// Skip the @ sign
		return [nameOrAddr substringWithRange:NSMakeRange(1, 1)];
	}
	else
	{
		return @"";
	}
}

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{

	MailCleanerFormPopulator *formPopulator = [[[MailCleanerFormPopulator alloc]
		initWithFormContext:parentContext] autorelease];

    formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_ADDRESS_LIST_TITLE");
	
	formPopulator.formInfo.objectAdder = [[[EmailAddressFilterAddressAdder alloc] 
		initWithEmailAddressFilter:self.emailAddressFilter] autorelease];
		
	
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:parentContext.dataModelController];
	NSPredicate *currentAcctPredicate = [NSPredicate predicateWithFormat:@"%K=%@",
		EMAIL_ADDRESS_ACCT_KEY,sharedVals.currentEmailAcct];
		
	NSArray *senderAddresses = [parentContext.dataModelController 
		fetchObjectsForEntityName:EMAIL_ADDRESS_ENTITY_NAME andPredicate:currentAcctPredicate];
		
	// Sort the addresses - If the email address is accompanied by a name, use the name;
	// otherwise, use the characters in the email address.
	NSArray *sortedAddresses = [CollectionHelper sortArray:senderAddresses
			withKey:EMAIL_ADDRESS_NAME_OR_ADDRESS_KEY andAscending:TRUE];
	
	NSMutableArray *sectionIndices = [[[NSMutableArray alloc] init]autorelease];
	
	NSString *currentSectionName = nil;
	
	for(EmailAddress *senderAddress in sortedAddresses)
	{
		// Only display the address for selection if
		// it is not already in the set of selected addresses.
		NSString *emailAddrSectionName = [self emailAddressSectionName:senderAddress];
		if(	(currentSectionName == nil)||
			(![currentSectionName isEqualToString:emailAddrSectionName]))
		{
			currentSectionName = emailAddrSectionName;
			[sectionIndices addObject:currentSectionName];
			[formPopulator nextSectionWithTitle:currentSectionName];
		}
		
		if([self.emailAddressFilter.selectedAddresses member:senderAddress] == nil)
		{
			EmailAddressFieldEditInfo *senderAddrFieldEditInfo = 
				[[[EmailAddressFieldEditInfo alloc] 
					initWithEmailAddress:senderAddress] autorelease];
			[formPopulator.currentSection addFieldEditInfo:senderAddrFieldEditInfo];
		}
	}
	
	formPopulator.formInfo.sectionIndices = sectionIndices;

			
	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailAddressFilter release];
	[super dealloc];
}

@end
