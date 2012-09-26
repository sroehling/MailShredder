//
//  EmailDomain.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DataModelController;
@class EmailAccount;

extern NSString * const EMAIL_DOMAIN_ENTITY_NAME;
extern NSString * const EMAIL_DOMAIN_ACCT_KEY;
extern NSString * const EMAIL_DOMAIN_NAME_KEY;

@interface EmailDomain : NSManagedObject
{
	@private
		BOOL isSelectedForSelectableObjectTableView;
}

@property (nonatomic, retain) NSString * domainName;

@property (nonatomic, retain) EmailAccount *domainAcct;

@property BOOL isSelectedForSelectableObjectTableView;

+(EmailDomain*)findOrAddDomainName:(NSString*)domainName 
			withCurrentDomains:(NSMutableDictionary*)currDomainsByName 
			inDataModelController:(DataModelController*)appDataDmc
			andEmailAcct:(EmailAccount*)emailAcct;

@end
