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

NSString * const MESSAGE_FILTER_ENTITY_NAME = @"MessageFilter";
NSString * const MESSAGE_FILTER_AGE_FILTER_KEY = @"ageFilter";

@implementation MessageFilter

@dynamic filterName;
@dynamic ageFilter;
@dynamic emailDomainFilter;
@dynamic folderFilter;
@dynamic recipientAddressFilter;
@dynamic fromAddressFilter;

// Inverse
@dynamic emailAcctMsgListFilter;

+(MessageFilter*)defaultMessageFilter:(DataModelController*)filterDmc
{
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:filterDmc];

	MessageFilter *msgListFilter = (MessageFilter*)[filterDmc insertObject:MESSAGE_FILTER_ENTITY_NAME];
	msgListFilter.ageFilter = sharedVals.defaultAgeFilterNone;
	msgListFilter.fromAddressFilter = (FromAddressFilter*)
		[filterDmc insertObject:FROM_ADDRESS_FILTER_ENTITY_NAME];
	msgListFilter.recipientAddressFilter = (RecipientAddressFilter*)
		[filterDmc insertObject:RECIPIENT_ADDRESS_FILTER_ENTITY_NAME];
	msgListFilter.emailDomainFilter = (EmailDomainFilter*)
		[filterDmc insertObject:EMAIL_DOMAIN_FILTER_ENTITY_NAME];
	msgListFilter.folderFilter = (EmailFolderFilter*)
		[filterDmc insertObject:EMAIL_FOLDER_FILTER_ENTITY_NAME];
		
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

	NSPredicate *emailDomainPredicate = [self.emailDomainFilter filterPredicate];
	assert(emailDomainPredicate != nil);
	[predicates addObject:emailDomainPredicate];
	
	NSPredicate *emailFolderPredicate = [self.folderFilter filterPredicate];
	assert(emailFolderPredicate != nil);
	[predicates addObject:emailFolderPredicate];
		
	NSPredicate *compoundPredicate = [NSCompoundPredicate 
			andPredicateWithSubpredicates:predicates];
	return compoundPredicate;
}

-(void)resetToDefault:(DataModelController*)filterDmc
{
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:filterDmc];
	
	self.ageFilter = sharedVals.defaultAgeFilterNone;
	
	[filterDmc deleteObject:self.fromAddressFilter];
	self.fromAddressFilter = (FromAddressFilter*)
		[filterDmc insertObject:FROM_ADDRESS_FILTER_ENTITY_NAME];
		
	[filterDmc deleteObject:self.recipientAddressFilter];
	self.recipientAddressFilter = (RecipientAddressFilter*)
		[filterDmc insertObject:RECIPIENT_ADDRESS_FILTER_ENTITY_NAME];
		
	[filterDmc deleteObject:self.emailDomainFilter];
	self.emailDomainFilter = (EmailDomainFilter*)
		[filterDmc insertObject:EMAIL_DOMAIN_FILTER_ENTITY_NAME];
		
	[filterDmc deleteObject:self.folderFilter];
	self.folderFilter = (EmailFolderFilter*)
		[filterDmc insertObject:EMAIL_FOLDER_FILTER_ENTITY_NAME];

}

-(NSString*)filterSynopsis
{
	NSMutableArray *synopsisParts = [[[NSMutableArray alloc] init] autorelease];
	
	[synopsisParts addObject:[self.ageFilter filterSynopsis]];
	[synopsisParts addObject:[self.fromAddressFilter filterSynopsis]];
	[synopsisParts addObject:[self.recipientAddressFilter filterSynopsis]];	
	[synopsisParts addObject:[self.emailDomainFilter filterSynopsis]];
	[synopsisParts addObject:[self.folderFilter filterSynopsis]];
	
	return [synopsisParts componentsJoinedByString:@", "];
	
}

@end
