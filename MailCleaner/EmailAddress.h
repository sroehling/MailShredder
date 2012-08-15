//
//  EmailAddress.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmailAddressFilterSelected;
@class DataModelController;
@class EmailInfo;

extern NSString * const EMAIL_ADDRESS_ENTITY_NAME;

@interface EmailAddress : NSManagedObject
{
	@private
		BOOL isSelectedForSelectableObjectTableView;
}

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * name;

@property (nonatomic, retain) NSSet *selectedAddressEmailAddress;

@property BOOL isSelectedForSelectableObjectTableView;

+(NSMutableDictionary*)addressesByName:(DataModelController*)appDataDmc;
+(EmailAddress*)findOrAddAddress:(NSString*)emailAddress 
	withCurrentAddresses:(NSMutableDictionary*)currAddressByName 
			inDataModelController:(DataModelController*)appDataDmc;
@property (nonatomic, retain) NSSet *emailInfoRecipientAddress;

@end

@interface EmailAddress (CoreDataGeneratedAccessors)

- (void)addSelectedAddressEmailAddressObject:(EmailAddressFilterSelected *)value;
- (void)removeSelectedAddressEmailAddressObject:(EmailAddressFilterSelected *)value;
- (void)addSelectedAddressEmailAddress:(NSSet *)values;
- (void)removeSelectedAddressEmailAddress:(NSSet *)values;

- (void)addEmailInfoRecipientAddressObject:(EmailInfo *)value;
- (void)removeEmailInfoRecipientAddressObject:(EmailInfo *)value;
- (void)addEmailInfoRecipientAddress:(NSSet *)values;
- (void)removeEmailInfoRecipientAddress:(NSSet *)values;

+(NSString*)formattedAddresses:(NSSet*)addresses;
-(NSString*)formattedAddress;

@end
