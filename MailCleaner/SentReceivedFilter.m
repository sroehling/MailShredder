//
//  SentReceivedFilter.m
//
//  Created by Steve Roehling on 10/3/12.
//
//

#import "SentReceivedFilter.h"
#import "MessageFilter.h"
#import "SharedAppVals.h"
#import "DataModelController.h"
#import "LocalizationHelper.h"
#import "EmailInfo.h"

NSString * const SENT_RECEIVED_FILTER_ENTITY_NAME = @"SentReceivedFilter";
NSUInteger const SENT_RECEIVED_FILTER_MATCH_LOGIC_EITHER = 0;
NSUInteger const SENT_RECEIVED_FILTER_MATCH_LOGIC_RECEIVED = 1;
NSUInteger const SENT_RECEIVED_FILTER_MATCH_LOGIC_SENT = 2;

@implementation SentReceivedFilter

@dynamic matchLogic;

// Inverse Relationships
@dynamic messageFilterSentReceivedFilter;
@dynamic sharedAppValsSentReceivedFilterEither;
@dynamic sharedAppValsSentReceivedFilterSent;
@dynamic sharedAppValsSentReceivedFilterReceived;

@synthesize selectionFlagForSelectableObjectTableView;


+(SentReceivedFilter*)sentReceivedFilterInDataModelController:(DataModelController*)dmcForNewFilter
	andMatchLogic:(NSUInteger)theMatchLogic
{
	SentReceivedFilter *theFilter = [dmcForNewFilter insertObject:SENT_RECEIVED_FILTER_ENTITY_NAME];
	assert((theMatchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_EITHER) ||
		(theMatchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_RECEIVED) ||
		(theMatchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_SENT));
	theFilter.matchLogic = [NSNumber numberWithUnsignedInteger:theMatchLogic];
	return theFilter;
}


-(NSString*)filterSynopsis
{
	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];
		
	if(matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_RECEIVED)
	{
		return LOCALIZED_STR(@"SENT_RECEIVED_FILTER_MATCH_RECEIVED");
	}
	else if(matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_SENT)
	{
		return LOCALIZED_STR(@"SENT_RECEIVED_FILTER_MATCH_SENT");
	}
	else 
	{
		assert(matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_EITHER);
		return LOCALIZED_STR(@"SENT_RECEIVED_FILTER_MATCH_EITHER");
	}

}

-(NSString*)filterSubtitle
{
	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];
		
	if(matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_RECEIVED)
	{
		return @"";
	}
	else if(matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_SENT)
	{
		return @"";
	}
	else 
	{
		assert(matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_EITHER);
		return LOCALIZED_STR(@"SENT_RECEIVED_FILTER_MATCH_EITHER_SUBTITLE");
	}

}

-(NSPredicate*)filterPredicate
{
	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];
	
	if(matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_RECEIVED)
	{
		return [NSPredicate predicateWithFormat:@"%K == %@",
			EMAIL_INFO_IS_SENT_MSG_KEY,[NSNumber numberWithBool:FALSE]];
	}
	else if(matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_SENT)
	{
		return [NSPredicate predicateWithFormat:@"%K == %@",
			EMAIL_INFO_IS_SENT_MSG_KEY,[NSNumber numberWithBool:TRUE]];
	}
	else 
	{
		assert(matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_EITHER);
		return [NSPredicate predicateWithValue:TRUE];
	}
}

-(BOOL)filterMatchesEitherSentOrReceived
{
	NSUInteger matchLogic = [self.matchLogic unsignedIntegerValue];
	return (matchLogic == SENT_RECEIVED_FILTER_MATCH_LOGIC_EITHER)?TRUE:FALSE;
}


@end
