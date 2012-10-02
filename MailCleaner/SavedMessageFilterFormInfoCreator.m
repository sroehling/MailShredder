//
//  DeleteRuleFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SavedMessageFilterFormInfoCreator.h"

#import "LocalizationHelper.h"
#import "FormContext.h"
#import "FormInfo.h"
#import "FormPopulator.h"
#import "ManagedObjectFieldInfo.h"
#import "FromAddressFilter.h"
#import "RecipientAddressFilter.h"
#import "BoolFieldEditInfo.h"
#import "MessageFilter.h"
#import "SectionInfo.h"
#import "EmailAccount.h"
#import "MailCleanerFormPopulator.h"
#import "FilterNameFieldValidator.h"
#import "SenderDomainFilter.h"

@implementation SavedMessageFilterFormInfoCreator

@synthesize messageFilter;
@synthesize emailAccount;


-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct 
	andMessageFilter:(MessageFilter*)theMessageFilter
{
	self = [super init];
	if(self)
	{
		assert(theMessageFilter != nil);
		self.messageFilter = theMessageFilter;
		
		assert(theEmailAcct != nil);
		self.emailAccount = theEmailAcct;
	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}

-(void)dealloc
{
	[messageFilter release];
	[emailAccount release];
	[super dealloc];
}


- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    MailCleanerFormPopulator *formPopulator = [[[MailCleanerFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
    formPopulator.formInfo.title = LOCALIZED_STR(@"MESSAGE_FILTER_TITLE");

	[formPopulator nextSection];

	FilterNameFieldValidator *filterNameValidator = [[[FilterNameFieldValidator alloc] 
			initWithEmailAcct:self.emailAccount andMessageFilter:self.messageFilter] autorelease];

	[formPopulator populateNameFieldInParentObj:self.messageFilter withNameField:MESSAGE_FILTER_NAME_KEY 
	            andPlaceholder:LOCALIZED_STR(@"MESSAGE_RULE_NAME_PLACEHOLDER") 
				andMaxLength:MESSAGE_FILTER_NAME_MAX_LENGTH
				andCustomValidator:filterNameValidator];

	[formPopulator nextSection];

	[formPopulator populateAgeFilterInParentObj:self.messageFilter withAgeFilterPropertyKey:MESSAGE_FILTER_AGE_FILTER_KEY];

	[formPopulator populateEmailAddressFilter:self.messageFilter.fromAddressFilter
		andDoSelectRecipients:FALSE andDoSelectSenders:TRUE];
		
	[formPopulator populateEmailAddressFilter:self.messageFilter.recipientAddressFilter
		andDoSelectRecipients:TRUE andDoSelectSenders:FALSE];

	[formPopulator populateEmailDomainFilter:self.messageFilter.senderDomainFilter];

	[formPopulator populateEmailFolderFilter:self.messageFilter.folderFilter];
	
	[formPopulator populateSubjectFilter:self.messageFilter.subjectFilter];

	[formPopulator populateReadFilterInParentObj:self.messageFilter 
		withReadFilterPropertyKey:MESSAGE_FILTER_READ_FILTER_KEY];

	[formPopulator populateStarredFilterInParentObj:self.messageFilter 
		withStarredFilterPropertyKey:MESSAGE_FILTER_STARRED_FILTER_KEY];
	
	return formPopulator.formInfo;
}



@end
