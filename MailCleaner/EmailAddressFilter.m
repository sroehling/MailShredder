//
//  EmailAddressFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddressFilter.h"
#import "MessageFilter.h"
#import "MsgHandlingRule.h"
#import "LocalizationHelper.h"
#import "EmailInfo.h"
#import "EmailAddress.h"

NSString * const EMAIL_ADDRESS_FILTER_ENTITY_NAME = @"EmailAddressFilter";
NSInteger const MAX_SPECIFIC_ADDRESS_SYNOPSIS = 2;

@implementation EmailAddressFilter

@dynamic messageFilterEmailAddressFilter;
@dynamic msgHandlingRuleEmailAddressFilter;

@dynamic selectedAddresses;

-(NSString*)filterSynopsisShort
{
	if([self.selectedAddresses count] == 0)
	{
		return LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_NONE_TITLE");
	}
	else 
	{
		return LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_SELECTED");
	}
}

-(NSString*)subFilterSynopsis
{
	NSInteger addressNum = 0;
	NSMutableArray *specificAddresses = [[[NSMutableArray alloc] init] autorelease];
	for(EmailAddress *senderAddress in self.selectedAddresses)
	{
		if(addressNum < MAX_SPECIFIC_ADDRESS_SYNOPSIS)
		{
			[specificAddresses addObject:senderAddress.address];
		}
		addressNum++;
	}
	if(addressNum <= MAX_SPECIFIC_ADDRESS_SYNOPSIS)
	{
		return [specificAddresses componentsJoinedByString:@", "];
	}
	else
	{
		NSInteger remainingAddresses = [self.selectedAddresses count] - MAX_SPECIFIC_ADDRESS_SYNOPSIS;
		NSString *remainingAddressesDesc = [NSString stringWithFormat:
			LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_SELECTED_REMAINING_ADDRESSES_FORMAT"),remainingAddresses];
		return [NSString stringWithFormat:@"%@ %@",
			[specificAddresses componentsJoinedByString:@", "],remainingAddressesDesc];
	}
}

-(NSString*)filterSynopsis
{
	if([self.selectedAddresses count] == 0)
	{
		return LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_NONE_TITLE");
	}
	else 
	{
		return [NSString stringWithFormat:@"%@ (%@)",
			LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_SELECTED"),
			[self subFilterSynopsis]];
	}
}


-(NSPredicate*)filterPredicate
{
	if([self.selectedAddresses count] == 0)
	{
		return [NSPredicate predicateWithValue:TRUE];
	}
	else 
	{
		NSMutableArray *specificAddrPredicates = [[[NSMutableArray alloc] init] autorelease];
		for(EmailAddress *senderAddress in self.selectedAddresses)
		{
			[specificAddrPredicates addObject:[NSPredicate predicateWithFormat:@"%K == %@",
				EMAIL_INFO_FROM_KEY,senderAddress.address]];
		}

		NSPredicate *matchSpecificAddrs = 
			[NSCompoundPredicate orPredicateWithSubpredicates:specificAddrPredicates];
		return matchSpecificAddrs;
	}
}


@end
