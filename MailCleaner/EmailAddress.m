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
#import "DateHelper.h"


NSString * const EMAIL_ADDRESS_ENTITY_NAME = @"EmailAddress";
NSString * const EMAIL_ADDRESS_ACCT_KEY = @"addressAccount";
NSString * const EMAIL_ADDRESS_NAME_OR_ADDRESS_KEY = @"nameOrAddress";

@implementation EmailAddress

@dynamic address;
@dynamic name;
@dynamic nameDate;
@dynamic selectedAddressEmailAddress;
@dynamic emailInfoRecipientAddress;
@dynamic addressAccount;
@dynamic emailInfosWithSenderAddress;

// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;


+(EmailAddress*)findOrAddAddress:(NSString*)emailAddress 
	withName:(NSString*)senderName
	andSendDate:(NSDate*)sendDate
	withCurrentAddresses:(NSMutableDictionary*)currAddressByName 
			inDataModelController:(DataModelController*)appDataDmc
			andEmailAcct:(EmailAccount*)emailAcct
{

	assert([StringValidation nonEmptyString:emailAddress]);
	// Update the list of known senders' addresses, if the address is not
	// already in the list.
	EmailAddress *theAddr = [currAddressByName objectForKey:emailAddress];
	if(theAddr == nil)
	{
		theAddr = [appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
		theAddr.address = emailAddress;
		theAddr.addressAccount = emailAcct;
		[currAddressByName setObject:theAddr forKey:emailAddress];
	}

	// Set or update the name used for the address
	if((theAddr.name == nil) || ([theAddr.name length]==0))
	{
		theAddr.name = senderName;
		theAddr.nameDate = sendDate;
	}
	else if ((theAddr.nameDate != nil) && 
		[StringValidation nonEmptyString:senderName] &&
		[DateHelper dateIsLater:sendDate otherDate:theAddr.nameDate])
	{
		// Name is already set, but there is a newer one.
		theAddr.nameDate = sendDate;
		theAddr.name = senderName;
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

-(NSString*)nameOrAddress
{
	if([self.name length] > 0)
	{
		return self.name;
	}
	else 
	{
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
