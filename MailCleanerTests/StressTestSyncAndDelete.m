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
static NSString * const TEST_YAHOO_EMAIL_ACCT_PASSWORD
        = @"TEMPORARILY_CHANGE_TO_REAL_PASSWORD_BEFORE_RUNNING_TEST";

@implementation StressTestSyncAndDelete

@synthesize appValsForTest;
@synthesize appDataDmc;
@synthesize progressDelegate;
@synthesize deleteProgressDelegate;

- (void)setUp
{
    [super setUp];
    
    self.progressDelegate = [[[TestMailSyncProgressDelegate alloc] init] autorelease];
    self.deleteProgressDelegate = [[[TestMailDeleteProgressDelegate alloc] init] autorelease];
	
}


-(void)resetCoreDataAndTestProgressDelegates
{
      
 	self.appDataDmc = [[[DataModelController alloc]
                        initForInMemoryStorageWithDataModelNamed:APP_DATA_DATA_MODEL_NAME
                        andStoreNamed:APP_DATA_STORE_NAME] autorelease];
     
 	self.appValsForTest = [SharedAppVals createWithDataModelController:self.appDataDmc];
    [self.appDataDmc saveContext];
    [self.appValsForTest.managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];

	[self.progressDelegate reset];
    [self.deleteProgressDelegate reset];
    
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
    
    NSLog(@"SYNC: Emails in account before sync: %d",self.appValsForTest.currentEmailAcct.emailsInAcct.count);
    NSLog(@"SYNC: Total count of emails cached locally before sync: %d",
          [CoreDataHelper countObjectsForEntityName:EMAIL_INFO_ENTITY_NAME
                              inManagedObectContext:self.appDataDmc.managedObjectContext]);
    
    [syncOperation main];
    
    NSLog(@"SYNC: Emails in account after sync: %d",self.appValsForTest.currentEmailAcct.emailsInAcct.count);
    
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
	
    NSLog(@"DELETE: Emails in account before delete: %d",self.appValsForTest.currentEmailAcct.emailsInAcct.count);
    
    NSLog(@"DELETE: Total count of emails cached locally before delete: %d",
          [CoreDataHelper countObjectsForEntityName:EMAIL_INFO_ENTITY_NAME
            inManagedObectContext:self.appDataDmc.managedObjectContext]);

	
    MailDeleteOperation *deleteOperation = [[[MailDeleteOperation alloc]
               initWithConnectionContext:syncConnectionContext
            andProgressDelegate:self.deleteProgressDelegate] autorelease];
    
    [deleteOperation main];

    
    NSLog(@"DELETE: Emails in account after delete: %d",self.appValsForTest.currentEmailAcct.emailsInAcct.count);

    NSLog(@"DELETE: Total count of emails cached locally after delete: %d",
          [CoreDataHelper countObjectsForEntityName:EMAIL_INFO_ENTITY_NAME
                              inManagedObectContext:self.appDataDmc.managedObjectContext]);

    
}

-(NSUInteger)markEmailBatchForDeletionWithBatchSize:(NSUInteger)deleteBatchSize
{
    assert(deleteBatchSize > 0);
    
    if(self.appValsForTest.currentEmailAcct.emailsInAcct.count <= 0)
    {
        return 0;
    }
    
    NSUInteger numMsgsDeleted = 0;
    for (EmailInfo *info in self.appValsForTest.currentEmailAcct.emailsInAcct)
    {
        
        info.deleted = [NSNumber numberWithBool:TRUE];
        
        numMsgsDeleted++;
        
        if (numMsgsDeleted >= deleteBatchSize)
        {
            [self.appDataDmc saveContext];
            return numMsgsDeleted;
        }
    }
    
    [self.appDataDmc saveContext];
    return numMsgsDeleted;
}

-(NSUInteger)markAndDeleteBatchOfEmailsWithBatchSize:(NSUInteger)deleteBatchSize
{
    NSUInteger numMsgsMarkedForDeletion = [self markEmailBatchForDeletionWithBatchSize:deleteBatchSize];
    if(numMsgsMarkedForDeletion > 0)
    {
        NSLog(@"DELETE: %d of %d messages marked for deletion",
              numMsgsMarkedForDeletion,
              self.appValsForTest.currentEmailAcct.emailsInAcct.count);
        [self deleteMarkedMsgsOnTestServer];
        NSLog(@"DELETE: %d messages remain after deletion",
              self.appValsForTest.currentEmailAcct.emailsInAcct.count);
      
    }
    
    return numMsgsMarkedForDeletion;
}

-(void)syncAndDeleteAllMsgsInCurrentlyConfiguredTestAcctWithBatchSize:(NSUInteger)deleteBatchSize
{
    NSUInteger msgsCachedLocallyForDeletion = [self syncWithTestServer];
    while(msgsCachedLocallyForDeletion > 0)
    {
        // delete all the messages retrieved via the sync
        NSUInteger msgsDeleted = [self markAndDeleteBatchOfEmailsWithBatchSize:deleteBatchSize];
        while(msgsDeleted > 0)
        {
            msgsDeleted = [self markAndDeleteBatchOfEmailsWithBatchSize:deleteBatchSize];
        }
        
        // re-sync with server to get more messages
        msgsCachedLocallyForDeletion =  [self syncWithTestServer];
    }
    
    NSLog(@"TOTAL Messages Synced: %d",self.progressDelegate.numMsgsSynced);
    NSLog(@"TOTAL Messages Deleted: %d",self.deleteProgressDelegate.numDeletedMsgs);

}

-(EmailAccount *)setupTestEmailAcct:(NSString *)acctName
               imapServer:(NSString*)imapSrv
                emailAddr:(NSString*)addr userName:(NSString*)userName
                 password:(NSString*)passwd
                   useSSL:(BOOL)doUseSSL portNum:(NSUInteger)portNum
                maxSyncMsgs:(NSUInteger)maxSync
{
	EmailAccount *testAcct = [EmailAccount defaultNewEmailAcctWithDataModelController:self.appDataDmc];
	testAcct.userName = userName;
	testAcct.imapServer =imapSrv;
	testAcct.emailAddress = addr;
	testAcct.acctName = acctName;
    testAcct.portNumber = [NSNumber numberWithInteger:portNum];
    testAcct.useSSL = [NSNumber numberWithBool:doUseSSL];
    [testAcct.passwordFieldInfo setFieldValue:passwd];
    
    testAcct.maxSyncMsgs = [NSNumber numberWithUnsignedInteger:maxSync];

    self.appValsForTest.currentEmailAcct = testAcct;
    
    [self.appDataDmc saveContext];
    
    return testAcct;
}

//-----------------------------------------------------------------------------------------------
// This test will test the deletion of all messages from a test server. Before running this test
// the test Dovecot IMAP server needs to be up and running in a virtual machine, and
// a test mailbox needs to be created and populated, as follows:
//
// % cd /home/vmail/testimapuser\@debianvm.local/
// % ~sroehling/MailCleanerTestImapServer/testScripts/gentestmbox.pl --subjprefix=INBOXMSGS\
//               --nummsgs=1000 > INBOX ; chown vmail:vmail INBOX
//-----------------------------------------------------------------------------------------------
-(void)testSyncAndDeleteWithTestServer
{
    NSLog(@"Stress testing against test server");
    
    [self resetCoreDataAndTestProgressDelegates];
    
    
   	EmailAccount *testAcct = [self setupTestEmailAcct:@"Test Account"
            imapServer:@"debianvm"
            emailAddr:@"testimapuser@debianvm.local" userName:@"testimapuser@debianvm.local"
            password:@"pass"
            useSSL:FALSE portNum:EMAIL_ACCOUNT_DEFAULT_PORT_NOSSL
            maxSyncMsgs:MAX_MSGS_TO_CACHE_FROM_SYNC];
  
    EmailFolder *inboxFolder = [appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
    inboxFolder.folderName = @"INBOX";
    inboxFolder.folderAccount = testAcct;
    [testAcct addOnlySyncFoldersObject:inboxFolder];
    
    // Set the line below to TRUE to print via NSLog details on each message that is synchronized.
//    self.progressDelegate.logMsgSyncCompletion = TRUE;
//    self.deleteProgressDelegate.logDeletedMsgs = TRUE;
    self.progressDelegate.logMsgSyncCompletion = FALSE;
    self.deleteProgressDelegate.logDeletedMsgs = FALSE;
    
    [self.appDataDmc saveContext];
    
    [self syncAndDeleteAllMsgsInCurrentlyConfiguredTestAcctWithBatchSize:MAX_MSGS_PER_DELETE_OPERATION];
    
}

-(void)testSyncAndDeleteWithYahooServer
{
    NSLog(@"Stress testing against test server");
    
    [self resetCoreDataAndTestProgressDelegates];
    
 	EmailAccount *testAcct = [self setupTestEmailAcct:@"Yahoo"
        imapServer:@"imap.mail.yahoo.com"
        emailAddr:@"sroehling@yahoo.com" userName:@"sroehling@yahoo.com" 
        password:TEST_YAHOO_EMAIL_ACCT_PASSWORD
        useSSL:TRUE portNum:EMAIL_ACCOUNT_DEFAULT_PORT_SSL
        maxSyncMsgs:50];
    
    // Limit deletion to the Inbox
    EmailFolder *inboxFolder = [appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
    inboxFolder.folderName = @"Inbox";
    inboxFolder.folderAccount = testAcct;
    [testAcct addOnlySyncFoldersObject:inboxFolder];
    [self.appDataDmc saveContext];

    [self syncAndDeleteAllMsgsInCurrentlyConfiguredTestAcctWithBatchSize:10];
    
}


- (void)tearDown
{
    // Tear-down code here.
	
	[appDataDmc release];
	[appValsForTest release];
    [progressDelegate release];
    [deleteProgressDelegate release];
    
    [super tearDown];
}


@end
