//
//  MessageFilterFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilterFormInfoCreator.h"
#import "MessageFilter.h"
#import "LocalizationHelper.h"
#import "FormPopulator.h"
#import "StaticNavFieldEditInfo.h"
#import "SectionInfo.h"
#import "SelectableObjectTableViewControllerFactory.h"
#import "AgeFilterFormInfoCreator.h"
#import "ManagedObjectFieldInfo.h"
#import "AgeFilter.h"
#import "MailCleanerFormPopulator.h"

@implementation MessageFilterFormInfoCreator

@synthesize msgFilter;

-(id)initWithMsgFilter:(MessageFilter *)theMsgFilter
{
	self = [super init];
	if(self)
	{
		assert(theMsgFilter != nil);
		self.msgFilter = theMsgFilter;

	}
	return self;
}


- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    MailCleanerFormPopulator *formPopulator = [[[MailCleanerFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
			
    formPopulator.formInfo.title = LOCALIZED_STR(@"MESSAGE_FILTER_TITLE");
	
	[formPopulator nextSection];
	
	[formPopulator populateAgeFilterInParentObj:self.msgFilter 
		withAgeFilterPropertyKey:MESSAGE_FILTER_AGE_FILTER_KEY];
			
	return formPopulator.formInfo;
}


-(void)dealloc
{
	[msgFilter release];
	[super dealloc];
}


@end
