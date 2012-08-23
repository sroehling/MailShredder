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
NSString * const EMAIL_INFO_DOMAIN_KEY = @"domain";
NSString * const EMAIL_INFO_DELETED_KEY = @"deleted";
NSString * const EMAIL_INFO_ACCT_KEY = @"emailAcct";
NSString * const EMAIL_INFO_SENDER_ADDRESS_KEY = @"senderAddress";
NSString * const EMAIL_INFO_FOLDER_INFO_KEY = @"folderInfo";

@implementation EmailInfo

@dynamic uid;
@dynamic sendDate;
@dynamic domain;
@dynamic subject;
@dynamic deleted;
@dynamic recipientAddresses;
@dynamic emailAcct;
@dynamic senderAddress;

@dynamic folderInfo;


-(NSString*)formattedSendDate
{
	if([DateHelper dateIsEqual:self.sendDate otherDate:[DateHelper today]])
	{
		return [[DateHelper theHelper].shortTimeFormatter stringFromDate:self.sendDate];
	}
	else 
	{
		return [[DateHelper theHelper].shortDateFormatter stringFromDate:self.sendDate];
	}
}



@end
