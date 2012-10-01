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
extern NSString * const EMAIL_DOMAIN_SECTION_NAME_KEY;

@interface EmailDomain : NSManagedObject
{
	@private
		BOOL isSelectedForSelectableObjectTableView;
}

@property (nonatomic, retain) NSString * domainName;

@property (nonatomic, retain) EmailAccount *domainAcct;

@property (nonatomic, retain) NSNumber * isRecipientDomain;
@property (nonatomic, retain) NSNumber * isSenderDomain;
@property (nonatomic, retain) NSString * sectionName;

@property BOOL isSelectedForSelectableObjectTableView;

+(EmailDomain*)findOrAddDomainName:(NSString*)domainName 
			withCurrentDomains:(NSMutableDictionary*)currDomainsByName 
			inDataModelController:(DataModelController*)appDataDmc
			andEmailAcct:(EmailAccount*)emailAcct
			andIsRecipientDomain:(BOOL)recipientDomain
			andIsSenderDomain:(BOOL)senderDomain;

@end
