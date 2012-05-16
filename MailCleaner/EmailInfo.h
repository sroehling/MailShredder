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

@interface EmailInfo : NSManagedObject

@property (nonatomic, retain) NSDate * sendDate;
@property (nonatomic, retain) NSString * from;
@property (nonatomic, retain) NSString * subject;

@end
