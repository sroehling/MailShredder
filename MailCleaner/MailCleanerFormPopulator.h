//
//  MailCleanerFormPopulator.h
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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

-(void)populateSentReceivedFilterInParentObj:(NSManagedObject*)parentObj
	withSentReceivedFilterPropertyKey:(NSString*)filterKey;
	
-(void)populateEmailAddressFilter:(EmailAddressFilter*)emailAddressFilter
	andDoSelectRecipients:(BOOL)selectRecipients andDoSelectSenders:(BOOL)selectSenders;

-(void)populateEmailDomainFilter:(EmailDomainFilter*)emailDomainFilter;
-(void)populateEmailFolderFilter:(EmailFolderFilter*)emailFolderFilter;
-(void)populateSubjectFilter:(SubjectFilter*)subjectFilter;

@end
