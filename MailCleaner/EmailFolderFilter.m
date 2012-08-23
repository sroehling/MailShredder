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
NSString * const EMAIL_FOLDER_FILTER_MATCH_UNSELECTED_KEY = @"matchUnselected";
NSInteger const MAX_SPECIFIC_FOLDER_SYNOPSIS = 2;

@implementation EmailFolderFilter

@dynamic selectedFolders;

// Inverse relationships
@dynamic msgHandlingRuleFolderFilter;
@dynamic messageFilterFolderFilter;
@dynamic matchUnselected;

-(NSString*)filterSelectedPrefix
{
	if([self.matchUnselected boolValue])
	{
		return LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_UNSELECTED");
	}
	else 
	{
		return LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_SELECTED");
	}
}

-(NSString*)filterSynopsisShort
{
	if([self.selectedFolders count] == 0)
	{
		return LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_NONE_TITLE");
	}
	else 
	{
		return [self filterSelectedPrefix];
	}
}

-(NSString*)subFilterSynopsis
{
	NSInteger folderNum = 0;
	NSMutableArray *specificFolderNames = [[[NSMutableArray alloc] init] autorelease];
	for(EmailFolder *folder in self.selectedFolders)
	{
		if(folderNum < MAX_SPECIFIC_FOLDER_SYNOPSIS)
		{
			[specificFolderNames addObject:folder.folderName];
		}
		folderNum++;
	}
	if(folderNum <= MAX_SPECIFIC_FOLDER_SYNOPSIS)
	{
		return [specificFolderNames componentsJoinedByString:@", "];
	}
	else
	{
		NSInteger remainingFolders = [self.selectedFolders count] - MAX_SPECIFIC_FOLDER_SYNOPSIS;
		NSString *remainingFolderDesc = [NSString stringWithFormat:
			LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_SELECTED_REMAINING_FOLDERS_FORMAT"),remainingFolders];
		return [NSString stringWithFormat:@"%@ %@",
			[specificFolderNames componentsJoinedByString:@", "],
			remainingFolderDesc];
	}

}

-(NSString*)filterSynopsis
{
	if([self.selectedFolders count] == 0)
	{
		return LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_NONE_TITLE");
	}
	else 
	{
		return [NSString stringWithFormat:@"%@ (%@)",[self filterSelectedPrefix],
				[self subFilterSynopsis]];
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
				EMAIL_INFO_FOLDER_INFO_KEY,folder]];
		}

		NSPredicate *matchSpecificFolders = 
			[NSCompoundPredicate orPredicateWithSubpredicates:specificFolderPredicates];
			
		if([self.matchUnselected boolValue])
		{
			return [NSCompoundPredicate notPredicateWithSubpredicate:matchSpecificFolders];
		}
		else
		{
			return matchSpecificFolders;
		}

	}
}

-(void)setFolders:(NSSet*)selectedFolders
{
	// Clear out the list of current domains
	NSSet *existingFolders = [NSSet setWithSet:self.selectedFolders];
	[self removeSelectedFolders:existingFolders];
	
	// Add the selected domains
	[self addSelectedFolders:selectedFolders];
}

@end
