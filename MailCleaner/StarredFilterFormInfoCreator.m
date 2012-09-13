//
//  StarredFilterFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StarredFilterFormInfoCreator.h"

#import "SharedAppVals.h"
#import "FormPopulator.h"
#import "FormContext.h"
#import "StarredFilterFieldEditInfo.h"
#import "SectionInfo.h"
#import "LocalizationHelper.h"


@implementation StarredFilterFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
			
    formPopulator.formInfo.title = LOCALIZED_STR(@"MESSAGE_READ_FILTER_TITLE");
	
	[formPopulator nextSection];
	
	SharedAppVals *sharedAppVals = [SharedAppVals 
		getUsingDataModelController:parentContext.dataModelController];

	[formPopulator nextSection];
	
	[formPopulator.currentSection addFieldEditInfo:[[[StarredFilterFieldEditInfo alloc] 
		initWithStarredFilter:sharedAppVals.defaultStarredFilterStarredOrUnstarred] autorelease]];
		
	[formPopulator.currentSection addFieldEditInfo:[[[StarredFilterFieldEditInfo alloc] 
		initWithStarredFilter:sharedAppVals.defaultStarredFilterStarred] autorelease]];
		
	[formPopulator.currentSection addFieldEditInfo:[[[StarredFilterFieldEditInfo alloc] 
		initWithStarredFilter:sharedAppVals.defaultStarredFilterUnstarred] autorelease]];

			
	return formPopulator.formInfo;
}


@end
