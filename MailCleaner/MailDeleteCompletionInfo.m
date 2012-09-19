//
//  MailDeleteCompletionInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailDeleteCompletionInfo.h"
#import "LocalizationHelper.h"

@implementation MailDeleteCompletionInfo

@synthesize destinationFolder;
@synthesize numMsgsDeleted;
@synthesize didEraseMsgs;

-(NSString*)completionSummary
{
	if(didEraseMsgs)
	{
		if(destinationFolder != nil)
		{
			return [NSString stringWithFormat:LOCALIZED_STR(@"MESSAGE_DELETION_COMPLETION_STATUS_MOVED_THEN_PERMANENTLY_DELETE_FORMAT"),
				numMsgsDeleted,destinationFolder];
		}
		else 
		{
			// Messages deleted in place
			return [NSString stringWithFormat:LOCALIZED_STR(@"MESSAGE_DELETION_COMPLETION_STATUS_PERMANENTLY_DELETE_FORMAT"),
				numMsgsDeleted];
		}
	}
	else if(destinationFolder != nil)
	{
		return [NSString stringWithFormat:LOCALIZED_STR(@"MESSAGE_DELETION_COMPLETION_STATUS_MOVED_TO_TRASH_FOLDER"),
			numMsgsDeleted,destinationFolder];
	}
	else 
	{
		return LOCALIZED_STR(@"MESSAGE_DELETION_COMPLETION_STATUS_NO_ACTION");
	}
}

@end
