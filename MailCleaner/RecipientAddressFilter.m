//
//  RecipientAddressFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RecipientAddressFilter.h"
#import "EmailAddress.h"
#import "LocalizationHelper.h"

NSString * const RECIPIENT_ADDRESS_FILTER_ENTITY_NAME = @"RecipientAddressFilter";

@implementation RecipientAddressFilter

@dynamic messageFilterRecipientAddressFilter;
@dynamic msgHandlingRuleRecipientAddressFilter;


-(NSPredicate*)emailInfoMatchSelectedAddrPredicate:(EmailAddress*)selectedAddr
{
	return [NSPredicate predicateWithFormat:
		@"ANY recipientAddresses.address = [cd] %@", selectedAddr.address];
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
