//
//  EmailInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailInfo.h"
#import "DateHelper.h"

NSString * const EMAIL_INFO_ENTITY_NAME = @"EmailInfo";
NSString * const EMAIL_INFO_SEND_DATE_KEY = @"sendDate";
NSString * const EMAIL_INFO_DELETED_KEY = @"deleted";
NSString * const EMAIL_INFO_ACCT_KEY = @"emailAcct";
NSString * const EMAIL_INFO_SENDER_ADDRESS_KEY = @"senderAddress";
NSString * const EMAIL_INFO_FOLDER_INFO_KEY = @"folderInfo";
NSString * const EMAIL_INFO_SENDER_DOMAIN_KEY = @"senderDomain";
NSString * const EMAIL_INFO_STARRED_KEY = @"isStarred";
NSString * const EMAIL_INFO_READ_KEY = @"isRead";

@implementation EmailInfo

@dynamic uid;
@dynamic sendDate; // GMT
@dynamic subject;
@dynamic deleted;
@dynamic recipientAddresses;
@dynamic emailAcct;
@dynamic senderAddress;

@dynamic folderInfo;
@dynamic senderDomain;

@dynamic isRead;
@dynamic isStarred;

- (NSDate*)sendDateLocalTimeZone 
{
    return [self.sendDate dateByAddingTimeInterval:[[NSTimeZone localTimeZone] secondsFromGMT]];
}

-(NSString*)formattedSendDate
{
	NSDate *localSendDate = [self sendDateLocalTimeZone];
	if([DateHelper dateIsEqual:localSendDate otherDate:[DateHelper today]])
	{
		return [[DateHelper theHelper].shortTimeFormatter stringFromDate:localSendDate];
	}
	else 
	{
		return [[DateHelper theHelper].shortDateFormatter stringFromDate:localSendDate];
	}
}

-(NSString*)formattedSendDateAndTime
{
	NSDate *localSendDate = [self sendDateLocalTimeZone];
	return [[DateHelper theHelper].mediumDateAndTimeFormatter stringFromDate:localSendDate];
}

@end
