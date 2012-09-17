//
//  EmailAcctPreset.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImapAcctPreset.h"

@implementation ImapAcctPreset

@synthesize useSSL;
@synthesize portNum;
@synthesize domainName;
@synthesize imapServer;
@synthesize fullEmailIsUserName;
@synthesize defaultSyncFolders;
@synthesize defaultTrashFolders;
@synthesize immediatelyDeleteMsg;
@synthesize matchFirstDefaultSyncFolder;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.defaultSyncFolders = [[[NSMutableArray alloc] init] autorelease];
		self.defaultTrashFolders = [[[NSMutableArray alloc] init] autorelease];
	}
	return self;
}

-(void)dealloc
{
	[domainName release];
	[imapServer release];
	[defaultSyncFolders release];
	[defaultTrashFolders release];
	[super dealloc];
}

@end
