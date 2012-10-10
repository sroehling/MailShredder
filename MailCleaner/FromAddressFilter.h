//
//  FromAddressFilter.h
//
//  Created by Steve Roehling on 8/3/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EmailAddressFilter.h"

@class MessageFilter;

extern NSString * const FROM_ADDRESS_FILTER_ENTITY_NAME;

@interface FromAddressFilter : EmailAddressFilter

// Inverse relationships
@property (nonatomic, retain) NSSet *messageFilterFromAddrFilter;

@end

@interface FromAddressFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterFromAddrFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterFromAddrFilterObject:(MessageFilter *)value;
- (void)addMessageFilterFromAddrFilter:(NSSet *)values;
- (void)removeMessageFilterFromAddrFilter:(NSSet *)values;

@end
