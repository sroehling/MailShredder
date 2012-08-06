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
extern NSString * const EMAIL_INFO_FROM_KEY;
extern NSString * const EMAIL_INFO_DOMAIN_KEY;
extern NSString * const EMAIL_INFO_FOLDER_KEY;

@class EmailFolder;
@class EmailAddress;

@interface EmailInfo : NSManagedObject

@property (nonatomic, retain) NSString * messageId;

@property (nonatomic, retain) NSDate * sendDate;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * domain;
@property (nonatomic, retain) NSString * folder;

@property (nonatomic, retain) NSString * subject;


// If marked as deleted, it will be deleted on the server
// as soon as possible.
@property (nonatomic, retain) NSNumber * deleted;

@property (nonatomic, retain) EmailFolder *folderInfo;

@property (nonatomic, retain) NSSet *recipientAddresses;

@end

@interface EmailInfo (CoreDataGeneratedAccessors)

- (void)addRecipientAddressesObject:(EmailAddress *)value;
- (void)removeRecipientAddressesObject:(EmailAddress *)value;
- (void)addRecipientAddresses:(NSSet *)values;
- (void)removeRecipientAddresses:(NSSet *)values;

@end
