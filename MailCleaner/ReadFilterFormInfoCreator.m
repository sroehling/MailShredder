//
//  ReadFilterFormInfoCreator.m
//
//  Created by Steve Roehling on 9/12/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "ReadFilterFormInfoCreator.h"
#import "SharedAppVals.h"
#import "FormPopulator.h"
#import "FormContext.h"
#import "ReadFilterFieldEditInfo.h"
#import "SectionInfo.h"
#import "LocalizationHelper.h"

@implementation ReadFilterFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
			
    formPopulator.formInfo.title = LOCALIZED_STR(@"MESSAGE_READ_FILTER_TITLE");
	
	[formPopulator nextSection];
	
	SharedAppVals *sharedAppVals = [SharedAppVals 
		getUsingDataModelController:parentContext.dataModelController];

	[formPopulator nextSection];
	
	[formPopulator.currentSection addFieldEditInfo:[[[ReadFilterFieldEditInfo alloc] 
		initWithReadFilter:sharedAppVals.defaultReadFilterReadOrUnread] autorelease]];
		
	[formPopulator.currentSection addFieldEditInfo:[[[ReadFilterFieldEditInfo alloc] 
		initWithReadFilter:sharedAppVals.defaultReadFilterRead] autorelease]];
		
	[formPopulator.currentSection addFieldEditInfo:[[[ReadFilterFieldEditInfo alloc] 
		initWithReadFilter:sharedAppVals.defaultReadFilterUnread] autorelease]];
			
	return formPopulator.formInfo;
}

@end
