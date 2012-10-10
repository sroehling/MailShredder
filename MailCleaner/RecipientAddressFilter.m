//
//  RecipientAddressFilter.m
//
//  Created by Steve Roehling on 8/3/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "RecipientAddressFilter.h"
#import "EmailAddress.h"
#import "EmailInfo.h"
#import "LocalizationHelper.h"

NSString * const RECIPIENT_ADDRESS_FILTER_ENTITY_NAME = @"RecipientAddressFilter";

@implementation RecipientAddressFilter

@dynamic messageFilterRecipientAddressFilter;

-(NSPredicate*)filterPredicate
{
	if([self.selectedAddresses count] == 0)
	{
		return [NSPredicate predicateWithValue:TRUE];
	}
	else 
	{
		NSPredicate *matchSpecificAddrs =  [NSPredicate predicateWithFormat:@"ANY %K IN %@",
			EMAIL_INFO_RECIPIENT_ADDRESSES_KEY,self.selectedAddresses];
			
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


-(NSString*)fieldCaption
{
	return LOCALIZED_STR(@"RECIPIENT_ADDRESS_TITLE");
}

-(NSString*)addressType
{
	return LOCALIZED_STR(@"RECIPIENT_ADDRESS_TYPE");
}

-(NSString*)addressTypePlural
{
	return LOCALIZED_STR(@"RECIPIENT_ADDRESS_TYPE_PLURAL");
}




@end
