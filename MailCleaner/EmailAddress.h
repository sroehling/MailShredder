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

@end

@interface EmailAddress (CoreDataGeneratedAccessors)

- (void)addSelectedAddressEmailAddressObject:(EmailAddressFilterSelected *)value;
- (void)removeSelectedAddressEmailAddressObject:(EmailAddressFilterSelected *)value;
- (void)addSelectedAddressEmailAddress:(NSSet *)values;
- (void)removeSelectedAddressEmailAddress:(NSSet *)values;

@end
