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
#import "MsgHandlingRule.h"
#import "EmailFolderFilterFormInfoCreator.h"

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


-(void)populateRuleEnabled:(MsgHandlingRule*)theRule withSubtitle:(NSString*)subTitle
{

	assert(theRule != nil);

	ManagedObjectFieldInfo *ruleEnabledFieldInfo = [[[ManagedObjectFieldInfo alloc] 
			initWithManagedObject:theRule 
			andFieldKey:RULE_ENABLED_KEY 
			andFieldLabel:LOCALIZED_STR(@"RULE_ENABLED_FIELD_LABEL") 
			andFieldPlaceholder:@"N/A"] autorelease];
	BoolFieldEditInfo *ruleEnabledFieldEditInfo = 
		[[[BoolFieldEditInfo alloc] initWithFieldInfo:ruleEnabledFieldInfo
			andSubtitle:subTitle] autorelease];
	[self.currentSection addFieldEditInfo:ruleEnabledFieldEditInfo];

}

@end
