//
//  EmailInfo.h
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
extern NSString * const EMAIL_INFO_STARRED_KEY;
extern NSString * const EMAIL_INFO_READ_KEY;
extern NSString * const EMAIL_INFO_IS_SENT_MSG_KEY;
extern NSString * const EMAIL_INFO_SUBJECT_KEY;
extern NSString * const EMAIL_INFO_RECIPIENT_ADDRESSES_KEY;

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
@property (nonatomic, retain) NSSet *recipientDomains;

@property (nonatomic, retain) NSNumber * size;

@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * isStarred;
@property (nonatomic, retain) NSNumber * isSentMsg;


// The isHidden property is used to manage whether the message
// should be removed from futher consideration, with a default of FALSE.
// The UI functionality is not yet implemented, but the data model
// definition is in place so a schema migration isn't necessary
// to implement the feature.
@property (nonatomic, retain) NSNumber * isHidden;



-(NSString*)formattedSendDate;
-(NSString*)formattedSendDateAndTime;

@end

@interface EmailInfo (CoreDataGeneratedAccessors)

- (void)addRecipientAddressesObject:(EmailAddress *)value;
- (void)removeRecipientAddressesObject:(EmailAddress *)value;
- (void)addRecipientAddresses:(NSSet *)values;
- (void)removeRecipientAddresses:(NSSet *)values;

- (void)addRecipientDomainsObject:(EmailDomain *)value;
- (void)removeRecipientDomainsObject:(EmailDomain *)value;
- (void)addRecipientDomains:(NSSet *)values;
- (void)removeRecipientDomains:(NSSet *)values;


@end
