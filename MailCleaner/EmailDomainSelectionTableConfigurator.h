//
//  EmailDomainSelectionTableConfigurator.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/30/12.
//
//

#import <Foundation/Foundation.h>
#import "CoreDataTableConfigurator.h"

@class DataModelController;
@class EmailDomainFilter;

@interface EmailDomainSelectionTableConfigurator : NSObject
	<CoreDataTableConfigurator>
{
	@private
		NSFetchedResultsController *domainFrc;
		DataModelController *dmcForDomains;
		EmailDomainFilter *domainFilter;

}

@property(nonatomic,retain) NSFetchedResultsController *domainFrc;
@property(nonatomic,retain) DataModelController *dmcForDomains;
@property(nonatomic,retain) EmailDomainFilter *domainFilter;

-(id)initWithDataModelController:(DataModelController*)theDmcForDomains
	andDomainFilter:(EmailDomainFilter *)theDomainFilter;

@end
