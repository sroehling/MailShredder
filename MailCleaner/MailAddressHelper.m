//
//  MailAddressHelper.m
//
//  Created by Steve Roehling on 6/27/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MailAddressHelper.h"

@implementation MailAddressHelper

+(NSString*)emailAddressDomainName:(NSString*)fullAddress
{
	assert(fullAddress != nil);
	NSArray *addrParts = [fullAddress componentsSeparatedByString:@"@"];
	if([addrParts count] > 0)
	{
		NSInteger indexOfDomainPartAfterLastAmpersand = [addrParts count]-1;
		return [addrParts objectAtIndex:indexOfDomainPartAfterLastAmpersand];
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
