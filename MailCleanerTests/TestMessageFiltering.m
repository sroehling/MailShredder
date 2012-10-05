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
#import "FromAddressFilter.h"
#import "EmailAddress.h"
#import "EmailAddressFilter.h"
#import "EmailDomain.h"
#import "EmailDomainFilter.h"
#import "MailAddressHelper.h"
#import "EmailFolder.h"
#import "EmailFolderFilter.h"
#import "EmailAddress.h"
#import "RecipientAddressFilter.h"
#import "EmailAccount.h"
#import "SubjectFilter.h"
#import "SenderDomainFilter.h"

@implementation TestMessageFiltering

@synthesize testAppVals;
@synthesize appDataDmc;
@synthesize testFolder;

- (void)setUp
{
    [super setUp];
	
    // Set-up code here.
}



-(EmailInfo*)populateTestEmailWithSendDate:(NSString*)sendDate 
	andSubject:(NSString*)subject andFrom:(NSString*)fromSender
	andFolder:(NSString*)folderName andRecipientAddress:(NSString*)recipientAddr
{
	EmailInfo *newEmailInfo = (EmailInfo*) [self.appDataDmc insertObject:EMAIL_INFO_ENTITY_NAME];
	newEmailInfo.sendDate = [DateHelper dateFromStr:sendDate];

	NSMutableDictionary *currEmailAddressByAddress = [self.testAppVals.currentEmailAcct emailAddressesByName];
	
	newEmailInfo.senderAddress = [EmailAddress findOrAddAddress:fromSender 
					withName:@"" andSendDate:[DateHelper dateFromStr:sendDate]
					withCurrentAddresses:currEmailAddressByAddress 
					inDataModelController:self.appDataDmc
					andEmailAcct:self.testAppVals.currentEmailAcct
					andIsRecipientAddr:FALSE andIsSenderAddr:TRUE];
					
	newEmailInfo.subject = subject;
	newEmailInfo.uid = [NSNumber numberWithInt:currMessageId];
	
	NSUInteger dummySize = 32;
	newEmailInfo.size = [NSNumber numberWithUnsignedInt:dummySize];
	
	NSMutableDictionary *currFoldersByName = [self.testAppVals.currentEmailAcct foldersByName];
	newEmailInfo.folderInfo = [EmailFolder findOrAddFolder:folderName
		inExistingFolders:currFoldersByName withDataModelController:self.appDataDmc
		andFolderAcct:self.testAppVals.currentEmailAcct];
	
	
	NSMutableDictionary *currDomainsByName = [self.testAppVals.currentEmailAcct emailDomainsByDomainName];
	newEmailInfo.senderDomain = [EmailDomain findOrAddDomainName:[MailAddressHelper 
			emailAddressDomainName:fromSender] withCurrentDomains:currDomainsByName
			inDataModelController:self.appDataDmc 
			andEmailAcct:self.testAppVals.currentEmailAcct
			andIsRecipientDomain:FALSE andIsSenderDomain:TRUE];
	
	
	newEmailInfo.emailAcct = testAppVals.currentEmailAcct;
	
	EmailAddress *recipientAddress = [EmailAddress findOrAddAddress:recipientAddr 
						withName:@"" andSendDate:[DateHelper dateFromStr:sendDate]
					withCurrentAddresses:currEmailAddressByAddress 
					inDataModelController:self.appDataDmc
					andEmailAcct:self.testAppVals.currentEmailAcct
					andIsRecipientAddr:TRUE andIsSenderAddr:FALSE];
	[newEmailInfo addRecipientAddressesObject:recipientAddress];
	
	newEmailInfo.isRead = [NSNumber numberWithBool:TRUE];
	newEmailInfo.isStarred = [NSNumber numberWithBool:FALSE];

	currMessageId ++;
	[self.appDataDmc saveContext];
	
	return newEmailInfo;
}

-(EmailInfo*)populateTestEmailWithSendDate:(NSString*)sendDate 
	andSubject:(NSString*)subject andFrom:(NSString*)fromSender
{
	return [self populateTestEmailWithSendDate:sendDate andSubject:subject 
		andFrom:fromSender andFolder:@"INBOX" andRecipientAddress:@"jane@example.com"];
}

-(EmailInfo*)populateFolderTestEmailWithSendDate:(NSString*)sendDate
	andSubject:(NSString*)subject andFrom:(NSString*)fromSender andFolder:(NSString*)folderName
{
	return [self populateTestEmailWithSendDate:sendDate andSubject:subject 
		andFrom:fromSender andFolder:folderName andRecipientAddress:@"jane@example.com"];
}

// ------------------

-(void)resetCoreData
{
	self.appDataDmc = [[[DataModelController alloc] 
			initForInMemoryStorageWithDataModelNamed:APP_DATA_DATA_MODEL_NAME 
			andStoreNamed:APP_DATA_STORE_NAME] autorelease];
			
	self.testAppVals = [SharedAppVals createWithDataModelController:self.appDataDmc];
	
	EmailAccount *testAcct = [EmailAccount defaultNewEmailAcctWithDataModelController:self.appDataDmc];
	testAcct.userName = @"testuser";
	testAcct.imapServer = @"testserver";
	testAcct.emailAddress = @"testemail";
	testAcct.acctName = @"testacct";
	
	self.testAppVals.currentEmailAcct = testAcct;
	
		
	self.testFolder = (EmailFolder*)[self.appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
	self.testFolder.folderName = @"TESTINBOX";
	self.testFolder.folderAccount = testAcct;
			
	currMessageId = 0;
}

-(void)checkFilteredEmailsInfos:(NSArray*)expectedSubjects 
	andFilterPredicate:(NSPredicate*)msgFilterPredicate
{

	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_INFO_ENTITY_NAME 
		inManagedObjectContext:self.appDataDmc.managedObjectContext];
	[fetchRequest setEntity:entity];
	[fetchRequest setPredicate:msgFilterPredicate];	
	
	NSArray *msgsMatchingFilter = 
		[CoreDataHelper executeFetchOrThrow:fetchRequest 
		inManagedObectContext:self.appDataDmc.managedObjectContext];

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

	self.messageFilterForTest.ageFilter = testAppVals.defaultAgeFilterOlder1Year;
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S03",@"S04",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	self.messageFilterForTest.ageFilter = testAppVals.defaultAgeFilterNone;
	filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S02",@"S03",@"S04",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}

-(MessageFilter*)messageFilterForTest
{
	return self.testAppVals.currentEmailAcct.msgListFilter;
}

- (void)testEmailAddressFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	EmailInfo *fromJane = [self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-02-01" andSubject:@"S02" andFrom:@"bob"];
	EmailInfo *fromDan = [self populateTestEmailWithSendDate:@"2012-03-01" andSubject:@"S03" andFrom:@"dan"];
	[self populateTestEmailWithSendDate:@"2012-04-01" andSubject:@"S04" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-05-01" andSubject:@"S05" andFrom:@"sally"];

	// Filtering for Jane should include S01 and S04
	[self.messageFilterForTest.fromAddressFilter addSelectedAddressesObject:fromJane.senderAddress];
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S04", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
	// Also filtering for Dan should additionally include S03
	[self.messageFilterForTest.fromAddressFilter addSelectedAddressesObject:fromDan.senderAddress];
	filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S03",@"S04", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];


	// Filtering for Steve shouldn't change the results, since there are no messages from Steve
	EmailAddress *steveEmailAddr = (EmailAddress*)[self.appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
	steveEmailAddr.address = @"steve";
	[self.messageFilterForTest.fromAddressFilter addSelectedAddressesObject:fromDan.senderAddress];
	filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S03",@"S04", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	
}


- (void)testRecipientAddressFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	[self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane" 
		andFolder:@"INBOX" andRecipientAddress:@"jane@example.com"];
		
	[self populateTestEmailWithSendDate:@"2012-02-01" andSubject:@"S02" andFrom:@"bob" 
		andFolder:@"INBOX" andRecipientAddress:@"jane@example.com"];
		
	[self populateTestEmailWithSendDate:@"2012-03-01" andSubject:@"S03" andFrom:@"dan" 
		andFolder:@"INBOX" andRecipientAddress:@"john@example.com"];
		
	[self populateTestEmailWithSendDate:@"2012-04-01" andSubject:@"S04" andFrom:@"jane" 
		andFolder:@"INBOX" andRecipientAddress:@"john@example.com"];
		
	[self populateTestEmailWithSendDate:@"2012-05-01" andSubject:@"S05" andFrom:@"sally" 
		andFolder:@"INBOX" andRecipientAddress:@"bob@example.com"];
		
	NSMutableDictionary *currEmailAddressByAddress = [self.testAppVals.currentEmailAcct emailAddressesByName];
	[self.messageFilterForTest.recipientAddressFilter addSelectedAddressesObject:
		[EmailAddress findOrAddAddress:@"jane@example.com" 
			withName:@"" andSendDate:[DateHelper today]
					withCurrentAddresses:currEmailAddressByAddress 
					inDataModelController:self.appDataDmc
					andEmailAcct:self.testAppVals.currentEmailAcct
					andIsRecipientAddr:TRUE andIsSenderAddr:FALSE]];
	[self.messageFilterForTest.recipientAddressFilter addSelectedAddressesObject:
		[EmailAddress findOrAddAddress:@"bob@example.com" 
			withName:@"" andSendDate:[DateHelper today]
					withCurrentAddresses:currEmailAddressByAddress 
					inDataModelController:self.appDataDmc
					andEmailAcct:self.testAppVals.currentEmailAcct
					andIsRecipientAddr:TRUE andIsSenderAddr:FALSE]];
					
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S02",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
	// Invert the matching
	self.messageFilterForTest.recipientAddressFilter.matchUnselected = [NSNumber numberWithBool:TRUE];
	filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S03",@"S04", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

		
}

- (void)testInvertedEmailAddressFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	EmailInfo *fromJane = [self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-02-01" andSubject:@"S02" andFrom:@"bob"];
	EmailInfo *fromDan = [self populateTestEmailWithSendDate:@"2012-03-01" andSubject:@"S03" andFrom:@"dan"];
	[self populateTestEmailWithSendDate:@"2012-04-01" andSubject:@"S04" andFrom:@"jane"];
	[self populateTestEmailWithSendDate:@"2012-05-01" andSubject:@"S05" andFrom:@"sally"];

	[self.messageFilterForTest.fromAddressFilter addSelectedAddressesObject:fromJane.senderAddress];
	
	[self.messageFilterForTest.fromAddressFilter addSelectedAddressesObject:fromDan.senderAddress];

	// Invert the selection
	self.messageFilterForTest.fromAddressFilter.matchUnselected = [NSNumber numberWithBool:TRUE];
	
	// Filtering for address other than Jane or Dan should include S02,S05
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S02",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}



- (void)testEmailDomainFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	EmailInfo *localDomainMsg = [self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane@localdomain"];
	[self populateTestEmailWithSendDate:@"2012-02-01" andSubject:@"S02" andFrom:@"bob@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-03-01" andSubject:@"S03" andFrom:@"dan@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-04-01" andSubject:@"S04" andFrom:@"jane@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-05-01" andSubject:@"S05" andFrom:@"sally@localdomain"];

	// Filtering email addresses with the localdomain should include S01 and S05.
	[self.messageFilterForTest.senderDomainFilter addSelectedDomainsObject:localDomainMsg.senderDomain];
	
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S05", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}

- (void)testInvertedEmailDomainFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	EmailInfo *localDomainMsg = [self populateTestEmailWithSendDate:@"2012-01-01" andSubject:@"S01" andFrom:@"jane@localdomain"];
	[self populateTestEmailWithSendDate:@"2012-02-01" andSubject:@"S02" andFrom:@"bob@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-03-01" andSubject:@"S03" andFrom:@"dan@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-04-01" andSubject:@"S04" andFrom:@"jane@notlocaldomain"];
	[self populateTestEmailWithSendDate:@"2012-05-01" andSubject:@"S05" andFrom:@"sally@localdomain"];

	// Filtering email addresses with the localdomain should include S01 and S05.
	[self.messageFilterForTest.senderDomainFilter addSelectedDomainsObject:localDomainMsg.senderDomain];
	
	self.messageFilterForTest.senderDomainFilter.matchUnselected = [NSNumber numberWithBool:TRUE];
	
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S02",@"S03",@"S04", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}


- (void)testEmailFolderFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	EmailInfo *inboxMsg = [self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S01" 
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S02" 
		andFrom:@"jane@localdomain" andFolder:@"MYFOLDER"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S03"
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];

	// Filtering email addresses with the localdomain should include S01 and S05.
	[self.messageFilterForTest.folderFilter addSelectedFoldersObject:inboxMsg.folderInfo];
	
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S03", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}

- (void)testInvertedEmailFolderFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	EmailInfo *inboxMsg = [self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S01" 
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S02" 
		andFrom:@"jane@localdomain" andFolder:@"MYFOLDER"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S03"
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
		

	[self.messageFilterForTest.folderFilter addSelectedFoldersObject:inboxMsg.folderInfo];
	
	// Invert the selection predicate
	self.messageFilterForTest.folderFilter.matchUnselected = [NSNumber numberWithBool:TRUE];
	
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S02", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
}


- (void)testStarredFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	EmailInfo *starredMsg = [self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S01" 
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	starredMsg.isStarred = [NSNumber numberWithBool:TRUE];
	
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S02" 
		andFrom:@"jane@localdomain" andFolder:@"MYFOLDER"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S03"
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
		

	self.messageFilterForTest.starredFilter = self.testAppVals.defaultStarredFilterStarred;
		
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
	self.messageFilterForTest.starredFilter = self.testAppVals.defaultStarredFilterUnstarred;
	filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S02",@"S03",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];


	self.messageFilterForTest.starredFilter = self.testAppVals.defaultStarredFilterStarredOrUnstarred;
	filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S02",@"S03",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	
}

- (void)testReadFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	EmailInfo *readMsg = [self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S01" 
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	readMsg.isRead = [NSNumber numberWithBool:FALSE];
	
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S02" 
		andFrom:@"jane@localdomain" andFolder:@"MYFOLDER"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:@"S03"
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
		

	self.messageFilterForTest.readFilter = self.testAppVals.defaultReadFilterUnread;
		
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01", nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
	self.messageFilterForTest.readFilter = self.testAppVals.defaultReadFilterRead;
	filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S02",@"S03",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];


	self.messageFilterForTest.readFilter = self.testAppVals.defaultReadFilterReadOrUnread;
	filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:@"S01",@"S02",@"S03",nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	
}

- (void)testSubjectFilter
{
	[self resetCoreData];

	NSDate *baseDate = [DateHelper dateFromStr:@"2012-12-31"];
	
	NSString *subject01 = @"S01 - The First Message";
	NSString *subject02 = @"S02 - Something else";
	NSString *subject03 = @"S03 - The Final message";
	
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:subject01 
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:subject02 
		andFrom:@"jane@localdomain" andFolder:@"MYFOLDER"];
	[self populateFolderTestEmailWithSendDate:@"2012-01-02" andSubject:subject03
		andFrom:@"jane@localdomain" andFolder:@"INBOX"];
		

	self.messageFilterForTest.subjectFilter.searchString = @"message";
	self.messageFilterForTest.subjectFilter.caseSensitive = [NSNumber numberWithBool:FALSE];
	
	NSPredicate *filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	NSArray *msgsExpectedAfterFiltering = [NSArray arrayWithObjects:subject01, subject03, nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];
	
	self.messageFilterForTest.subjectFilter.caseSensitive = [NSNumber numberWithBool:TRUE];	
	filterPredicate = [self.messageFilterForTest filterPredicate:baseDate];
	msgsExpectedAfterFiltering = [NSArray arrayWithObjects:subject03, nil];
	[self checkFilteredEmailsInfos:msgsExpectedAfterFiltering  andFilterPredicate:filterPredicate];

	
}




@end
