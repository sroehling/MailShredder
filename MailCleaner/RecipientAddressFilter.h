//
//  RecipientAddressFilter.h
//
//  Created by Steve Roehling on 8/3/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EmailAddressFilter.h"

extern NSString * const RECIPIENT_ADDRESS_FILTER_ENTITY_NAME;

@class MessageFilter;
@class MsgListView;

@interface RecipientAddressFilter : EmailAddressFilter

// Inverse relationships
@property (nonatomic, retain) NSSet *messageFilterRecipientAddressFilter;

@end

@interface RecipientAddressFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterRecipientAddressFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterRecipientAddressFilterObject:(MessageFilter *)value;
- (void)addMessageFilterRecipientAddressFilter:(NSSet *)values;
- (void)removeMessageFilterRecipientAddressFilter:(NSSet *)values;

@end
