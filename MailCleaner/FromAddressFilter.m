//
//  FromAddressFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FromAddressFilter.h"
#import "EmailInfo.h"
#import "EmailAddress.h"
#import "LocalizationHelper.h"

NSString * const FROM_ADDRESS_FILTER_ENTITY_NAME = @"FromAddressFilter";

@implementation FromAddressFilter

@dynamic messageFilterFromAddrFilter;
@dynamic msgHandlingRuleFromAddressFilter;


-(NSPredicate*)emailInfoMatchSelectedAddrPredicate:(EmailAddress*)selectedAddr
{
	return [NSPredicate predicateWithFormat:@"%K == %@",
				EMAIL_INFO_SENDER_ADDRESS_KEY,selectedAddr];
}

-(NSString*)fieldCaption
{
	return LOCALIZED_STR(@"FROM_ADDRESS_TITLE");
}

-(NSString*)addressType
{
	return LOCALIZED_STR(@"FROM_ADDRESS_TYPE");
}

-(NSString*)addressTypePlural
{
	return LOCALIZED_STR(@"FROM_ADDRESS_TYPE_PLURAL");
}


@end
