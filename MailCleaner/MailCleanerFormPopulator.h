//
//  MailCleanerFormPopulator.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FormPopulator.h"

@class MsgHandlingRule;
@class EmailAddressFilter;
@class EmailDomainFilter;
@class EmailFolderFilter;

@interface MailCleanerFormPopulator : FormPopulator

-(void)populateAgeFilterInParentObj:(NSManagedObject*)parentObj
	withAgeFilterPropertyKey:(NSString*)ageFilterKey;
	
-(void)populateEmailAddressFilter:(EmailAddressFilter*)emailAddressFilter;
-(void)populateEmailDomainFilter:(EmailDomainFilter*)emailDomainFilter;
-(void)populateEmailFolderFilter:(EmailFolderFilter*)emailFolderFilter;

-(void)populateRuleEnabled:(MsgHandlingRule*)theRule withSubtitle:(NSString*)subTitle;

@end
