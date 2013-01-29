//
//  StressTestSyncAndDelete.m
//  MailShredder
//
//  Created by Steve Roehling on 1/25/13.
//
//

#import "StressTestSyncAndDelete.h"

#import "EmailAccount.h"
#import "SharedAppVals.h"
#import "DataModelController.h"
#import "AppHelper.h"
#import "SharedAppVals.h"
#import "CoreDataHelper.h"
#import "MessageFilter.h"
#import "AgeFilter.h"
#import "AgeFilterComparison.h"
#import "AgeFilterNone.h"
#import "FromAddressFilter.h"

#import "MailSyncConnectionContext.h"
#import "TestMailSyncProgressDelegate.h"
#import "TestMailDeleteProgressDelegate.h"
#import "KeychainFieldInfo.h"
#import "MailSyncOperation.h"
#import "MailDeleteOperation.h"
#import "EmailInfo.h"
#import "MsgPredicateHelper.h"
#import "EmailFolder.h"
#import "CoreDataHelper.h"

static NSUInteger const MAX_MSGS_PER_DELETE_OPERATION = 500;
static NSUInteger const MAX_MSGS_TO_CACHE_FROM_SYNC = 1000;

@implementation StressTestSyncAndDelete

@synthesize testAppVals;
@synthesize appDataDmc;
@synthesize progressDelegate;
@synthesize deleteProgressDelegate;

- (void)setUp
{
    [super setUp];
    
    self.progressDelegate = [[[TestMailSyncProgressDelegate alloc] init] autorelease];
    self.deleteProgressDelegate = [[[TestMailDeleteProgressDelegate alloc] init] autorelease];
	
}


-(void)resetCoreData
{
      
 	self.appDataDmc = [[[DataModelController alloc]
                        initForInMemoryStorageWithDataModelNamed:APP_DATA_DATA_MODEL_NAME
                        andStoreNamed:APP_DATA_STORE_NAME] autorelease];
     
 	self.testAppVals = [SharedAppVals createWithDataModelController:self.appDataDmc];
    [self.appDataDmc saveContext];
    [self.testAppVals.managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];

	
	EmailAccount *testAcct = [EmailAccount defaultNewEmailAcctWithDataModelController:self.appDataDmc];
	testAcct.userName = @"testimapuser@debianvm.local";
	testAcct.imapServer = @"debianvm";
	testAcct.emailAddress = @"testimapuser@debianvm.local";
	testAcct.acctName = @"Test Account";
    testAcct.portNumber = [NSNumber numberWithInteger:143];
    testAcct.useSSL = [NSNumber numberWithBool:FALSE];
    [testAcct.passwordFieldInfo setFieldValue:@"pass"];
    
    EmailFolder *inboxFolder = [appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
    inboxFolder.folderName = @"INBOX";
    inboxFolder.folderAccount = testAcct;
 //   [testAcct addOnlySyncFoldersObject:inboxFolder];
    
    testAcct.maxSyncMsgs = [NSNumber numberWithUnsignedInteger:MAX_MSGS_TO_CACHE_FROM_SYNC];

	
	self.testAppVals.currentEmailAcct = testAcct;
    
    [self.appDataDmc saveContext];
    
}

-(NSUInteger)syncWithTestServer
{
    MailSyncConnectionContext *syncConnectionContext =
        [[[MailSyncConnectionContext alloc]
          initWithMainThreadDmc:self.appDataDmc
          andProgressDelegate:self.progressDelegate] autorelease];
    
    MailSyncOperation *syncOperation = [[[MailSyncOperation alloc]
                                              initWithConnectionContext:syncConnectionContext
                                              andProgressDelegate:self.progressDelegate] autorelease];
    
    NSLog(@"SYNC: Emails in account before sync: %d",self.testAppVals.currentEmailAcct.emailsInAcct.count);
    NSLog(@"SYNC: Total count of emails cached locally before sync: %d",
          [CoreDataHelper countObjectsForEntityName:EMAIL_INFO_ENTITY_NAME
                              inManagedObectContext:self.appDataDmc.managedObjectContext]);
    
    [syncOperation main];
    
    NSLog(@"SYNC: Emails in account after sync: %d",self.testAppVals.currentEmailAcct.emailsInAcct.count);
    
    NSUInteger msgsCachedLocally = [CoreDataHelper countObjectsForEntityName:EMAIL_INFO_ENTITY_NAME
                                                       inManagedObectContext:self.appDataDmc.managedObjectContext];

    
    NSLog(@"SYNC: Total count of emails cached locally after sync: %d",msgsCachedLocally);
    
    return msgsCachedLocally;
    
 
}


-(void)deleteMarkedMsgsOnTestServer
{
    MailSyncConnectionContext *syncConnectionContext = [[[MailSyncConnectionContext alloc]
          initWithMainThreadDmc:self.appDataDmc
          andProgressDelegate:self.progressDelegate] autorelease];
	
    NSLog(@"DELETE: Emails in account before delete: %d",self.testAppVals.currentEmailAcct.emailsInAcct.count);
    
    NSLog(@"DELETE: Total count of emails cached locally before delete: %d",
          [CoreDataHelper countObjectsForEntityName:EMAIL_INFO_ENTITY_NAME
            inManagedObectContext:self.appDataDmc.managedObjectContext]);

	
    MailDeleteOperation *deleteOperation = [[[MailDeleteOperation alloc]
               initWithConnectionContext:syncConnectionContext
            andProgressDelegate:self.deleteProgressDelegate] autorelease];
    
    [deleteOperation main];

    
    NSLog(@"DELETE: Emails in account after delete: %d",self.testAppVals.currentEmailAcct.emailsInAcct.count);

    NSLog(@"DELETE: Total count of emails cached locally after delete: %d",
          [CoreDataHelper countObjectsForEntityName:EMAIL_INFO_ENTITY_NAME
                              inManagedObectContext:self.appDataDmc.managedObjectContext]);

    
}

-(NSUInteger)markEmailBatchForDeletion
{
    if(self.testAppVals.currentEmailAcct.emailsInAcct.count <= 0)
    {
        return 0;
    }
    
    NSUInteger numMsgsDeleted = 0;
    for (EmailInfo *info in self.testAppVals.currentEmailAcct.emailsInAcct)
    {
        
        info.deleted = [NSNumber numberWithBool:TRUE];
        
        numMsgsDeleted++;
        
        if (numMsgsDeleted >= MAX_MSGS_PER_DELETE_OPERATION)
        {
            [self.appDataDmc saveContext];
            return numMsgsDeleted;
        }
    }
    
    [self.appDataDmc saveContext];
    return numMsgsDeleted;
}

-(NSUInteger)markAndDeleteBatchOfEmails
{
    NSUInteger numMsgsMarkedForDeletion = [self markEmailBatchForDeletion];
    if(numMsgsMarkedForDeletion > 0)
    {
        NSLog(@"DELETE: %d of %d messages marked for deletion",
              numMsgsMarkedForDeletion,
              self.testAppVals.currentEmailAcct.emailsInAcct.count);
        [self deleteMarkedMsgsOnTestServer];
        NSLog(@"DELETE: %d messages remain after deletion",
              self.testAppVals.currentEmailAcct.emailsInAcct.count);
      
    }
    
    return numMsgsMarkedForDeletion;
}

-(void)testSyncAndDeleteWithTestServer
{
    NSLog(@"Stress testing against test server");
    
    [self resetCoreData];
    
    NSUInteger msgsCachedLocallyForDeletion = [self syncWithTestServer];
    while(msgsCachedLocallyForDeletion > 0)
    {
        // delete all the messages retrieved via the sync
        NSUInteger msgsDeleted = [self markAndDeleteBatchOfEmails];
        while(msgsDeleted > 0)
        {
            msgsDeleted = [self markAndDeleteBatchOfEmails];
        }
        
        // re-sync with server to get more messages
        msgsCachedLocallyForDeletion =  [self syncWithTestServer];
    }
    
}

- (void)tearDown
{
    // Tear-down code here.
	
	[appDataDmc release];
	[testAppVals release];
    [progressDelegate release];
    [deleteProgressDelegate release];
    
    [super tearDown];
}


@end
