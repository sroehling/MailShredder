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
@class SubjectFilter;

@interface MailCleanerFormPopulator : FormPopulator

-(void)populateAgeFilterInParentObj:(NSManagedObject*)parentObj
	withAgeFilterPropertyKey:(NSString*)ageFilterKey;
	
-(void)populateReadFilterInParentObj:(NSManagedObject*)parentObj
	withReadFilterPropertyKey:(NSString*)readFilterKey;
	
-(void)populateStarredFilterInParentObj:(NSManagedObject*)parentObj
	withStarredFilterPropertyKey:(NSString*)starredFilterKey;	
	
-(void)populateEmailAddressFilter:(EmailAddressFilter*)emailAddressFilter;
-(void)populateEmailDomainFilter:(EmailDomainFilter*)emailDomainFilter;
-(void)populateEmailFolderFilter:(EmailFolderFilter*)emailFolderFilter;
-(void)populateSubjectFilter:(SubjectFilter*)subjectFilter;

@end
