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

extern NSString * const EMAIL_INFO_LOCKED_KEY;
extern NSString * const EMAIL_INFO_TRASHED_KEY;
extern NSString * const EMAIL_INFO_DELETED_KEY;
extern NSString * const EMAIL_INFO_SELECTED_IN_MSG_LIST_KEY;


@interface EmailInfo : NSManagedObject

@property (nonatomic, retain) NSString * messageId;

@property (nonatomic, retain) NSDate * sendDate;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * subject;

@property (nonatomic, retain) NSNumber * selectedInMsgList;

@property (nonatomic, retain) NSNumber * locked;
@property (nonatomic, retain) NSNumber * trashed;

// If marked as deleted, it will be deleted on the server
// as soon as possible.
@property (nonatomic, retain) NSNumber * deleted;



@end
