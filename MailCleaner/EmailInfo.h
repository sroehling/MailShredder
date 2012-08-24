//
//  EmailInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const EMAIL_INFO_ENTITY_NAME;
extern NSString * const EMAIL_INFO_SEND_DATE_KEY;

extern NSString * const EMAIL_INFO_DELETED_KEY;
extern NSString * const EMAIL_INFO_ACCT_KEY;
extern NSString * const EMAIL_INFO_SENDER_ADDRESS_KEY;
extern NSString * const EMAIL_INFO_FOLDER_INFO_KEY;
extern NSString * const EMAIL_INFO_SENDER_DOMAIN_KEY;

@class EmailFolder;
@class EmailAddress;
@class EmailAccount;
@class EmailDomain;

@interface EmailInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSDate * sendDate;
@property (nonatomic, retain) NSString * subject;


// If marked as deleted, it will be deleted on the server
// as soon as possible.
@property (nonatomic, retain) NSNumber * deleted;

@property (nonatomic, retain) EmailAddress *senderAddress;

@property (nonatomic, retain) EmailFolder *folderInfo;
@property (nonatomic, retain) EmailDomain *senderDomain;

@property (nonatomic, retain) EmailAccount *emailAcct;

@property (nonatomic, retain) NSSet *recipientAddresses;

-(NSString*)formattedSendDate;
-(NSString*)formattedSendDateAndTime;



@end

@interface EmailInfo (CoreDataGeneratedAccessors)

- (void)addRecipientAddressesObject:(EmailAddress *)value;
- (void)removeRecipientAddressesObject:(EmailAddress *)value;
- (void)addRecipientAddresses:(NSSet *)values;
- (void)removeRecipientAddresses:(NSSet *)values;

@end
