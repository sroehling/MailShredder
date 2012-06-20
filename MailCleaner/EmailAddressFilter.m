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

@implementation EmailAddressFilter

@dynamic messageFilterEmailAddressFilter;
@dynamic msgHandlingRuleEmailAddressFilter;

@dynamic selectedAddresses;

-(NSString*)filterSynopsis
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
