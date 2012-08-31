//
//  EmailAddressFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MessageFilter;
@class EmailAddress;

extern NSString * const EMAIL_ADDRESS_FILTER_MATCH_UNSELECTED_KEY;


@interface EmailAddressFilter : NSManagedObject

@property (nonatomic, retain) NSNumber * matchUnselected;

-(NSString*)filterSynopsis;
-(NSString*)filterSynopsisShort;
-(NSString*)subFilterSynopsis;
-(NSPredicate*)filterPredicate;

@property (nonatomic, retain) NSSet *selectedAddresses;

-(void)setAddresses:(NSSet *)selectedAddresses;

-(NSString*)fieldCaption;
-(NSString*)addressType;
-(NSString*)addressTypePlural;

@end

@interface EmailAddressFilter (CoreDataGeneratedAccessors)

- (void)addSelectedAddressesObject:(EmailAddress *)value;
- (void)removeSelectedAddressesObject:(EmailAddress *)value;
- (void)addSelectedAddresses:(NSSet *)values;
- (void)removeSelectedAddresses:(NSSet *)values;

@end
