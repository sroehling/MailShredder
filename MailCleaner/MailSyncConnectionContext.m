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
@synthesize mailAcct;
@synthesize emailAcctInfo;

-(id)initWithMainThreadDmc:(DataModelController*)mainThreadDmc
{
	self = [super init];
	if(self)
	{
	
		// NSManagedObjectContext is not thread safe, so we need to create a dedicated DataModelController
		// wrapper for NSManagedObjectContext, where we'll perform the sync.
		// Objects need to be allocated and deallocated in the same thread, since release pools
		// are thread specific.

		self.syncDmc = [[[DataModelController alloc] 
			initWithPersistentStoreCoord:mainThreadDmc.managedObjectContext.persistentStoreCoordinator] autorelease];
		
		
		self.mailAcct = [[CTCoreAccount alloc] init];
		SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.syncDmc];
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

-(void)disconnect
{
	if(self.mailAcct != nil)
	{
		[self.mailAcct disconnect];
		self.mailAcct = nil;
	}
}


-(void)dealloc
{
	[syncDmc release];
	[mailAcct release];
	[emailAcctInfo release];
	[super dealloc];
}

@end
