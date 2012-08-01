//
//  EmailAddressFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MessageFilter, MsgHandlingRule;
@class EmailAddress;

extern NSString * const EMAIL_ADDRESS_FILTER_ENTITY_NAME;
extern NSString * const EMAIL_ADDRESS_FILTER_MATCH_UNSELECTED_KEY;


@interface EmailAddressFilter : NSManagedObject

@property (nonatomic, retain) NSSet *messageFilterEmailAddressFilter;
@property (nonatomic, retain) NSSet *msgHandlingRuleEmailAddressFilter;
@property (nonatomic, retain) NSNumber * matchUnselected;

-(NSString*)filterSynopsis;
-(NSString*)filterSynopsisShort;
-(NSString*)subFilterSynopsis;
-(NSPredicate*)filterPredicate;

@property (nonatomic, retain) NSSet *selectedAddresses;

-(void)setAddresses:(NSSet *)selectedAddresses;

@end

@interface EmailAddressFilter (CoreDataGeneratedAccessors)

- (void)addSelectedAddressesObject:(EmailAddress *)value;
- (void)removeSelectedAddressesObject:(EmailAddress *)value;
- (void)addSelectedAddresses:(NSSet *)values;
- (void)removeSelectedAddresses:(NSSet *)values;

- (void)addMessageFilterEmailAddressFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterEmailAddressFilterObject:(MessageFilter *)value;
- (void)addMessageFilterEmailAddressFilter:(NSSet *)values;
- (void)removeMessageFilterEmailAddressFilter:(NSSet *)values;

- (void)addMsgHandlingRuleEmailAddressFilterObject:(MsgHandlingRule *)value;
- (void)removeMsgHandlingRuleEmailAddressFilterObject:(MsgHandlingRule *)value;
- (void)addMsgHandlingRuleEmailAddressFilter:(NSSet *)values;
- (void)removeMsgHandlingRuleEmailAddressFilter:(NSSet *)values;

@end
