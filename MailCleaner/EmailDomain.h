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

extern NSString * const EMAIL_DOMAIN_ENTITY_NAME;

@interface EmailDomain : NSManagedObject
{
	@private
		BOOL isSelectedForSelectableObjectTableView;
}

@property (nonatomic, retain) NSString * domainName;

@property BOOL isSelectedForSelectableObjectTableView;


+(NSMutableDictionary*)emailDomainsByDomainName:(DataModelController*)appDataDmc;
+(EmailDomain*)findOrAddDomainName:(NSString*)domainName 
		withCurrentDomains:(NSMutableDictionary*)currDomainsByName 
			inDataModelController:(DataModelController*)appDataDmc;

@end
