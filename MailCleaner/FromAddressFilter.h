//
//  FromAddressFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EmailAddressFilter.h"

@class MessageFilter;
@class MsgHandlingRule;

extern NSString * const FROM_ADDRESS_FILTER_ENTITY_NAME;


@interface FromAddressFilter : EmailAddressFilter

// Inverse relationships
@property (nonatomic, retain) NSSet *messageFilterFromAddrFilter;
@property (nonatomic, retain) NSSet *msgHandlingRuleFromAddressFilter;

@end

@interface FromAddressFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterFromAddrFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterFromAddrFilterObject:(MessageFilter *)value;
- (void)addMessageFilterFromAddrFilter:(NSSet *)values;
- (void)removeMessageFilterFromAddrFilter:(NSSet *)values;

- (void)addMsgHandlingRuleFromAddressFilterObject:(MsgHandlingRule *)value;
- (void)removeMsgHandlingRuleFromAddressFilterObject:(MsgHandlingRule *)value;
- (void)addMsgHandlingRuleFromAddressFilter:(NSSet *)values;
- (void)removeMsgHandlingRuleFromAddressFilter:(NSSet *)values;


@end
