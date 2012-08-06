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

NSString * const EMAIL_ADDRESS_FILTER_MATCH_UNSELECTED_KEY = @"matchUnselected";

NSInteger const MAX_SPECIFIC_ADDRESS_SYNOPSIS = 2;

@implementation EmailAddressFilter

@dynamic matchUnselected;
@dynamic selectedAddresses;

-(NSString*)filterSelectionPrefix
{
	if([self.matchUnselected boolValue])
	{
		return [NSString stringWithFormat:LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_UNSELECTED_FORMAT"),
			[self addressType]];
	}
	else 
	{
		return [NSString stringWithFormat:LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_SELECTED_FORMAT"),
			[self addressTypePlural]];		
	}
}

-(NSString*)matchAnyAddressTitle
{	
	return [NSString stringWithFormat:LOCALIZED_STR(@"EMAIL_ADDRESS_FILTER_ANY_ADDRESS_TITLE_FORMAT"),
		[self addressType]];
}

-(NSString*)filterSynopsisShort
{
	if([self.selectedAddresses count] == 0)
	{
		return [self matchAnyAddressTitle];
	}
	else 
	{
		return [self filterSelectionPrefix];
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
		return [self matchAnyAddressTitle];
	}
	else 
	{
		return [NSString stringWithFormat:@"%@ (%@)",
			[self filterSelectionPrefix],
			[self subFilterSynopsis]];
	}
}

-(NSPredicate*)emailInfoMatchSelectedAddrPredicate:(EmailAddress*)selectedAddr
{
	assert(0); // must be overridden
	return nil;
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
		for(EmailAddress *selectedAddr in self.selectedAddresses)
		{
			[specificAddrPredicates addObject:[self emailInfoMatchSelectedAddrPredicate:selectedAddr]];
		}

		NSPredicate *matchSpecificAddrs = 
			[NSCompoundPredicate orPredicateWithSubpredicates:specificAddrPredicates];
			
		if([self.matchUnselected boolValue])
		{
			return [NSCompoundPredicate notPredicateWithSubpredicate:matchSpecificAddrs];
		}
		else
		{
			return matchSpecificAddrs;
		}
	}
}

-(void)setAddresses:(NSSet *)selectedAddresses
{
	NSSet *existingAddresses = [NSSet setWithSet:self.selectedAddresses];
	[self removeSelectedAddresses:existingAddresses];
	
	[self addSelectedAddresses:selectedAddresses];
}

-(NSString*)fieldCaption
{
	assert(0); // must be overridden
	return nil;
}

-(NSString*)addressType
{
	assert(0); // must be overridden
	return nil;	
}

-(NSString*)addressTypePlural
{
	assert(0); // must be overridden
	return nil;	
}

@end
