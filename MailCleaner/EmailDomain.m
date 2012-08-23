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
	EmailDomain *theDomain = [currDomainsByName objectForKey:domainName];
	if(theDomain == nil)
	{
		theDomain = [appDataDmc insertObject:EMAIL_DOMAIN_ENTITY_NAME];
		theDomain.domainName = domainName;
		theDomain.domainAcct = emailAcct;
		[currDomainsByName setObject:theDomain forKey:domainName];
	}
	return theDomain;
}

@end
