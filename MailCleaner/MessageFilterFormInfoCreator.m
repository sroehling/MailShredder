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
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
			
    formPopulator.formInfo.title = LOCALIZED_STR(@"MESSAGE_FILTER_TITLE");
	
	[formPopulator nextSection];
	
	ManagedObjectFieldInfo *assignmentFieldInfo = [[[ManagedObjectFieldInfo alloc] 
		initWithManagedObject:self.msgFilter
		andFieldKey:MESSAGE_FILTER_AGE_FILTER_KEY 
		andFieldLabel:LOCALIZED_STR(@"MESSAGE_AGE_TITLE")
		andFieldPlaceholder:LOCALIZED_STR(@"MESSAGE_AGE_FILTER_PROMPT")] autorelease];

	
	AgeFilterFormInfoCreator *ageFilterFormInfoCreator = 
		[[[AgeFilterFormInfoCreator alloc] init] autorelease];
	
	SelectableObjectTableViewControllerFactory *ageFilterViewFactory = 
		[[[SelectableObjectTableViewControllerFactory alloc] initWithFormInfoCreator:ageFilterFormInfoCreator 
			andAssignedField:assignmentFieldInfo] autorelease];
	ageFilterViewFactory.closeAfterSelection = TRUE;
			
	
	StaticNavFieldEditInfo *messageAgeFieldEditInfo = 
		[[[StaticNavFieldEditInfo alloc] 
			initWithCaption:LOCALIZED_STR(@"MESSAGE_AGE_TITLE")
			andSubtitle:LOCALIZED_STR(@"MESSAGE_AGE_SUBTITLE") 
			andContentDescription:[self.msgFilter.ageFilter filterSynopsis]
			andSubViewFactory:ageFilterViewFactory] autorelease];
	[formPopulator.currentSection addFieldEditInfo:messageAgeFieldEditInfo];		

			
	return formPopulator.formInfo;
}


-(void)dealloc
{
	[msgFilter release];
	[super dealloc];
}


@end
