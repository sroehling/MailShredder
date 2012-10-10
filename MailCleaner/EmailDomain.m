//
//  EmailDomain.m
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "EmailDomain.h"
#import "DataModelController.h"
#import "StringValidation.h"
#import "EmailAccount.h"

NSString * const EMAIL_DOMAIN_ENTITY_NAME = @"EmailDomain";
NSString * const EMAIL_DOMAIN_ACCT_KEY = @"domainAcct";
NSString * const EMAIL_DOMAIN_NAME_KEY = @"domainName";
NSString * const EMAIL_DOMAIN_SECTION_NAME_KEY = @"sectionName";
NSString * const EMAIL_DOMAIN_IS_SENDER_KEY = @"isSenderDomain";

@implementation EmailDomain

@dynamic domainName;
@dynamic domainAcct;

@dynamic isRecipientDomain;
@dynamic isSenderDomain;
@dynamic sectionName;

@dynamic emailInfoRecipientDomains;

// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;


+(EmailDomain*)findOrAddDomainName:(NSString*)domainName 
			withCurrentDomains:(NSMutableDictionary*)currDomainsByName 
			inDataModelController:(DataModelController*)appDataDmc
			andEmailAcct:(EmailAccount*)emailAcct
			andIsRecipientDomain:(BOOL)recipientDomain
			andIsSenderDomain:(BOOL)senderDomain
{
	assert(domainName!=nil);

	// Domain names are case-insensitive (per RFC 2821), so we store (and lookup)
	// the domain name using the lower-case version of the domain name. This ensures
	// that 2 domain names which differ only by their case are treated the same.
	NSString *caseInsensitiveDomainName = [domainName lowercaseString];
	
	EmailDomain *theDomain = [currDomainsByName objectForKey:caseInsensitiveDomainName];
	if(theDomain == nil)
	{
		theDomain = [appDataDmc insertObject:EMAIL_DOMAIN_ENTITY_NAME];
		theDomain.domainName = caseInsensitiveDomainName;
		theDomain.domainAcct = emailAcct;
		
		theDomain.sectionName = (domainName.length>0)?
			[[domainName substringToIndex:1] uppercaseString]:@"";
		
		[currDomainsByName setObject:theDomain forKey:caseInsensitiveDomainName];
	}
	
	if(recipientDomain)
	{
		theDomain.isRecipientDomain = [NSNumber numberWithBool:TRUE];
	}
	
	if(senderDomain)
	{
		theDomain.isSenderDomain = [NSNumber numberWithBool:TRUE];
	}
	
	return theDomain;
}

@end
