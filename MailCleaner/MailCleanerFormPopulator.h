//
//  MailCleanerFormPopulator.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FormPopulator.h"

@class EmailAddressFilter;
@class EmailDomainFilter;
@class EmailFolderFilter;

@interface MailCleanerFormPopulator : FormPopulator

-(void)populateAgeFilterInParentObj:(NSManagedObject*)parentObj
	withAgeFilterPropertyKey:(NSString*)ageFilterKey;
	
-(void)populateEmailAddressFilter:(EmailAddressFilter*)emailAddressFilter;
-(void)populateEmailDomainFilter:(EmailDomainFilter*)emailDomainFilter;
-(void)populateEmailFolderFilter:(EmailFolderFilter*)emailFolderFilter;

@end
