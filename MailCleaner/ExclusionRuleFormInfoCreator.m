//
//  ExclusionRuleFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExclusionRuleFormInfoCreator.h"
#import "LocalizationHelper.h"
#import "FormContext.h"
#import "FormInfo.h"
#import "FormPopulator.h"
#import "ManagedObjectFieldInfo.h"
#import "BoolFieldEditInfo.h"
#import "ExclusionRule.h"
#import "SectionInfo.h"
#import "MailCleanerFormPopulator.h"

@implementation ExclusionRuleFormInfoCreator

@synthesize rule;

-(id)initWithExclusionRule:(ExclusionRule*)theRule
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
	
    formPopulator.formInfo.title = LOCALIZED_STR(@"EXCLUSION_RULE_FORM_TITLE");
	
	[formPopulator nextSection];

	[formPopulator populateRuleEnabled:self.rule withSubtitle:LOCALIZED_STR(@"EXCLUSION_RULE_ENABLED_SUBTITLE")];	

	[formPopulator nextSection];

	[formPopulator populateAgeFilterInParentObj:self.rule withAgeFilterPropertyKey:RULE_AGE_FILTER_KEY];
	
	[formPopulator populateEmailAddressFilter:self.rule.emailAddressFilter];

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
