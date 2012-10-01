//
//  EmailAddressFilterTableConfigurator.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/28/12.
//
//

#import <Foundation/Foundation.h>
#import "CoreDataTableConfigurator.h"

@class DataModelController;
@class EmailAddressFilterFormInfo;


@interface EmailAddressSelectionTableConfigurator : NSObject
	<CoreDataTableConfigurator>
{
	@private
		NSFetchedResultsController *addressFrc;
		DataModelController *dmcForAddresses;
		EmailAddressFilterFormInfo *filterFormInfo;
}

@property(nonatomic,retain) NSFetchedResultsController *addressFrc;
@property(nonatomic,retain) DataModelController *dmcForAddresses;
@property(nonatomic,retain) EmailAddressFilterFormInfo *filterFormInfo;

-(id)initWithDataModelController:(DataModelController*)theDmcForAddresses
	andFilterFormInfo:(EmailAddressFilterFormInfo *)theFilterFormInfo;

@end
