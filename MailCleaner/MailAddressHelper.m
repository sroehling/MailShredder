//
//  MailAddressHelper.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailAddressHelper.h"

@implementation MailAddressHelper

+(NSString*)emailAddressDomainName:(NSString*)fullAddress
{
	assert(fullAddress != nil);
	NSArray *addrParts = [fullAddress componentsSeparatedByString:@"@"];
	if([addrParts count] == 2)
	{
		return [addrParts objectAtIndex:1];
	}
	else 
	{
		return @"";
	}
}

+(NSString*)emailAddressUserName:(NSString*)fullAddress
{
	assert(fullAddress != nil);
	NSArray *addrParts = [fullAddress componentsSeparatedByString:@"@"];
	if([addrParts count] == 2)
	{
		return [addrParts objectAtIndex:0];
	}
	else 
	{
		return @"";
	}

}

@end
