//
//  MoreFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreFormInfoCreator.h"
#import "HelpPageFormPopulator.h"
#import "LocalizationHelper.h"

@implementation MoreFormInfoCreator

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
    HelpPageFormPopulator *formPopulator = [[[HelpPageFormPopulator alloc] 
		initWithFormContext:parentContext] autorelease];
	
	formPopulator.formInfo.title = LOCALIZED_STR(@"MORE_VIEW_TITLE");
	
	[formPopulator nextSection];
	
	[formPopulator populateHelpPageWithTitle:LOCALIZED_STR(@"HELP_ABOUT") andPageRef:@"about"];

	
	return formPopulator.formInfo;

}

@end
