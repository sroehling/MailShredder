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

	[formPopulator populateRuleEnabled:self.rule withSubtitle:LOCALIZED_STR(@"TRASH_RULE_ENABLED_SUBTITLE")];	

	[formPopulator nextSection];

	[formPopulator populateAgeFilterInParentObj:self.rule withAgeFilterPropertyKey:RULE_AGE_FILTER_KEY];

	[formPopulator populateEmailAddressFilter:self.rule.emailAddressFilter];

	
	return formPopulator.formInfo;
}

-(void)dealloc
{
	[rule release];
	[super dealloc];
}

@end
