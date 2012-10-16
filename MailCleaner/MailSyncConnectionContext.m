//
//  MailSyncConnectionContext.m
//
//  Created by Steve Roehling on 8/7/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MailSyncConnectionContext.h"
#import "SharedAppVals.h"
#import "EmailAccount.h"
#import "KeychainFieldInfo.h"
#import "AppHelper.h"
#import "DataModelController.h"
#import "CoreDataHelper.h"

@implementation MailSyncConnectionContext

@synthesize syncDmc;
@synthesize mainThreadDmc;
@synthesize cachedChangeNotifications;
@synthesize progressDelegate;
@synthesize mailAcct;
@synthesize emailAcctInfo;


- (void)mailSyncThreadDidSaveNotificationHandler:(NSNotification *)notification
{
	[self.cachedChangeNotifications addObject:notification];
}


-(id)initWithMainThreadDmc:(DataModelController*)theMainThreadDmc
	andProgressDelegate:(id<MailServerConnectionProgressDelegate>)theProgressDelegate
{
	self = [super init];
	if(self)
	{
	
		self.mainThreadDmc = theMainThreadDmc;
	
		self.progressDelegate = theProgressDelegate;
		
		self.mailAcct = [[[CTCoreAccount alloc] init] autorelease];
		SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.mainThreadDmc];
		assert(sharedVals.currentEmailAcct != nil);

		self.emailAcctInfo = sharedVals.currentEmailAcct;
	
		self.cachedChangeNotifications = [[[NSMutableArray alloc] init] autorelease];

				
		contextIsSetup = FALSE;
		

	}
	return self;
}

-(EmailAccount*)acctInSyncObjectContext
{
	// self.emailAcctInfo references the EmailAccount on the main thread. For objects
	// created or changed on the thread used for synchronization, we need a separate reference
	// from the NSManagedObjectContext used for synchronization.
	return (EmailAccount*)[CoreDataHelper objectInOtherContext:self.syncDmc.managedObjectContext 
		forOriginalObj:self.emailAcctInfo];
}

-(id)init
{
	assert(0);
	return nil;
}


-(void)connect
{
	self.mailAcct = [[[CTCoreAccount alloc] init] autorelease];
	
	int connectionType = [self.emailAcctInfo.useSSL boolValue]?
		CONNECTION_TYPE_TLS:CONNECTION_TYPE_PLAIN;
	
	KeychainFieldInfo *passwordFieldInfo = [self.emailAcctInfo  passwordFieldInfo];
	NSString *password = (NSString*)[passwordFieldInfo getFieldValue];
	
	NSLog(@"Mail connection: server=%@, login=%@, pass=<hidden>",
		self.emailAcctInfo.imapServer,
		self.emailAcctInfo.userName);
		
	BOOL connectionSucceeded = [self.mailAcct connectToServer:self.emailAcctInfo.imapServer 
		port:[self.emailAcctInfo.portNumber intValue]
		connectionType:connectionType
		authType:IMAP_AUTH_TYPE_PLAIN 
		login:self.emailAcctInfo.userName
		password:password];
	if(!connectionSucceeded)
	{
		if([self.progressDelegate respondsToSelector:@selector(mailServerConnectionFailed)])
		{
			[self.progressDelegate mailServerConnectionFailed];
		}
		@throw [NSException exceptionWithName:@"IMAPServerConnectionFailed" reason:@"Connection to IMAP server failed" userInfo:nil];
	}
	
}

-(void)setupContext
{

	// NSManagedObjectContext is not thread safe, so we need to create a dedicated DataModelController
	// wrapper for NSManagedObjectContext, where we'll perform the sync.
	// Objects need to be allocated and deallocated in the same thread, since release pools
	// are thread specific.
	// The per-thread DataModelController (and underlynig NSManagedObjectContext) must be 
	// allocated in the worker thread.
	
	if(!contextIsSetup)
	{
		self.syncDmc = [[[DataModelController alloc] 
				initWithPersistentStoreCoord:self.mainThreadDmc.managedObjectContext.persistentStoreCoordinator] autorelease];
				
		[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(mailSyncThreadDidSaveNotificationHandler:)
			name:NSManagedObjectContextDidSaveNotification 
			object:self.syncDmc.managedObjectContext];
		
		contextIsSetup = TRUE;
	}
		
	
}

-(void)teardownContext
{
	if(contextIsSetup)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self 
				name:NSManagedObjectContextDidSaveNotification 
				object:self.syncDmc.managedObjectContext];
				
		[syncDmc release];
	}
}

-(BOOL)establishConnection
{
	[self setupContext];
		
	if([self.progressDelegate respondsToSelector:@selector(mailServerConnectionStarted)])
	{
		[self.progressDelegate mailServerConnectionStarted]; 
	}
	
	@try
	{
    	[self connect];
		
		if([self.progressDelegate respondsToSelector:@selector(mailServerConnectionEstablished)])
		{
			[self.progressDelegate mailServerConnectionEstablished];
		}

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

-(void)mergeCachedChangesToMainThreadContext
{
	for(NSNotification *cachedNotification in self.cachedChangeNotifications)
	{
		NSLog(@"Merging cached changes in thread's NSManagedObjectContext (MOC) to main thread MOC");
		[self.mainThreadDmc.managedObjectContext mergeChangesFromContextDidSaveNotification:cachedNotification];
	}

	[self.mainThreadDmc saveContext];

	[self.cachedChangeNotifications removeAllObjects];
}

-(void)saveLocalChanges
{
	// Process any pending deletes before saving.
	[self.syncDmc.managedObjectContext processPendingChanges];
	
	[self.syncDmc saveContext];
	
	[self performSelectorOnMainThread:@selector(mergeCachedChangesToMainThreadContext) withObject:nil waitUntilDone:TRUE];
}

-(void)teardownConnection
{
	if([self.progressDelegate respondsToSelector:@selector(mailServerConnectionTeardownStarted)])
	{
		[self.progressDelegate mailServerConnectionTeardownStarted];
	}
		
	[self disconnect];

	[self saveLocalChanges];
		
	[self teardownContext];						
															
	if([self.progressDelegate respondsToSelector:@selector(mailServerConnectionTeardownFinished)])
	{
		[self.progressDelegate mailServerConnectionTeardownFinished];
	}

}


-(void)dealloc
{
	[mainThreadDmc release];
	[mailAcct release];
	[emailAcctInfo release];
	[cachedChangeNotifications release];
	[super dealloc];
}

@end
