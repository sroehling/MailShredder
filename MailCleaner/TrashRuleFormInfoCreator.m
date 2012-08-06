//
//  DeleteRuleFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrashRuleFormInfoCreator.h"

#import "LocalizationHelper.h"
#import "FormContext.h"
#import "FormInfo.h"
#import "FormPopulator.h"
#import "ManagedObjectFieldInfo.h"
#import "FromAddressFilter.h"
#import "RecipientAddressFilter.h"
#import "BoolFieldEditInfo.h"
#import "TrashRule.h"
#import "SectionInfo.h"
#import "MailCleanerFormPopulator.h"

@implementation TrashRuleFormInfoCreator

@synthesize rule;

-(id)initWithTrashRule:(TrashRule*)theRule
{
	self = [super init];
	if(self)
	{
		assert(theRule != nil);
		self.rule = theRule;
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
	
    formPopulator.formInfo.title = LOCALIZED_STR(@"TRASH_RULE_FORM_TITLE");

	[formPopulator nextSection];

	[formPopulator populateNameFieldInParentObj:self.rule withNameField:RULE_NAME_KEY 
	            andPlaceholder:LOCALIZED_STR(@"MESSAGE_RULE_NAME_PLACEHOLDER") 
				andMaxLength:RULE_NAME_MAX_LENGTH];

	[formPopulator nextSection];

	[formPopulator populateRuleEnabled:self.rule withSubtitle:LOCALIZED_STR(@"TRASH_RULE_ENABLED_SUBTITLE")];	

	[formPopulator nextSection];

	[formPopulator populateAgeFilterInParentObj:self.rule withAgeFilterPropertyKey:RULE_AGE_FILTER_KEY];

	[formPopulator populateEmailAddressFilter:self.rule.fromAddressFilter];
		
	[formPopulator populateEmailAddressFilter:self.rule.recipientAddressFilter];

	[formPopulator populateEmailDomainFilter:self.rule.emailDomainFilter];

	[formPopulator populateEmailFolderFilter:self.rule.folderFilter];

	
	return formPopulator.formInfo;
}

-(void)dealloc
{
	[rule release];
	[super dealloc];
}

@end
