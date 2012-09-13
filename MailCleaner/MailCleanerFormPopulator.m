//
//  MailCleanerFormPopulator.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailCleanerFormPopulator.h"
#import "ManagedObjectFieldInfo.h"
#import "AgeFilterFormInfoCreator.h"
#import "SelectableObjectTableViewControllerFactory.h"
#import "GenericFieldBasedTableEditViewControllerFactory.h"
#import "StaticNavFieldEditInfo.h"
#import "StringValidation.h"
#import "LocalizationHelper.h"
#import "EmailAddressFilter.h"
#import "AgeFilter.h"
#import "SectionInfo.h"
#import "EmailFolderFilter.h"
#import "EmailAddressFilterFormInfoCreator.h"
#import "EmailDomainFilterFormInfoCreator.h"
#import "BoolFieldEditInfo.h"
#import "EmailFolderFilterFormInfoCreator.h"
#import "ReadFilter.h"
#import "ReadFilterFormInfoCreator.h"
#import "StarredFilter.h"
#import "StarredFilterFormInfoCreator.h"

@implementation MailCleanerFormPopulator

-(void)populateAgeFilterInParentObj:(NSManagedObject*)parentObj
	withAgeFilterPropertyKey:(NSString*)ageFilterKey
	
{
	assert(parentObj != nil);
	assert([StringValidation nonEmptyString:ageFilterKey]);

	ManagedObjectFieldInfo *assignmentFieldInfo = [[[ManagedObjectFieldInfo alloc] 
		initWithManagedObject:parentObj
		andFieldKey:ageFilterKey 
		andFieldLabel:LOCALIZED_STR(@"MESSAGE_AGE_TITLE")
		andFieldPlaceholder:LOCALIZED_STR(@"MESSAGE_AGE_FILTER_PROMPT")] autorelease];

	AgeFilterFormInfoCreator *ageFilterFormInfoCreator = 
		[[[AgeFilterFormInfoCreator alloc] init] autorelease];
	
	SelectableObjectTableViewControllerFactory *ageFilterViewFactory = 
		[[[SelectableObjectTableViewControllerFactory alloc] initWithFormInfoCreator:ageFilterFormInfoCreator 
			andAssignedField:assignmentFieldInfo] autorelease];
	ageFilterViewFactory.closeAfterSelection = TRUE;
	
	AgeFilter *ageFilter = (AgeFilter*)[parentObj valueForKey:ageFilterKey];
	assert(ageFilter != nil);
			
	
	StaticNavFieldEditInfo *messageAgeFieldEditInfo = 
		[[[StaticNavFieldEditInfo alloc] 
			initWithCaption:LOCALIZED_STR(@"MESSAGE_AGE_TITLE")
			andSubtitle:LOCALIZED_STR(@"MESSAGE_AGE_SUBTITLE") 
			andContentDescription:[ageFilter filterSynopsis]
			andSubViewFactory:ageFilterViewFactory] autorelease];
	[self.currentSection addFieldEditInfo:messageAgeFieldEditInfo];		

}


-(void)populateReadFilterInParentObj:(NSManagedObject*)parentObj
	withReadFilterPropertyKey:(NSString*)readFilterKey
{
	
	ManagedObjectFieldInfo *assignmentFieldInfo = [[[ManagedObjectFieldInfo alloc] 
		initWithManagedObject:parentObj
		andFieldKey:readFilterKey 
		andFieldLabel:LOCALIZED_STR(@"MESSAGE_READ_FILTER_TITLE")
		andFieldPlaceholder:@"N/A"] autorelease];

	ReadFilterFormInfoCreator *readFilterFormInfoCreator = 
		[[[ReadFilterFormInfoCreator alloc] init] autorelease];
	
	SelectableObjectTableViewControllerFactory *readFilterViewFactory = 
		[[[SelectableObjectTableViewControllerFactory alloc] initWithFormInfoCreator:readFilterFormInfoCreator 
			andAssignedField:assignmentFieldInfo] autorelease];
	readFilterViewFactory.closeAfterSelection = TRUE;
	
	ReadFilter *readFilter = (ReadFilter*)[parentObj valueForKey:readFilterKey];
	assert(readFilter != nil);
	
	StaticNavFieldEditInfo *messageAgeFieldEditInfo = 
		[[[StaticNavFieldEditInfo alloc] 
			initWithCaption:LOCALIZED_STR(@"EMAIL_READ_FILTER_FIELD_CAPTION")
			andSubtitle:LOCALIZED_STR(@"EMAIL_READ_FILTER_FIELD_SUBTITLE") 
			andContentDescription:[readFilter filterSynopsis]
			andSubViewFactory:readFilterViewFactory] autorelease];
	[self.currentSection addFieldEditInfo:messageAgeFieldEditInfo];
}

-(void)populateStarredFilterInParentObj:(NSManagedObject*)parentObj
	withStarredFilterPropertyKey:(NSString*)starredFilterKey
{
	
	ManagedObjectFieldInfo *assignmentFieldInfo = [[[ManagedObjectFieldInfo alloc] 
		initWithManagedObject:parentObj
		andFieldKey:starredFilterKey 
		andFieldLabel:LOCALIZED_STR(@"EMAIL_STARRED_FILTER_TITLE")
		andFieldPlaceholder:@"N/A"] autorelease];

	StarredFilterFormInfoCreator *starredFilterFormInfoCreator = 
		[[[StarredFilterFormInfoCreator alloc] init] autorelease];
	
	SelectableObjectTableViewControllerFactory *starredFilterViewFactory = 
		[[[SelectableObjectTableViewControllerFactory alloc] initWithFormInfoCreator:starredFilterFormInfoCreator 
			andAssignedField:assignmentFieldInfo] autorelease];
	starredFilterViewFactory.closeAfterSelection = TRUE;
	
	StarredFilter *starredFilter = (StarredFilter*)[parentObj valueForKey:starredFilterKey];
	assert(starredFilter != nil);
	
	StaticNavFieldEditInfo *messageAgeFieldEditInfo = 
		[[[StaticNavFieldEditInfo alloc] 
			initWithCaption:LOCALIZED_STR(@"EMAIL_STARRED_FILTER_FIELD_CAPTION")
			andSubtitle:LOCALIZED_STR(@"EMAIL_STARRED_FILTER_FIELD_SUBTITLE") 
			andContentDescription:[starredFilter filterSynopsis]
			andSubViewFactory:starredFilterViewFactory] autorelease];
	[self.currentSection addFieldEditInfo:messageAgeFieldEditInfo];
}

-(void)populateEmailAddressFilter:(EmailAddressFilter*)emailAddressFilter
{
	EmailAddressFilterFormInfoCreator *addrFilterFormInfoCreator = 
		[[[EmailAddressFilterFormInfoCreator alloc] 
			initWithEmailAddressFilter:emailAddressFilter] autorelease];

	StaticNavFieldEditInfo *messageAddrFieldEditInfo = 
		[[[StaticNavFieldEditInfo alloc] 
			initWithCaption:[emailAddressFilter fieldCaption]
		andSubtitle:[emailAddressFilter subFilterSynopsis]
		andContentDescription:[emailAddressFilter filterSynopsisShort]
		andSubFormInfoCreator:addrFilterFormInfoCreator] autorelease];
		
	[self.currentSection addFieldEditInfo:messageAddrFieldEditInfo];
}

-(void)populateEmailDomainFilter:(EmailDomainFilter*)emailDomainFilter
{
	EmailDomainFilterFormInfoCreator *domainFilterFormInfoCreator = 
		[[[EmailDomainFilterFormInfoCreator alloc]
			initWithEmailDomainFilter:emailDomainFilter] autorelease];

	StaticNavFieldEditInfo *messageDomainFieldEditInfo = 
		[[[StaticNavFieldEditInfo alloc] 
			initWithCaption:LOCALIZED_STR(@"EMAIL_DOMAIN_TITLE") 
		andSubtitle:[emailDomainFilter subFilterSynopsis]
		andContentDescription:[emailDomainFilter filterSynopsisShort]
		andSubFormInfoCreator:domainFilterFormInfoCreator] autorelease];
		
	[self.currentSection addFieldEditInfo:messageDomainFieldEditInfo];
	
}

-(void)populateEmailFolderFilter:(EmailFolderFilter*)emailFolderFilter
{
	EmailFolderFilterFormInfoCreator *folderFilterFormInfoCreator = 
		[[[EmailFolderFilterFormInfoCreator alloc]
			initWithEmailFolderFilter:emailFolderFilter] autorelease];

	StaticNavFieldEditInfo *messageFolderFieldEditInfo = 
		[[[StaticNavFieldEditInfo alloc] 
			initWithCaption:LOCALIZED_STR(@"EMAIL_FOLDER_TITLE") 
		andSubtitle:[emailFolderFilter subFilterSynopsis]
		andContentDescription:[emailFolderFilter filterSynopsisShort]
		andSubFormInfoCreator:folderFilterFormInfoCreator] autorelease];
		
	[self.currentSection addFieldEditInfo:messageFolderFieldEditInfo];

}



@end
