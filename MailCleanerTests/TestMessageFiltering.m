//
//  TestMessageFiltering.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestMessageFiltering.h"
#import "DataModelController.h"
#import "AppHelper.h"
#import "SharedAppVals.h"
#import "EmailInfo.h"
#import "DateHelper.h"
#import "MsgPredicateHelper.h"
#import "CoreDataHelper.h"
#import "MessageFilter.h"
#import "AgeFilter.h"
#import "AgeFilterComparison.h"
#import "AgeFilterNone.h"
#import "TrashRule.h"
#import "FolderInfo.h"
#import "ExclusionRule.h"
#import "EmailAddress.h"
#import "EmailAddressFilter.h"
#import "EmailDomain.h"
#import "EmailDomainFilter.h"
#import "MailAddressHelper.h"
#import "EmailFolder.h"
#import "EmailFolderFilter.h"

@implementation TestMessageFiltering

@synthesize testAppVals;
@synthesize appDataDmc;
@synthesize emailInfoDmc;
@synthesize testFolder;

- (void)setUp
{
    [super setUp];
	
    // Set-up code here.
}

-(void)populateTestEmailWithSendDate:(NSString*)sendDate 
	andSubject:(NSString*)subject andFrom:(NSString*)fromSender
	andFolder:(NSString*)folderName
{
	EmailInfo *newEmailInfo = (EmailInfo*) [self.emailInfoDmc insertObject:EMAIL_INFO_ENTITY_NAME];
	newEmailInfo.sendDate = [DateHelper dateFromStr:sendDate];
	newEmailInfo.from = fromSender;
	newEmailInfo.subject = subject;
	newEmailInfo.messageId = [NSString stringWithFormat:@"MSG%06d",currMessageId];
	newEmailInfo.folderInfo = self.testFolder;
	newEmailInfo.folder = folderName;
	newEmailInfo.domain = [MailAddressHelper emailAddressDomainName:fromSender];
	currMessageId ++;
	[self.emailInfoDmc saveContext];
}

-(void)populateTestEmailWithSendDate:(NSString*)sendDate 
	andSubject:(NSString*)subject andFrom:(NSString*)fromSender
{
	[self populateTestEmailWithSendDate:sendDate andSubject:subject andFrom:fromSender andFolder:@"INBOX"];
}

-(void)populateFolderTestEmailWithSendDate:(NSString*)sendDate
	andSubject:(NSString*)subject andFrom:(NSString*)fromSender andFolder:(NSString*)folderName
{
	[self populateTestEmailWithSendDate:sendDate andSubject:subject 
		andFrom:fromSender andFolder:folderName];
}

// ------------------

-(void)resetCoreData
{
	self.appDataDmc = [[[DataModelController alloc] 
			initForInMemoryStorageWithDataModelNamed:APP_DATA_DATA_MODEL_NAME 
			andStoreNamed:APP_DATA_STORE_NAME] autorelease];
			
	self.testAppVals = [SharedAppVals createWithDataModelController:self.appDataDmc];
	
	
	self.emailInfoDmc = [[[DataModelController alloc] 
			initForInMemoryStorageWithDataModelNamed:EMAIL_INFO_DATA_MODEL_NAME 
			andStoreNamed:EMAIL_INFO_STORE_NAME] autorelease];

	self.testFolder = (FolderInfo*)[self.emailInfoDmc insertObject:FOLDER_INFO_ENTITY_NAME];
	self.testFolder.fullyQualifiedName = @"TESTINBOX";
			
	currMessageId = 0;
}

-(void)checkFilteredEmailsInfos:(NSArray*)expectedSubjects 
	andFilterPredicate:(NSPredicate*)msgFilterPredicate
{

	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_INFO_ENTITY_NAME 
		inManagedObjectContext:self.emailInfoDmc.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:msgFilterPredicate];	
	
	NSArray *msgsMatchingFilter = 
		[CoreDataHelper executeFetchOrThrow:fetchRequest 
		inManagedObectContext:self.emailInfoDmc.managedObjectContext];

	NSMutableSet *subjectsInResults = [[[NSMutableSet alloc] init] autorelease];
	for(EmailInfo *emailInfo in msgsMatchingFilter)
	{
		[subjectsInResults addObject:emailInfo.subject];
	}


	for(NSString *expectedSubject in expectedSubjects)
	{
		STAssertTrue([subjectsInResults containsObject:expectedSubject],
			@"Subject %@ expected to be in results",expectedSubject);
		[subjectsInResults removeObject:expectedSubject];
	}
	
	// Once all the expected subjects have been checked against the 
	// results, there should be no matching subjects left. If there are,
	// this means there are unexpected subjects in the results.
	STAssertTrue([subjectsInResults count] == 0,
		@"Unexpected subjects in results: %@",[[subjectsInResults allObjects] componentsJoinedByString:@","]);
}

- (void)tearDown
{
    // Tear-down code here.
	
	[appDataDmc release];
	[emailInfoDmc release];
	[testAppVals release];
	[testFolder release];
    
    [super tearDown];
}


- (void)testMessageFilter
{
	[self resetCoreData];
	
	[self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-12-30" andSubject:@"S02" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2011-12-30" andSubject:@"S03" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2010-01-01" andSubject:@"S04" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2009-01-01" andSubject:@"S05" andFrom:@"jane"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];

	self.testAppVals.msgListFilter.ageFilter = testAppVals.defaultAgeFilterNewer1Year;
	NSPredicate *filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S02", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	self.testAppVals.msgListFilter.ageFilter = testAppVals.defaultAgeFilterNewer3Months;
	filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S02", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	self.testAppVals.msgListFilter.ageFilter = testAppVals.defaultAgeFilterOlder1Year;
	filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S03",@"S04",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	self.testAppVals.msgListFilter.ageFilter = testAppVals.defaultAgeFilterNone;
	filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S02",@"S03",@"S04",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}

- (void)testEmailAddressFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	[self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-02-01" andSubject:@"S02" andFrom:@"bob"];
	[self populateTestEmailWithSendDate:@"2012-03-01" andSubject:@"S03" andFrom:@"dan"];
	[self populateTestEmailWithSendDate:@"2012-04-01" andSubject:@"S04" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-05-01" andSubject:@"S05" andFrom:@"sally"];

	// Filtering for Jane should include S01 and S04
	EmailAddress *janeEmailAddr = (EmailAddress*)[self.appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
	janeEmailAddr.address = @"jane";
	[self.testAppVals.msgListFilter.emailAddressFilter addSelectedAddressesObject:janeEmailAddr];
	NSPredicate *filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S04", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
	// Also filtering for Dan should additionally include S03
	EmailAddress *danEmailAddr = (EmailAddress*)[self.appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
	danEmailAddr.address = @"dan";
	[self.testAppVals.msgListFilter.emailAddressFilter addSelectedAddressesObject:danEmailAddr];
	filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S03",@"S04", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];


	// Filtering for Steve shouldn't change the results, since there are no messages from Steve
	EmailAddress *steveEmailAddr = (EmailAddress*)[self.appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
	steveEmailAddr.address = @"steve";
	[self.testAppVals.msgListFilter.emailAddressFilter addSelectedAddressesObject:danEmailAddr];
	filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S03",@"S04", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	
}

- (void)testInvertedEmailAddressFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	[self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-02-01" andSubject:@"S02" andFrom:@"bob"];
	[self populateTestEmailWithSendDate:@"2012-03-01" andSubject:@"S03" andFrom:@"dan"];
	[self populateTestEmailWithSendDate:@"2012-04-01" andSubject:@"S04" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-05-01" andSubject:@"S05" andFrom:@"sally"];

	EmailAddress *janeEmailAddr = (EmailAddress*)[self.appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
	janeEmailAddr.address = @"jane";
	[self.testAppVals.msgListFilter.emailAddressFilter addSelectedAddressesObject:janeEmailAddr];
	
	EmailAddress *danEmailAddr = (EmailAddress*)[self.appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
	danEmailAddr.address = @"dan";
	[self.testAppVals.msgListFilter.emailAddressFilter addSelectedAddressesObject:danEmailAddr];

	// Invert the selection
	self.testAppVals.msgListFilter.emailAddressFilter.matchUnselected = [NSNumber numberWithBool:TRUE];
	
	// Filtering for address other than Jane or Dan should include S02,S05
	NSPredicate *filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S02",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}



- (void)testEmailDomainFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	[self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane@localdomain"];
	[self populateTestEmailWithSendDate:@"2012-02-01" andSubject:@"S02" andFrom:@"bob@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-03-01" andSubject:@"S03" andFrom:@"dan@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-04-01" andSubject:@"S04" andFrom:@"jane@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-05-01" andSubject:@"S05" andFrom:@"sally@localdomain"];

	// Filtering email addresses with the localdomain should include S01 and S05.
	EmailDomain *localDomain = (EmailDomain*)[self.appDataDmc insertObject:EMAIL_DOMAIN_ENTITY_NAME];
	localDomain.domainName = @"localdomain";
	[self.testAppVals.msgListFilter.emailDomainFilter addSelectedDomainsObject:localDomain];
	
	NSPredicate *filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}

- (void)testInvertedEmailDomainFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	[self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane@localdomain"];
	[self populateTestEmailWithSendDate:@"2012-02-01" andSubject:@"S02" andFrom:@"bob@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-03-01" andSubject:@"S03" andFrom:@"dan@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-04-01" andSubject:@"S04" andFrom:@"jane@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-05-01" andSubject:@"S05" andFrom:@"sally@localdomain"];

	// Filtering email addresses with the localdomain should include S01 and S05.
	EmailDomain *localDomain = (EmailDomain*)[self.appDataDmc insertObject:EMAIL_DOMAIN_ENTITY_NAME];
	localDomain.domainName = @"localdomain";
	[self.testAppVals.msgListFilter.emailDomainFilter addSelectedDomainsObject:localDomain];
	
	testAppVals.msgListFilter.emailDomainFilter.matchUnselected = [NSNumber numberWithBool:TRUE];
	
	NSPredicate *filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S02",@"S03",@"S04", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}



- (void)testEmailFolderFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S01" 
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S02" 
		andFrom:@"jane@localdomain" andFolder:@"MYFOLDER"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S03"
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];

	// Filtering email addresses with the localdomain should include S01 and S05.
	EmailFolder *inbox = (EmailFolder*)[self.appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
	inbox.folderName = @"INBOX";
	[self.testAppVals.msgListFilter.folderFilter addSelectedFoldersObject:inbox];
	
	NSPredicate *filterPredicate = [self.testAppVals.msgListFilter filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S03", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}


- (void)testTrashRule
{
	[self resetCoreData];
	
	[self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-12-30" andSubject:@"S02" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2011-12-30" andSubject:@"S03" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2010-01-01" andSubject:@"S04" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2009-01-01" andSubject:@"S05" andFrom:@"jane"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule = [TrashRule createNewDefaultRule:self.appDataDmc];

	// Don't trash anything
	trashRule.ageFilter = self.testAppVals.defaultAgeFilterNone;
	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S02",@"S03",@"S04",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
	// Trash messages older than 1 year
	trashRule.ageFilter = self.testAppVals.defaultAgeFilterOlder1Year;
	filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S03",@"S04",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
}


- (void)testExclusionRule
{
	[self resetCoreData];
	
	[self populateTestEmailWithSendDate:@"2012-10-15" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-09-15" andSubject:@"S02" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2011-12-30" andSubject:@"S03" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2010-01-01" andSubject:@"S04" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2009-01-01" andSubject:@"S05" andFrom:@"jane"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule = [TrashRule createNewDefaultRule:self.appDataDmc];
	ExclusionRule *exclusionRule = [ExclusionRule createNewDefaultRule:self.appDataDmc];

	// Trashing older than 3 months includes - S02, S03, S04, S05
	// Excluding newer than 6 months includes - S01, S02
	// The results should be S03, S04, S05 (S02 got excluded)
	trashRule.ageFilter = self.testAppVals.defaultAgeFilterOlder3Months;
	exclusionRule.ageFilter = self.testAppVals.defaultAgeFilterNewer6Months;
	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S03",@"S04",@"S05",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
	// Disable the exclusion rule, so S02 should come back into the results
	exclusionRule.enabled = [NSNumber numberWithBool:FALSE];
	filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S02",@"S03",@"S04",@"S05",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	// Also disable the trash rule, so no messages should be trashed
	trashRule.enabled = [NSNumber numberWithBool:FALSE];
	filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];


	// Re-enabling the trash rule shouldn't have any effect, since the trash rule is still disabled
	exclusionRule.enabled = [NSNumber numberWithBool:TRUE];
	filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	
}


- (void)testMultipleTrashRules
{
	[self resetCoreData];
	
	[self populateTestEmailWithSendDate:@"2012-12-30" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-10-15" andSubject:@"S02" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-09-15" andSubject:@"S03" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-01-02" andSubject:@"S05" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2011-12-30" andSubject:@"S05" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2009-01-01" andSubject:@"S06" andFrom:@"jane"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule01 = [TrashRule createNewDefaultRule:self.appDataDmc];
	TrashRule *trashRule02 = [TrashRule createNewDefaultRule:self.appDataDmc];

	trashRule01.ageFilter = self.testAppVals.defaultAgeFilterOlder1Year;
	trashRule02.ageFilter = self.testAppVals.defaultAgeFilterNewer3Months;
	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S02",@"S05",@"S06",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
}


- (void)testDisabledTrashRule
{
	[self resetCoreData];
	
	[self populateTestEmailWithSendDate:@"2012-12-30" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-10-15" andSubject:@"S02" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-09-15" andSubject:@"S03" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-01-02" andSubject:@"S05" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2011-12-30" andSubject:@"S05" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2009-01-01" andSubject:@"S06" andFrom:@"jane"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule01 = [TrashRule createNewDefaultRule:self.appDataDmc];

	trashRule01.ageFilter = self.testAppVals.defaultAgeFilterOlder1Year;
	trashRule01.enabled = [NSNumber numberWithBool:FALSE];
	
	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}


- (void)testTrashRuleWithEmailAddressFilter
{
	[self resetCoreData];
	
	[self populateTestEmailWithSendDate:@"2012-12-30" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-10-15" andSubject:@"S02" andFrom:@"bob"];
	[self populateTestEmailWithSendDate:@"2012-09-15" andSubject:@"S03" andFrom:@"dan"];
	[self populateTestEmailWithSendDate:@"2012-01-02" andSubject:@"S05" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2011-12-30" andSubject:@"S05" andFrom:@"sally"];
	[self populateTestEmailWithSendDate:@"2009-01-01" andSubject:@"S06" andFrom:@"steve"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule01 = [TrashRule createNewDefaultRule:self.appDataDmc];


	EmailAddress *janeEmailAddr = (EmailAddress*)[self.appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
	janeEmailAddr.address = @"jane";
	
	[trashRule01.emailAddressFilter addSelectedAddressesObject:janeEmailAddr];
	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
}


- (void)testTrashRuleWithDomainFilter
{
	[self resetCoreData];
	
	[self populateTestEmailWithSendDate:@"2012-12-30" andSubject:@"S01" andFrom:@"jane@localdomain"];
	[self populateTestEmailWithSendDate:@"2012-10-15" andSubject:@"S02" andFrom:@"bob@nonlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-09-15" andSubject:@"S03" andFrom:@"dan@localdomain"];
	[self populateTestEmailWithSendDate:@"2012-01-02" andSubject:@"S05" andFrom:@"jane@nonlocaldomain"];
	[self populateTestEmailWithSendDate:@"2011-12-30" andSubject:@"S05" andFrom:@"sally@nonlocaldomain"];
	[self populateTestEmailWithSendDate:@"2009-01-01" andSubject:@"S06" andFrom:@"steve@nonlocaldomain"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule01 = [TrashRule createNewDefaultRule:self.appDataDmc];

	// Filtering email addresses with the localdomain should include S01 and S03.
	EmailDomain *localDomain = (EmailDomain*)[self.appDataDmc insertObject:EMAIL_DOMAIN_ENTITY_NAME];
	localDomain.domainName = @"localdomain";
	[trashRule01.emailDomainFilter addSelectedDomainsObject:localDomain];

	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S03", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
}


- (void)testTrashRuleWithFolderFilter
{
	[self resetCoreData];
	
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S01" 
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S02" 
		andFrom:@"jane@localdomain" andFolder:@"MYFOLDER"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S03"
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule01 = [TrashRule createNewDefaultRule:self.appDataDmc];

	// Filtering email by the INBOX folder should result in S01 and S03
	EmailFolder *inbox = (EmailFolder*)[self.appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
	inbox.folderName = @"INBOX";
	[trashRule01.folderFilter addSelectedFoldersObject:inbox];

	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S03", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
}



- (void)testExclusionRuleWithAddressFiltering
{
	[self resetCoreData];
	
	[self populateTestEmailWithSendDate:@"2012-10-15" andSubject:@"S01" andFrom:@"bob"];
	[self populateTestEmailWithSendDate:@"2012-09-15" andSubject:@"S02" andFrom:@"bob"];
	[self populateTestEmailWithSendDate:@"2011-12-30" andSubject:@"S03" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2010-01-01" andSubject:@"S04" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2009-01-01" andSubject:@"S05" andFrom:@"jane"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule = [TrashRule createNewDefaultRule:self.appDataDmc];
	ExclusionRule *exclusionRule = [ExclusionRule createNewDefaultRule:self.appDataDmc];

	// Trashing older than 3 months includes - S02, S03, S04, S05
	trashRule.ageFilter = self.testAppVals.defaultAgeFilterOlder3Months;
	
	// Excluding messages sent from "bob" includes - S01, S02
	// The results should be S03, S04, S05 (S02 got excluded)
	EmailAddress *bobEmailAddress = (EmailAddress*)[self.appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
	bobEmailAddress.address = @"bob";
	[exclusionRule.emailAddressFilter addSelectedAddressesObject:bobEmailAddress];

	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S03",@"S04",@"S05",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
		
}

- (void)testExclusionRuleWithDomainFiltering
{
	[self resetCoreData];
	
	[self populateTestEmailWithSendDate:@"2012-12-30" andSubject:@"S01" andFrom:@"jane@localdomain"];
	[self populateTestEmailWithSendDate:@"2012-06-15" andSubject:@"S02" andFrom:@"bob@localdomain"];
	[self populateTestEmailWithSendDate:@"2012-04-15" andSubject:@"S03" andFrom:@"dan@nonlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-01-02" andSubject:@"S04" andFrom:@"jane@nonlocaldomain"];
	[self populateTestEmailWithSendDate:@"2011-12-30" andSubject:@"S05" andFrom:@"sally@nonlocaldomain"];
	[self populateTestEmailWithSendDate:@"2009-01-01" andSubject:@"S06" andFrom:@"steve@nonlocaldomain"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule = [TrashRule createNewDefaultRule:self.appDataDmc];
	ExclusionRule *exclusionRule = [ExclusionRule createNewDefaultRule:self.appDataDmc];

	// Trashing older than 3 months includes - S02, S03, S04, S05, S06
	trashRule.ageFilter = self.testAppVals.defaultAgeFilterOlder3Months;
	
	// Excluding messages sent from "@localdomain" includes - S01, S02
	// The results should be S03, S04, S05,S06 (S02 got excluded)
	EmailDomain *localDomain = (EmailDomain*)[self.appDataDmc insertObject:EMAIL_DOMAIN_ENTITY_NAME];
	localDomain.domainName = @"localdomain";
	[exclusionRule.emailDomainFilter addSelectedDomainsObject:localDomain];

	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S03",@"S04",@"S05",@"S06",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
		
}


- (void)testExclusionRuleWithFolderFiltering
{
	[self resetCoreData];
	
	[self populateFolderTestEmailWithSendDate:@"2012-12-30" andSubject:@"S01" 
		andFrom:@"jane@localdomain" andFolder:@"SAVE"];
	[self populateFolderTestEmailWithSendDate:@"2012-10-02" andSubject:@"S02" 
		andFrom:@"jane@localdomain" andFolder:@"SAVE"];
	[self populateFolderTestEmailWithSendDate:@"2012-08-02" andSubject:@"S03"
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	[self populateFolderTestEmailWithSendDate:@"2012-07-02" andSubject:@"S04"
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	[self populateFolderTestEmailWithSendDate:@"2012-06-02" andSubject:@"S05"
		andFrom:@"jane@localdomain" andFolder:@"SAVE"];
	[self populateFolderTestEmailWithSendDate:@"2012-05-02" andSubject:@"S06"
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	
	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	TrashRule *trashRule = [TrashRule createNewDefaultRule:self.appDataDmc];
	ExclusionRule *exclusionRule = [ExclusionRule createNewDefaultRule:self.appDataDmc];

	// Trashing older than 3 months includes - S03, S04, S05, S06
	trashRule.ageFilter = self.testAppVals.defaultAgeFilterOlder3Months;
	
	// Excluding messages belonging to the "SAVE" folder includes S01,S02,S05
	// The results should be S03, S04, S06 (S02,S05 got excluded)
	EmailFolder *saveFolder = (EmailFolder*)[self.appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
	saveFolder.folderName = @"SAVE";
	[exclusionRule.folderFilter addSelectedFoldersObject:saveFolder];

	NSPredicate *filterPredicate = [MsgPredicateHelper trashedByMsgRules:self.appDataDmc andBaseDate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S03",@"S04",@"S06",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
		
}




@end
