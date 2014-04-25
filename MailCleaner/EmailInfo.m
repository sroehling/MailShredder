//
//  EmailInfo.m
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
NSString * const EMAIL_INFO_SUBJECT_KEY = @"subject";
NSString * const EMAIL_INFO_RECIPIENT_ADDRESSES_KEY = @"recipientAddresses";
NSString * const EMAIL_INFO_IS_SENT_MSG_KEY = @"isSentMsg";

@implementation EmailInfo

@dynamic uid;
@dynamic sendDate; // GMT
@dynamic subject;
@dynamic deleted;
@dynamic recipientAddresses;
@dynamic recipientDomains;
@dynamic emailAcct;
@dynamic senderAddress;
@dynamic size;

@dynamic folderInfo;
@dynamic senderDomain;

@dynamic isRead;
@dynamic isStarred;
@dynamic isSentMsg;

@dynamic isHidden;



- (NSDate*)sendDateLocalTimeZone 
{
    return [self.sendDate dateByAddingTimeInterval:[[NSTimeZone localTimeZone] secondsFromGMT]];
}

-(NSString*)formattedSendDate
{
    DateHelper *dateHelper = [[[DateHelper alloc] init] autorelease];

	NSDate *localSendDate = [self sendDateLocalTimeZone];
	if([dateHelper dateIsEqual:localSendDate otherDate:[dateHelper today]])
	{
		return [dateHelper.shortTimeFormatter stringFromDate:localSendDate];
	}
	else 
	{
		return [dateHelper.shortDateFormatter stringFromDate:localSendDate];
	}
}

-(NSString*)formattedSendDateAndTime
{
    DateHelper *dateHelper = [[[DateHelper alloc] init] autorelease];
	NSDate *localSendDate = [self sendDateLocalTimeZone];
	return [dateHelper.mediumDateAndTimeFormatter stringFromDate:localSendDate];
}

@end
