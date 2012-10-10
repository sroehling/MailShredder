//
//  RulesFormInfoCreator.m
//
//  Created by Steve Roehling on 5/30/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "SavedMessageFilterListFormInfoCreator.h"
#import "LocalizationHelper.h"
#import "FormPopulator.h"
#import "FormContext.h"
#import "DataModelController.h"
#import "StaticNavFieldEditInfo.h"
#import "SectionInfo.h"
#import "SharedAppVals.h"
#import "MsgPredicateHelper.h"
#import "MessageFilter.h"
#import "EmailAccount.h"
#import "SavedMessageFilterFormInfoCreator.h"
#import "StaticNavFieldEditInfo.h"
#import "GenericFieldBasedTableEditViewControllerFactory.h"
#import "MessageFilterObjectAdder.h"
#import "CollectionHelper.h"

@implementation SavedMessageFilterListFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
    formPopulator.formInfo.title = LOCALIZED_STR(@"SAVED_MESSAGE_FILTER_VIEW_TITLE");
	
	formPopulator.formInfo.objectAdder = [[[MessageFilterObjectAdder alloc] init] autorelease];
		
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:parentContext.dataModelController];
	if([sharedVals.currentEmailAcct.savedMsgListFilters count] > 0)
	{
		[formPopulator nextSection];

		NSArray *sortedFilters = [CollectionHelper setToSortedArray:sharedVals.currentEmailAcct.savedMsgListFilters 
				withKey:MESSAGE_FILTER_NAME_KEY];

		for(MessageFilter *savedFilter in sortedFilters)
		{
			SavedMessageFilterFormInfoCreator *savedFilterFormCreator = 
				[[[SavedMessageFilterFormInfoCreator alloc] initWithEmailAcct:sharedVals.currentEmailAcct
				andMessageFilter:savedFilter] autorelease];
			GenericFieldBasedTableEditViewControllerFactory *filterEditViewControllerFactory
				= [[[GenericFieldBasedTableEditViewControllerFactory alloc] initWithFormInfoCreator:savedFilterFormCreator] autorelease];
			NSString *filterSynopsis = savedFilter.filterSynopsis;
			StaticNavFieldEditInfo *filterFieldEditInfo = 
				[[[StaticNavFieldEditInfo alloc] initWithCaption:savedFilter.filterName andSubtitle:filterSynopsis 
					andContentDescription:nil andSubViewFactory:filterEditViewControllerFactory] autorelease];
			filterFieldEditInfo.objectForDelete = savedFilter;
			[formPopulator.currentSection addFieldEditInfo:filterFieldEditInfo];
		}
		
	}

	return formPopulator.formInfo;

}


@end
