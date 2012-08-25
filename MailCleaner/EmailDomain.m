//
//  EmailDomain.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailDomain.h"
#import "DataModelController.h"
#import "StringValidation.h"
#import "EmailAccount.h"

NSString * const EMAIL_DOMAIN_ENTITY_NAME = @"EmailDomain";
NSString * const EMAIL_DOMAIN_ACCT_KEY = @"domainAcct";

@implementation EmailDomain

@dynamic domainName;
@dynamic domainAcct;

// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;


+(EmailDomain*)findOrAddDomainName:(NSString*)domainName 
			withCurrentDomains:(NSMutableDictionary*)currDomainsByName 
			inDataModelController:(DataModelController*)appDataDmc
			andEmailAcct:(EmailAccount*)emailAcct
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
		[currDomainsByName setObject:theDomain forKey:caseInsensitiveDomainName];
	}
	return theDomain;
}

@end
