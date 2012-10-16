//
//  SubjectFilterFormInfoCreator.m
//
//  Created by Steve Roehling on 9/13/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "SubjectFilterFormInfoCreator.h"
#import "FormContext.h"
#import "FormPopulator.h"
#import "LocalizationHelper.h"
#import "SubjectFilter.h"
#import "TextFieldEditInfo.h"
#import "SectionInfo.h"

@implementation SubjectFilterFormInfoCreator

@synthesize subjectFilter;

-(id)initWithSubjectFilter:(SubjectFilter*)theSubjectFilter
{
	self = [super init];
	if (self)
	{
		assert(theSubjectFilter != nil);
		self.subjectFilter = theSubjectFilter;
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
    FormPopulator *formPopulator = [[[FormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
			
    formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_SUBJECT_FILTER_TITLE");
	
	[formPopulator populateWithHeader:nil andSubHeader:LOCALIZED_STR(@"EMAIL_SUBJECT_FILTER_TABLE_SUBTITLE")];
	
	[formPopulator nextSection];
	
	TextFieldEditInfo *subjectContainsFieldEditInfo =
		[TextFieldEditInfo createForObject:self.subjectFilter andKey:SUBJECT_FILTER_SEARCH_STRING_KEY 
		andLabel:LOCALIZED_STR(@"SUBJECT_FILTER_SEARCH_STRING_FIELD_LABEL") 
		andPlaceholder:LOCALIZED_STR(@"SUBJECT_FILTER_SEARCH_STRING_PLACEHOLDER") 
		andValidator:nil andSecureTextEntry:FALSE andAutoCorrectType:UITextAutocorrectionTypeNo
		andAutoCapitalizationType:UITextAutocapitalizationTypeSentences];
	[formPopulator.currentSection addFieldEditInfo:subjectContainsFieldEditInfo];
	
	[formPopulator populateBoolFieldInParentObj:self.subjectFilter 
		withBoolField:SUBJECT_FILTER_CASE_SENSITIVE_KEY 
		andFieldLabel:LOCALIZED_STR(@"SUBJECT_FILTER_CASE_SENSITIVE_FIELD_LABEL") 
		andSubTitle:LOCALIZED_STR(@"SUBJECT_FILTER_CASE_SENSITIVE_FIELD_SUBTITLE")];
	
	return formPopulator.formInfo;
}



@end
