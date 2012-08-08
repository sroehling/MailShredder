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

@implementation MailSyncConnectionContext

@synthesize syncDmc;
@synthesize mailAcct;

-(id)init
{
	self = [super init];
	if(self)
	{
	
		// NSManagedObjectContext is not thread safe, so we need to create a dedicated DataModelController
		// wrapper for NSManagedObjectContext, where we'll perform the sync.
		// Objects need to be allocated and deallocated in the same thread, since release pools
		// are thread specific.

		self.syncDmc = [AppHelper appDataModelController];
		self.mailAcct = [[CTCoreAccount alloc] init];
	}
	return self;
}


-(void)connect
{
	self.mailAcct = [[CTCoreAccount alloc] init];
	
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.syncDmc];
	assert(sharedVals.currentEmailAcct != nil);

	EmailAccount *currentAcctSettings = sharedVals.currentEmailAcct;
	
	int connectionType = [currentAcctSettings.useSSL boolValue]?
		CONNECTION_TYPE_TLS:CONNECTION_TYPE_PLAIN;
		
	KeychainFieldInfo *passwordFieldInfo = [currentAcctSettings passwordFieldInfo];
	NSString *password = (NSString*)[passwordFieldInfo getFieldValue];
	
	NSLog(@"Mail connection: server=%@, login=%@, pass=%@",
		currentAcctSettings.imapServer,
		currentAcctSettings.userName,
		password);
	
	[self.mailAcct connectToServer:currentAcctSettings.imapServer 
		port:[currentAcctSettings.portNumber intValue]
		connectionType:connectionType
		authType:IMAP_AUTH_TYPE_PLAIN 
		login:currentAcctSettings.userName
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
	[super dealloc];
}

@end
