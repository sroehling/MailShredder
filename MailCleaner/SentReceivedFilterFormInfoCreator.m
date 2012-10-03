//
//  SentReceivedFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 10/3/12.
//
//

#import "SentReceivedFilterFormInfoCreator.h"
#import "FormPopulator.h"
#import "FormContext.h"
#import "SharedAppVals.h"
#import "LocalizationHelper.h"
#import "SectionInfo.h"
#import "SentReceivedFilterFieldEditInfo.h"

@implementation SentReceivedFilterFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
			
    formPopulator.formInfo.title = LOCALIZED_STR(@"SENT_RECEIVED_FILTER_TITLE");
	
	[formPopulator nextSection];
	
	SharedAppVals *sharedAppVals = [SharedAppVals 
		getUsingDataModelController:parentContext.dataModelController];

	[formPopulator nextSection];
	
	[formPopulator.currentSection addFieldEditInfo:[[[SentReceivedFilterFieldEditInfo alloc] 
		initWithSentReceivedFilter:sharedAppVals.defaultSentReceivedFilterEither] autorelease]];

	[formPopulator.currentSection addFieldEditInfo:[[[SentReceivedFilterFieldEditInfo alloc]
		initWithSentReceivedFilter:sharedAppVals.defaultSentReceivedFilterReceived] autorelease]];

	[formPopulator.currentSection addFieldEditInfo:[[[SentReceivedFilterFieldEditInfo alloc]
		initWithSentReceivedFilter:sharedAppVals.defaultSentReceivedFilterSent] autorelease]];
		
			
	return formPopulator.formInfo;
}



@end
