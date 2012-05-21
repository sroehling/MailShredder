//
//  AgeFilterFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AgeFilterFormInfoCreator.h"
#import "LocalizationHelper.h"
#import "FormPopulator.h"
#import "StaticFieldEditInfo.h"
#import "SharedAppVals.h"
#import "FormContext.h"
#import "AgeFilterNone.h"
#import "SectionInfo.h"
#import "AgeFilterFieldEditInfo.h"
#import "AgeFilterComparison.h"

@implementation AgeFilterFormInfoCreator

-(AgeFilterFieldEditInfo*)fieldEditInfoForAgeFilter:(AgeFilter*)theAgeFilter
{
	assert(theAgeFilter != nil);
	AgeFilterFieldEditInfo *ageFilterNoneFieldEditInfo = [[[AgeFilterFieldEditInfo alloc] 
		initWithAgeFilter:theAgeFilter 
		andCaption:theAgeFilter.filterSynopsis 
		andContent:nil andSubtitle:nil] autorelease];
	return ageFilterNoneFieldEditInfo;

}

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
			
    formPopulator.formInfo.title = LOCALIZED_STR(@"MESSAGE_AGE_TITLE");
	
	[formPopulator nextSection];
	
	SharedAppVals *sharedAppVals = [SharedAppVals 
		getUsingDataModelController:parentContext.dataModelController];
	
	AgeFilterFieldEditInfo *ageFilterNoneFieldEditInfo = [[[AgeFilterFieldEditInfo alloc] 
		initWithAgeFilter:sharedAppVals.defaultAgeFilterNone 
		andCaption:LOCALIZED_STR(@"AGE_FILTER_NONE_TITLE") 
		andContent:nil
		andSubtitle:LOCALIZED_STR(@"AGE_FILTER_NONE_SUBTITLE")] autorelease];
	[formPopulator.currentSection addFieldEditInfo:ageFilterNoneFieldEditInfo];

	[formPopulator nextSection];

	[formPopulator.currentSection addFieldEditInfo:
		[self fieldEditInfoForAgeFilter:sharedAppVals.defaultAgeFilterOlder1Month]];
	[formPopulator.currentSection addFieldEditInfo:
		[self fieldEditInfoForAgeFilter:sharedAppVals.defaultAgeFilterOlder3Months]];
	[formPopulator.currentSection addFieldEditInfo:
		[self fieldEditInfoForAgeFilter:sharedAppVals.defaultAgeFilterOlder6Months]];
	[formPopulator.currentSection addFieldEditInfo:
		[self fieldEditInfoForAgeFilter:sharedAppVals.defaultAgeFilterOlder1Year]];
	[formPopulator.currentSection addFieldEditInfo:
		[self fieldEditInfoForAgeFilter:sharedAppVals.defaultAgeFilterOlder2Years]];


	[formPopulator nextSection];

	[formPopulator.currentSection addFieldEditInfo:
		[self fieldEditInfoForAgeFilter:sharedAppVals.defaultAgeFilterNewer1Month]];
	[formPopulator.currentSection addFieldEditInfo:
		[self fieldEditInfoForAgeFilter:sharedAppVals.defaultAgeFilterNewer3Months]];
	[formPopulator.currentSection addFieldEditInfo:
		[self fieldEditInfoForAgeFilter:sharedAppVals.defaultAgeFilterNewer6Months]];
	[formPopulator.currentSection addFieldEditInfo:
		[self fieldEditInfoForAgeFilter:sharedAppVals.defaultAgeFilterNewer1Year]];

			
	return formPopulator.formInfo;
}


@end
