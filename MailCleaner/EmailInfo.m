//
//  EmailInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailInfo.h"

NSString * const EMAIL_INFO_ENTITY_NAME = @"EmailInfo";
NSString * const EMAIL_INFO_SEND_DATE_KEY = @"sendDate";
NSString * const EMAIL_INFO_FROM_KEY = @"from";
NSString * const EMAIL_INFO_DOMAIN_KEY = @"domain";
NSString * const EMAIL_INFO_FOLDER_KEY = @"folder";
NSString * const EMAIL_INFO_DELETED_KEY = @"deleted";

@implementation EmailInfo

@dynamic messageId;
@dynamic sendDate;
@dynamic from;
@dynamic domain;
@dynamic folder;
@dynamic subject;
@dynamic deleted;
@dynamic recipientAddresses;

@dynamic folderInfo;


@end
