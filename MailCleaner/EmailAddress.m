//
//  EmailAddress.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddress.h"
#import "DataModelController.h"
#import "StringValidation.h"


NSString * const EMAIL_ADDRESS_ENTITY_NAME = @"EmailAddress";

@implementation EmailAddress

@dynamic address;
@dynamic name;
@dynamic selectedAddressEmailAddress;
@dynamic emailInfoRecipientAddress;

// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;

+(NSMutableDictionary*)addressesByName:(DataModelController*)appDataDmc
{
	NSSet *currEmailAddresses = [appDataDmc fetchObjectsForEntityName:EMAIL_ADDRESS_ENTITY_NAME]; 
	NSMutableDictionary *currEmailAddressByAddress = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailAddress *currAddr in currEmailAddresses)
	{
		[currEmailAddressByAddress setObject:currAddr forKey:currAddr.address];
	}
	return currEmailAddressByAddress;
}

+(EmailAddress*)findOrAddAddress:(NSString*)emailAddress 
	withCurrentAddresses:(NSMutableDictionary*)currAddressByName 
			inDataModelController:(DataModelController*)appDataDmc
{

	assert([StringValidation nonEmptyString:emailAddress]);
	// Update the list of known senders' addresses, if the address is not
	// already in the list.
	EmailAddress *theAddr = [currAddressByName objectForKey:emailAddress];
	if(theAddr == nil)
	{
		theAddr = [appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
		theAddr.address = emailAddress;
		[currAddressByName setObject:theAddr forKey:emailAddress];
	}
	return theAddr;
}

-(NSString*)formattedAddress
{
	if([self.name length] > 0)
	{
		return [NSString stringWithFormat:@"%@ <%@>",self.name,self.address];
	}
	else {
		return self.address;
	}
}

+(NSString*)formattedAddresses:(NSSet*)addresses
{
	NSMutableArray *formattedAddresses = [[[NSMutableArray alloc] init] autorelease];
	for(EmailAddress *address in addresses)
	{
		[formattedAddresses addObject:[address formattedAddress]];
	}
	return [formattedAddresses componentsJoinedByString:@","];
	
}

@end
