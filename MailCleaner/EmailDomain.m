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

NSString * const EMAIL_DOMAIN_ENTITY_NAME = @"EmailDomain";

@implementation EmailDomain

@dynamic domainName;


// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;


+(NSMutableDictionary*)emailDomainsByDomainName:(DataModelController*)appDataDmc
{
	NSSet *currDomains = [appDataDmc fetchObjectsForEntityName:EMAIL_DOMAIN_ENTITY_NAME];
	NSMutableDictionary *currDomainByDomainName = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailDomain *currDomain in currDomains)
	{
		[currDomainByDomainName setObject:currDomain forKey:currDomain.domainName];
	}
	return currDomainByDomainName;
}


+(EmailDomain*)findOrAddDomainName:(NSString*)domainName withCurrentDomains:(NSMutableDictionary*)currDomainsByName 
			inDataModelController:(DataModelController*)appDataDmc
{
	assert([StringValidation nonEmptyString:domainName]);
	EmailDomain *theDomain = [currDomainsByName objectForKey:domainName];
	if(theDomain == nil)
	{
		theDomain = [appDataDmc insertObject:EMAIL_DOMAIN_ENTITY_NAME];
		theDomain.domainName = domainName;
		[currDomainsByName setObject:theDomain forKey:domainName];
	}
	return theDomain;
}

@end
