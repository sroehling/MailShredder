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
NSString * const EMAIL_INFO_LOCKED_KEY = @"locked";
NSString * const EMAIL_INFO_FROM_KEY = @"from";
NSString * const EMAIL_INFO_TRASHED_KEY = @"trashed";
NSString * const EMAIL_INFO_DELETED_KEY = @"deleted";
NSString * const EMAIL_INFO_SELECTED_IN_MSG_LIST_KEY = @"selectedInMsgList";

@implementation EmailInfo

@dynamic messageId;
@dynamic sendDate;
@dynamic from;
@dynamic subject;

@dynamic selectedInMsgList;

@dynamic locked;
@dynamic trashed;
@dynamic deleted;

@dynamic folderInfo;


@end
