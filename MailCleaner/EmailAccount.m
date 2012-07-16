//
//  EmailAccount.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAccount.h"

NSString * const EMAIL_ACCOUNT_ENTITY_NAME = @"EmailAccount";
NSString * const EMAIL_ACCOUNT_NAME_KEY = @"acctName";
NSString * const EMAIL_ACCOUNT_USESSL_KEY = @"useSSL";
NSInteger const EMAIL_ACCOUNT_NAME_MAX_LENGTH = 32;
NSString * const EMAIL_ACCOUNT_PORTNUM_KEY= @"portNumber";
NSString * const EMAIL_ACCOUNT_ADDRESS_KEY = @"emailAddress";
NSString * const EMAIL_ACCOUNT_IMAPSERVER_KEY = @"imapServer";
NSString * const EMAIL_ACCOUNT_USERNAME_KEY = @"userName";
NSString * const EMAIL_ACCOUNT_PASSWORD_KEY = @"password";

NSInteger const EMAIL_ACCOUNT_DEFAULT_PORT_SSL = 993;
NSInteger const EMAIL_ACCOUNT_DEFAULT_PORT_NOSSL = 143;


@implementation EmailAccount

@dynamic acctName;
@dynamic emailAddress;
@dynamic imapServer;
@dynamic userName;
@dynamic useSSL;
@dynamic portNumber;
@dynamic password;

@end
