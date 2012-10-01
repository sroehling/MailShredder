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
NSString * const EMAIL_ADDRESS_SORT_KEY = @"addressSort";
NSString * const EMAIL_ADDRESS_ADDRESS_KEY = @"address";
NSString * const EMAIL_ADDRESS_NAME_KEY = @"name";
NSString * const EMAIL_ADDRESS_SECTION_NAME_KEY = @"sectionName";

NSString * const EMAIL_ADDRESS_IS_RECIPIENT_KEY = @"isRecipientAddr";
NSString * const EMAIL_ADDRESS_IS_SENDER_KEY = @"isSenderAddr";


@implementation EmailAddress

@dynamic address;
@dynamic name;
@dynamic nameDate;
@dynamic selectedAddressEmailAddress;
@dynamic emailInfoRecipientAddress;
@dynamic addressAccount;
@dynamic emailInfosWithSenderAddress;
@dynamic addressSort;
@dynamic sectionName;

@dynamic isRecipientAddr;
@dynamic isSenderAddr;


// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;


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

-(void)configSortKeys
{

	NSString *sortStr;
	if([self.name length] > 0)
	{
		sortStr =  self.name;
	}
	else 
	{
		sortStr = self.address;
	}
	
	NSString *pattern = @"^[^a-zA-Z]*(([a-zA-Z]).*)$";
	NSRegularExpression *regex = [NSRegularExpression
		regularExpressionWithPattern:pattern options:0 error:nil];
		
	NSTextCheckingResult *match = [regex firstMatchInString:sortStr
         options:0 range:NSMakeRange(0, [sortStr length])];
	NSString *addressSection = @"";
	NSString *addressSortStr = @"";
	if (match) {
		NSRange addressSortRange = [match rangeAtIndex:1];
		addressSortStr = [sortStr substringWithRange:addressSortRange];
		NSRange firstAlphaRange = [match rangeAtIndex:2];
		addressSection = [[sortStr substringWithRange:firstAlphaRange] uppercaseString];
	}
		
//	NSLog(@"EmailAddress: config sort keys: section = %@, sort string = %@ (orig str = %@)",
//		addressSection,addressSortStr,sortStr);
	self.addressSort = addressSortStr;
	self.sectionName = addressSection;
 
}


+(EmailAddress*)findOrAddAddress:(NSString*)emailAddress 
	withName:(NSString*)senderName
	andSendDate:(NSDate*)sendDate
	withCurrentAddresses:(NSMutableDictionary*)currAddressByName 
			inDataModelController:(DataModelController*)appDataDmc
			andEmailAcct:(EmailAccount*)emailAcct
	andIsRecipientAddr:(BOOL)recipientAddr andIsSenderAddr:(BOOL)senderAddr
{

	assert([StringValidation nonEmptyString:emailAddress]);
	// Update the list of known senders' addresses, if the address is not
	// already in the list.
	EmailAddress *theAddr = [currAddressByName objectForKey:emailAddress];
	if(theAddr == nil)
	{
		theAddr = [appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
		theAddr.address = emailAddress;
		[theAddr configSortKeys];
		theAddr.addressAccount = emailAcct;
		[currAddressByName setObject:theAddr forKey:emailAddress];
	}

	// Set or update the name used for the address
	if((theAddr.name == nil) || ([theAddr.name length]==0))
	{
		theAddr.name = senderName;
		theAddr.nameDate = sendDate;
		[theAddr configSortKeys];
	}
	else if ((theAddr.nameDate != nil) && 
		[StringValidation nonEmptyString:senderName] &&
		[DateHelper dateIsLater:sendDate otherDate:theAddr.nameDate])
	{
		// Name is already set, but there is a newer one.
		theAddr.nameDate = sendDate;
		theAddr.name = senderName;
		[theAddr configSortKeys];
	}
	
	if(recipientAddr)
	{
		theAddr.isRecipientAddr = [NSNumber numberWithBool:TRUE];
	}
	if(senderAddr)
	{
		theAddr.isSenderAddr = [NSNumber numberWithBool:TRUE];
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
