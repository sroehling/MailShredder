//
//  EmailDomainSelectionFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailDomainSelectionFormInfoCreator.h"
#import "MailCleanerFormPopulator.h"
#import "LocalizationHelper.h"
#import "FormContext.h"
#import "EmailDomain.h"
#import "DataModelController.h"
#import "EmailDomainFilter.h"
#import "EmailDomainFieldEditInfo.h"
#import "SectionInfo.h"
#import "EmailDomainFilterDomainAdder.h"
#import "SharedAppVals.h"

@implementation EmailDomainSelectionFormInfoCreator

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
	
	formPopulator.formInfo.objectAdder = [[[EmailDomainFilterDomainAdder alloc] 
		initWithEmailDomainFilter:self.emailDomainFilter] autorelease];
		
	[formPopulator nextSection];
	
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:parentContext.dataModelController];
	NSPredicate *currentAcctPredicate = [NSPredicate predicateWithFormat:@"%K=%@",
		EMAIL_DOMAIN_ACCT_KEY,sharedVals.currentEmailAcct];

		
	NSArray *senderDomains = [parentContext.dataModelController 
		fetchObjectsForEntityName:EMAIL_DOMAIN_ENTITY_NAME andPredicate:currentAcctPredicate];
	for(EmailDomain *senderDomain in senderDomains)
	{
		// Only display the domain for selection if 
		// it is not already in the set of selected domains.
		if([self.emailDomainFilter.selectedDomains member:senderDomain] == nil)
		{
			EmailDomainFieldEditInfo *senderDomainFieldEditInfo = 
				[[[EmailDomainFieldEditInfo alloc] 
					initWithEmailDomain:senderDomain] autorelease];
			[formPopulator.currentSection addFieldEditInfo:senderDomainFieldEditInfo];
		}
	}

	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailDomainFilter release];
	[super dealloc];
}

@end
