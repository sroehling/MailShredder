//
//  MailSyncConnectionContext.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailSyncConnectionContext.h"
#import "SharedAppVals.h"
#import "EmailAccount.h"
#import "KeychainFieldInfo.h"
#import "AppHelper.h"
#import "DataModelController.h"

@implementation MailSyncConnectionContext

@synthesize syncDmc;
@synthesize mainThreadDmc;
@synthesize progressDelegate;
@synthesize mailAcct;
@synthesize emailAcctInfo;

- (void)mailSyncThreadDidSaveNotificationHandler:(NSNotification *)notification
{
    // This method is invoked as a subscriber/call-back for saves the to NSManagedObjectContext
	// used to synchronize the email information on a dedicated thread. This will in turn 
	// trigger the main thread to perform updates on to the appropriate NSFetchedResultsControllers,
	// table views, etc.
    [self.mainThreadDmc.managedObjectContext 
		performSelectorOnMainThread:@selector(mergeChangesFromContextDidSaveNotification:) 
		withObject:notification waitUntilDone:NO];

}


-(id)initWithMainThreadDmc:(DataModelController*)theMainThreadDmc
	andProgressDelegate:(id<MailSyncProgressDelegate>)theProgressDelegate
{
	self = [super init];
	if(self)
	{
	
		self.mainThreadDmc = theMainThreadDmc;
	
		self.progressDelegate = theProgressDelegate;
		
		self.mailAcct = [[CTCoreAccount alloc] init];
		SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.mainThreadDmc];
		assert(sharedVals.currentEmailAcct != nil);

		self.emailAcctInfo = sharedVals.currentEmailAcct;
		

	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}


-(void)connect
{
	self.mailAcct = [[CTCoreAccount alloc] init];
	
	int connectionType = [self.emailAcctInfo .useSSL boolValue]?
		CONNECTION_TYPE_TLS:CONNECTION_TYPE_PLAIN;
		
	KeychainFieldInfo *passwordFieldInfo = [self.emailAcctInfo  passwordFieldInfo];
	NSString *password = (NSString*)[passwordFieldInfo getFieldValue];
	
	NSLog(@"Mail connection: server=%@, login=%@, pass=%@",
		self.emailAcctInfo .imapServer,
		self.emailAcctInfo .userName,
		password);
	
	[self.mailAcct connectToServer:self.emailAcctInfo .imapServer 
		port:[self.emailAcctInfo .portNumber intValue]
		connectionType:connectionType
		authType:IMAP_AUTH_TYPE_PLAIN 
		login:self.emailAcctInfo.userName
		password:password]; 
	
}

-(void)setupContext
{

	// NSManagedObjectContext is not thread safe, so we need to create a dedicated DataModelController
	// wrapper for NSManagedObjectContext, where we'll perform the sync.
	// Objects need to be allocated and deallocated in the same thread, since release pools
	// are thread specific.
	// The per-thread DataModelController (and underlynig NSManagedObjectContext) must be 
	// allocated in the worker thread.
	self.syncDmc = [[[DataModelController alloc] 
			initWithPersistentStoreCoord:self.mainThreadDmc.managedObjectContext.persistentStoreCoordinator] autorelease];
			
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(mailSyncThreadDidSaveNotificationHandler:)
		name:NSManagedObjectContextDidSaveNotification 
		object:self.syncDmc.managedObjectContext];
}

-(void)teardownContext
{
	[[NSNotificationCenter defaultCenter] removeObserver:self 
			name:NSManagedObjectContextDidSaveNotification 
			object:self.syncDmc.managedObjectContext];
			
	[syncDmc release];
}

-(BOOL)establishConnection
{
	[self setupContext];
		
	[self.progressDelegate mailSyncConnectionStarted]; 
	
	@try
	{
    	[self connect];
		
		[self.progressDelegate mailSyncConnectionEstablished];

		return TRUE;

	}
	@catch (NSException *exception) 
	{
		NSLog(@"Connection error");
		[self teardownContext];
		return FALSE;
	}
}


-(void)disconnect
{
	if(self.mailAcct != nil)
	{
		[self.mailAcct disconnect];
		self.mailAcct = nil;
	}
}

-(void)saveLocalChanges
{
	// Process any pending deletes before saving.
	[self.syncDmc.managedObjectContext processPendingChanges];
	
	[self.syncDmc saveContext];

}

-(void)teardownConnection
{
	[self.progressDelegate mailSyncConnectionTeardownStarted];
		
	[self disconnect];

	[self saveLocalChanges];
		
	[self teardownContext];						
															
	[self.progressDelegate mailSyncConnectionTeardownFinished];

}


-(void)dealloc
{
	[mainThreadDmc release];
	[mailAcct release];
	[emailAcctInfo release];
	[super dealloc];
}

@end
