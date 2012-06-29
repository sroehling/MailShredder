//
//  EmailFolderFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailFolderFilter.h"
#import "EmailFolder.h"
#import "MessageFilter.h"
#import "MsgHandlingRule.h"
#import "EmailFolder.h"
#import "LocalizationHelper.h"
#import "EmailInfo.h"

NSString * const EMAIL_FOLDER_FILTER_ENTITY_NAME = @"EmailFolderFilter";

@implementation EmailFolderFilter

@dynamic selectedFolders;

// Inverse relationships
@dynamic msgHandlingRuleFolderFilter;
@dynamic messageFilterFolderFilter;

-(NSString*)filterSynopsis
{
	if([self.selectedFolders count] == 0)
	{
		return LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_NONE_TITLE");
	}
	else 
	{
		return LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_SELECTED");
	}
}

-(NSPredicate*)filterPredicate
{
	if([self.selectedFolders count] == 0)
	{
		return [NSPredicate predicateWithValue:TRUE];
	}
	else 
	{
		NSMutableArray *specificFolderPredicates = [[[NSMutableArray alloc] init] autorelease];
		for(EmailFolder *folder in self.selectedFolders)
		{
			[specificFolderPredicates addObject:[NSPredicate predicateWithFormat:@"%K == %@",
				EMAIL_INFO_FOLDER_KEY,folder.folderName]];
		}

		NSPredicate *matchSpecificFolders = 
			[NSCompoundPredicate orPredicateWithSubpredicates:specificFolderPredicates];
		return matchSpecificFolders;
	}
}


@end
