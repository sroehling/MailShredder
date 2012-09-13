//
//  ReadFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ReadFilter.h"
#import "DataModelController.h"
#import "EmailInfo.h"
#import "LocalizationHelper.h"

NSString * const READ_FILTER_ENTITY_NAME = @"ReadFilter";
NSUInteger const READ_FILTER_MATCH_LOGIC_READ=0;
NSUInteger const READ_FILTER_MATCH_LOGIC_UNREAD=1;
NSUInteger const READ_FILTER_MATCH_LOGIC_READ_OR_UNREAD=2;


@implementation ReadFilter

@dynamic matchLogic;

// Inverse relationships
@dynamic sharedAppValsDefaultReadFilterRead;
@dynamic sharedAppValsDefaultReadFilterReadOrUnread;
@dynamic sharedAppValsDefaultReadFilterUnread;
@dynamic messageFilterReadFilter;

@synthesize selectionFlagForSelectableObjectTableView;

+(ReadFilter*)readFilterInDataModelController:(DataModelController*)dmcForNewFilter
	andMatchLogic:(NSUInteger)theMatchLogic
{
	ReadFilter *theFilter = [dmcForNewFilter insertObject:READ_FILTER_ENTITY_NAME];
	assert((theMatchLogic == READ_FILTER_MATCH_LOGIC_READ) ||
		(theMatchLogic == READ_FILTER_MATCH_LOGIC_UNREAD) ||
		(theMatchLogic == READ_FILTER_MATCH_LOGIC_READ_OR_UNREAD));
	theFilter.matchLogic = [NSNumber numberWithUnsignedInteger:theMatchLogic];
	return theFilter;
}

-(NSString*)filterSynopsis
{
	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];
		
	if(matchLogic == READ_FILTER_MATCH_LOGIC_READ)
	{
		return LOCALIZED_STR(@"EMAIL_READ_FILTER_MATCH_READ");
	}
	else if(matchLogic == READ_FILTER_MATCH_LOGIC_UNREAD)
	{
		return LOCALIZED_STR(@"EMAIL_READ_FILTER_MATCH_UNREAD");
	}
	else 
	{
		assert(matchLogic == READ_FILTER_MATCH_LOGIC_READ_OR_UNREAD);
		return LOCALIZED_STR(@"EMAIL_READ_FILTER_MATCH_READ_OR_UNREAD");
	}

}

-(NSPredicate*)filterPredicate
{
	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];
	
	if(matchLogic == READ_FILTER_MATCH_LOGIC_READ)
	{
		return [NSPredicate predicateWithFormat:@"%K == %@",
			EMAIL_INFO_READ_KEY,[NSNumber numberWithBool:TRUE]];
	
	}
	else if(matchLogic == READ_FILTER_MATCH_LOGIC_UNREAD)
	{
		return [NSPredicate predicateWithFormat:@"%K == %@",
			EMAIL_INFO_READ_KEY,[NSNumber numberWithBool:FALSE]];
	}
	else 
	{
		assert(matchLogic == READ_FILTER_MATCH_LOGIC_READ_OR_UNREAD);
		return [NSPredicate predicateWithValue:TRUE];
	}
}


@end
