//
//  EmailAccount.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const EMAIL_ACCOUNT_ENTITY_NAME;
extern NSString * const EMAIL_ACCOUNT_NAME_KEY;
extern NSInteger const EMAIL_ACCOUNT_NAME_MAX_LENGTH;
extern NSString * const EMAIL_ACCOUNT_USESSL_KEY;
extern NSString * const EMAIL_ACCOUNT_PORTNUM_KEY;
extern NSString * const EMAIL_ACCOUNT_ADDRESS_KEY;
extern NSString * const EMAIL_ACCOUNT_IMAPSERVER_KEY;
extern NSString * const EMAIL_ACCOUNT_USERNAME_KEY;
extern NSString * const EMAIL_ACCOUNT_PASSWORD_KEY;

extern NSInteger const EMAIL_ACCOUNT_DEFAULT_PORT_SSL;
extern NSInteger const EMAIL_ACCOUNT_DEFAULT_PORT_NOSSL;


@interface EmailAccount : NSManagedObject

@property (nonatomic, retain) NSString * acctName;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * imapServer;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * useSSL;
@property (nonatomic, retain) NSNumber * portNumber;
@property (nonatomic, retain) NSString * password;

@end
