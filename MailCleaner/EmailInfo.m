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

@implementation EmailInfo

@dynamic sendDate;
@dynamic from;
@dynamic subject;

@end
