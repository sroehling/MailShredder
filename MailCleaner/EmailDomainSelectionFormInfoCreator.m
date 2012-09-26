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
#import "CollectionHelper.h"

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

-(NSString*)domainSectionName:(EmailDomain*)domain
{
	NSString *sectionName = [domain.domainName substringToIndex:1];
	return [sectionName uppercaseString];
}

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{

	MailCleanerFormPopulator *formPopulator = [[[MailCleanerFormPopulator alloc]
		initWithFormContext:parentContext] autorelease];

    formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_DOMAIN_LIST_TITLE");
	
	formPopulator.formInfo.objectAdder = [[[EmailDomainFilterDomainAdder alloc] 
		initWithEmailDomainFilter:self.emailDomainFilter] autorelease];
		
	
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:parentContext.dataModelController];
	NSPredicate *currentAcctPredicate = [NSPredicate predicateWithFormat:@"%K=%@",
		EMAIL_DOMAIN_ACCT_KEY,sharedVals.currentEmailAcct];


	NSString *currentSectionName = nil;


	NSMutableArray *sectionIndices = [[[NSMutableArray alloc] init] autorelease];
		
	NSArray *senderDomains = [parentContext.dataModelController 
		fetchObjectsForEntityName:EMAIL_DOMAIN_ENTITY_NAME andPredicate:currentAcctPredicate];
		
	NSArray *sortedDomains = [CollectionHelper sortArray:senderDomains withKey:EMAIL_DOMAIN_NAME_KEY andAscending:TRUE];
		
	for(EmailDomain *senderDomain in sortedDomains)
	{
		NSString *domainSectionName = [self domainSectionName:senderDomain];
		if((currentSectionName == nil) ||
		   (![currentSectionName isEqualToString:domainSectionName]))
		{
			currentSectionName = domainSectionName;
			[formPopulator nextSectionWithTitle:currentSectionName];
			[sectionIndices addObject:currentSectionName];
			
		}
	
	
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

	formPopulator.formInfo.sectionIndices = sectionIndices;

	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailDomainFilter release];
	[super dealloc];
}

@end
