//
//  MessageFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilter.h"
#import "AgeFilter.h"
#import "EmailAddressFilter.h"
#import "EmailDomainFilter.h"
#import "RecipientAddressFilter.h"
#import "EmailFolderFilter.h"
#import "DataModelController.h"
#import "FromAddressFilter.h"
#import "RecipientAddressFilter.h"
#import "SharedAppVals.h"
#import "AgeFilterNone.h"
#import "EmailAccount.h"
#import "SubjectFilter.h"
#import "ReadFilter.h"
#import "StarredFilter.h"
#import "LocalizationHelper.h"
#import "RecipientDomainFilter.h"
#import "SenderDomainFilter.h"

NSString * const MESSAGE_FILTER_ENTITY_NAME = @"MessageFilter";
NSString * const MESSAGE_FILTER_AGE_FILTER_KEY = @"ageFilter";
NSString * const MESSAGE_FILTER_READ_FILTER_KEY = @"readFilter";
NSString * const MESSAGE_FILTER_STARRED_FILTER_KEY = @"starredFilter";
NSString * const MESSAGE_FILTER_NAME_KEY = @"filterName";
NSInteger const MESSAGE_FILTER_NAME_MAX_LENGTH = 32;

@implementation MessageFilter

@dynamic filterName;

@dynamic ageFilter;
@dynamic senderDomainFilter;
@dynamic recipientDomainFilter;

@dynamic folderFilter;
@dynamic recipientAddressFilter;
@dynamic fromAddressFilter;
@dynamic readFilter;
@dynamic starredFilter;
@dynamic subjectFilter;

@dynamic matchingMsgs;

// Inverse
@dynamic emailAcctMsgListFilter;
@dynamic emailAcctSavedFilter;

+(MessageFilter*)defaultMessageFilter:(DataModelController*)filterDmc
{
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:filterDmc];

	MessageFilter *msgListFilter = (MessageFilter*)[filterDmc insertObject:MESSAGE_FILTER_ENTITY_NAME];
	
	msgListFilter.ageFilter = sharedVals.defaultAgeFilterNone;
	
	msgListFilter.fromAddressFilter = (FromAddressFilter*)
		[filterDmc insertObject:FROM_ADDRESS_FILTER_ENTITY_NAME];
		
	msgListFilter.recipientAddressFilter = (RecipientAddressFilter*)
		[filterDmc insertObject:RECIPIENT_ADDRESS_FILTER_ENTITY_NAME];
		
	msgListFilter.senderDomainFilter = (SenderDomainFilter*)
		[filterDmc insertObject:SENDER_DOMAIN_FILTER_ENTITY_NAME];

	msgListFilter.recipientDomainFilter = (RecipientDomainFilter*)
		[filterDmc insertObject:RECIPIENT_DOMAIN_FILTER_ENTITY_NAME];

		
	msgListFilter.folderFilter = (EmailFolderFilter*)
		[filterDmc insertObject:EMAIL_FOLDER_FILTER_ENTITY_NAME];
		
	msgListFilter.subjectFilter = (SubjectFilter*)
		[filterDmc insertObject:SUBJECT_FILTER_ENTITY_NAME];
		
	msgListFilter.starredFilter = sharedVals.defaultStarredFilterStarredOrUnstarred;
	
	msgListFilter.readFilter = sharedVals.defaultReadFilterReadOrUnread;
		
	return msgListFilter;
}


-(NSPredicate*)filterPredicate:(NSDate*)baseDate
{
	NSMutableArray *predicates = [[[NSMutableArray alloc] init] autorelease];

	NSPredicate *agePredicate = [self.ageFilter filterPredicate:baseDate];
	assert(agePredicate != nil);
	[predicates addObject:agePredicate];

	NSPredicate *emailAddressPredicate = [self.fromAddressFilter filterPredicate];
	assert(emailAddressPredicate != nil);
	[predicates addObject:emailAddressPredicate];
	
	NSPredicate *recipientAddressPredicate = [self.recipientAddressFilter filterPredicate];
	assert(recipientAddressPredicate != nil);
	[predicates addObject:recipientAddressPredicate]; 

	NSPredicate *senderDomainPredicate = [self.senderDomainFilter filterPredicate];
	assert(senderDomainPredicate != nil);
	[predicates addObject:senderDomainPredicate];
	
// TODO - Include the following to implement recipient domain filter
//	NSPredicate *recipientDomainPredicate = [self.recipientDomainFilter filterPredicate];
//	assert(recipientDomainPredicate != nil);
//	[predicates addObject:recipientDomainPredicate];
	
	NSPredicate *emailFolderPredicate = [self.folderFilter filterPredicate];
	assert(emailFolderPredicate != nil);
	[predicates addObject:emailFolderPredicate];
	
	NSPredicate *readPredicate = [self.readFilter filterPredicate];
	assert(readPredicate != nil);
	[predicates addObject:readPredicate];
	
	NSPredicate *starredPredicate = [self.starredFilter filterPredicate];
	assert(starredPredicate != nil);
	[predicates addObject:starredPredicate];
	
	NSPredicate *subjectPredicate = [self.subjectFilter filterPredicate];
	assert(subjectPredicate != nil);
	[predicates addObject:subjectPredicate];
		
	NSPredicate *compoundPredicate = [NSCompoundPredicate 
			andPredicateWithSubpredicates:predicates];
	return compoundPredicate;
}

-(BOOL)nonEmptyFilterName
{
	return ((self.filterName != nil) && ([self.filterName length] > 0))?TRUE:FALSE;
}

-(void)resetFilterName
{
	if([self nonEmptyFilterName])
	{
		self.filterName = @"";
	}

}

-(void)resetToDefault:(DataModelController*)filterDmc
{
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:filterDmc];
	
	[self resetFilterName];
	
	self.ageFilter = sharedVals.defaultAgeFilterNone;
	
	[self.fromAddressFilter resetFilter];
	[self.recipientAddressFilter resetFilter];
	[self.senderDomainFilter resetFilter];
	
// TODO - Include the following to implement recipient domain filters
//	[self.recipientDomainFilter resetFilter];

	[self.folderFilter resetFilter];
	[self.subjectFilter resetFilter];

	self.starredFilter = sharedVals.defaultStarredFilterStarredOrUnstarred;
	
	self.readFilter = sharedVals.defaultReadFilterReadOrUnread;

}

-(NSString*)filterSynopsis
{
	NSMutableArray *synopsisParts = [[[NSMutableArray alloc] init] autorelease];
	
	if(![self.ageFilter filterMatchesAnyAge])
	{
		[synopsisParts addObject:[self.ageFilter filterSynopsis]];
	}
	
	if(![self.fromAddressFilter filterMatchesAnyAddress])
	{
		[synopsisParts addObject:[self.fromAddressFilter filterSynopsis]];
	}
	
	if(![self.recipientAddressFilter filterMatchesAnyAddress])
	{
		[synopsisParts addObject:[self.recipientAddressFilter filterSynopsis]];
	}
	
	if(![self.subjectFilter filterMatchesAnySubject])
	{
		[synopsisParts addObject:[self.subjectFilter filterSynopsis]];	
	}
	
	if(![self.senderDomainFilter filterMatchesAnyDomain])
	{
		[synopsisParts addObject:[self.senderDomainFilter filterSynopsis]];
	}

// TODO - Include the following to implement recipient domain filters
//	if(![self.recipientDomainFilter filterMatchesAnyDomain])
//	{
//		[synopsisParts addObject:[self.recipientDomainFilter filterSynopsis]];
//	}

	if(![self.folderFilter filterMatchesAnyFolder])
	{
		[synopsisParts addObject:[self.folderFilter filterSynopsis]];
	}
	
	if(![self.readFilter filterMatchesAnyReadStatus])
	{
		[synopsisParts addObject:[self.readFilter filterSynopsis]];
	}
	
	if(![self.starredFilter filterMatchesAnyStarredStatus])
	{
		[synopsisParts addObject:[self.starredFilter filterSynopsis]];
	}
	
	if([synopsisParts count] > 0)
	{
		return [synopsisParts componentsJoinedByString:@", "];
	}
	else 
	{
		return LOCALIZED_STR(@"MESSAGE_FILTER_NO_FILTERING_SYNOPSIS");
	}
}

-(BOOL)matchesAnyMessage
{

	if(	[self.ageFilter filterMatchesAnyAge] &&
		[self.fromAddressFilter filterMatchesAnyAddress] &&
		[self.recipientAddressFilter filterMatchesAnyAddress] &&
		[self.subjectFilter filterMatchesAnySubject] &&
		[self.senderDomainFilter filterMatchesAnyDomain] &&
// TODO - Include the following to implement recipient domain filters
//		[self.recipientDomainFilter filterMatchesAnyDomain] &&
		[self.folderFilter filterMatchesAnyFolder] &&
		[self.readFilter filterMatchesAnyReadStatus] &&
		[self.starredFilter filterMatchesAnyStarredStatus])
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}


@end
