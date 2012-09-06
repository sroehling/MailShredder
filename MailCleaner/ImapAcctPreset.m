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

-(void)dealloc
{
	[domainName release];
	[imapServer release];
	[super dealloc];
}

@end
