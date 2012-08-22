//
//  EmailFolderSelectionFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailFolderSelectionFormInfoCreator.h"

#import "MailCleanerFormPopulator.h"
#import "LocalizationHelper.h"
#import "FormContext.h"
#import "EmailFolder.h"
#import "DataModelController.h"
#import "EmailFolderFieldEditInfo.h"
#import "EmailFolderFilter.h"
#import "SectionInfo.h"
#import "EmailFolderFilterFolderAdder.h"
#import "SharedAppVals.h"


@implementation EmailFolderSelectionFormInfoCreator

@synthesize emailFolderFilter;

-(id)initWithEmailFolderFilter:(EmailFolderFilter*)theEmailFolderFilter
{
	self = [super init];
	if(self)
	{
		assert(theEmailFolderFilter != nil);
		self.emailFolderFilter = theEmailFolderFilter;
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

    formPopulator.formInfo.title = LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_FOLDER_LIST_TITLE");
	
	formPopulator.formInfo.objectAdder = [[[EmailFolderFilterFolderAdder alloc] 
		initWithEmailFolderFilter:self.emailFolderFilter] autorelease];
		
	[formPopulator nextSection];
	
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:parentContext.dataModelController];
	NSPredicate *currentAcctPredicate = [NSPredicate predicateWithFormat:@"%K=%@",
		EMAIL_FOLDER_ACCT_KEY,sharedVals.currentEmailAcct];

		
	NSArray *folders = [parentContext.dataModelController 
		fetchObjectsForEntityName:EMAIL_FOLDER_ENTITY_NAME andPredicate:currentAcctPredicate];
	for(EmailFolder *folder in folders)
	{
		// Only display the domain for selection if 
		// it is not already in the set of selected domains.
		if([self.emailFolderFilter.selectedFolders member:folder] == nil)
		{
			NSLog(@"Populating form with folder: %@",folder.folderName);
			EmailFolderFieldEditInfo *folderFieldEditInfo = 
				[[[EmailFolderFieldEditInfo alloc] 
					initWithEmailFolder:folder] autorelease];
			[formPopulator.currentSection addFieldEditInfo:folderFieldEditInfo];
		}
	}

	return formPopulator.formInfo;
}

-(void)dealloc
{
	[emailFolderFilter release];
	[super dealloc];
}

@end
