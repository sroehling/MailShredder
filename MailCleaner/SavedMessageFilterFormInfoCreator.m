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
#import "MailCleanerFormPopulator.h"

@implementation SavedMessageFilterFormInfoCreator

@synthesize messageFilter;


-(id)initWithMessageFilter:(MessageFilter*)theMessageFilter
{
	self = [super init];
	if(self)
	{
		assert(theMessageFilter != nil);
		self.messageFilter = theMessageFilter;
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
	[super dealloc];
}


- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    MailCleanerFormPopulator *formPopulator = [[[MailCleanerFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
    formPopulator.formInfo.title = LOCALIZED_STR(@"MESSAGE_FILTER_TITLE");

	[formPopulator nextSection];

	[formPopulator populateNameFieldInParentObj:self.messageFilter withNameField:MESSAGE_FILTER_NAME_KEY 
	            andPlaceholder:LOCALIZED_STR(@"MESSAGE_RULE_NAME_PLACEHOLDER") 
				andMaxLength:MESSAGE_FILTER_NAME_MAX_LENGTH];

	[formPopulator nextSection];

	[formPopulator populateAgeFilterInParentObj:self.messageFilter withAgeFilterPropertyKey:MESSAGE_FILTER_AGE_FILTER_KEY];

	[formPopulator populateEmailAddressFilter:self.messageFilter.fromAddressFilter];
		
	[formPopulator populateEmailAddressFilter:self.messageFilter.recipientAddressFilter];

	[formPopulator populateEmailDomainFilter:self.messageFilter.emailDomainFilter];

	[formPopulator populateEmailFolderFilter:self.messageFilter.folderFilter];

	
	return formPopulator.formInfo;
}



@end
