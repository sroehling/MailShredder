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

+(NSDictionary*)presetsByDomainName
{

	NSString   *path = [[NSBundle mainBundle] pathForResource: @"imapAcctPresets" ofType: @"txt"];
	NSString *presetData = [NSString stringWithContentsOfFile:path 
			encoding:NSUTF8StringEncoding error:nil];
	NSArray *lines = [presetData componentsSeparatedByString:@"\n"];
	
	NSMutableDictionary *acctPresetsByDomain = [[[NSMutableDictionary alloc] init] autorelease];
	
	for(NSString *line in lines)
	{
		NSArray *fields = [line componentsSeparatedByString:@"\t"];
		NSLog(@"Loading preset info: domain:%@ server:%@ usessl:%@ portnum:%@ usernameisfulladdress:%@",
			[fields objectAtIndex:0],[fields objectAtIndex:1],
			[fields objectAtIndex:2],[fields objectAtIndex:3],
			[fields objectAtIndex:4]);
			
		ImapAcctPreset *preset = [[[ImapAcctPreset alloc] init] autorelease];
		preset.domainName = [fields objectAtIndex:0];
		
		NSString *scannedPortNum = [fields objectAtIndex:3];
		NSString *scannedUseSSL = [fields objectAtIndex:2];
		NSString *scannedFullUserNameIsEmail = [fields objectAtIndex:4];
		
		preset.portNum = [scannedPortNum integerValue];
		preset.useSSL = [scannedUseSSL boolValue];
		preset.imapServer = [fields objectAtIndex:1];
		
		preset.fullEmailIsUserName = [scannedFullUserNameIsEmail boolValue];
		
		[acctPresetsByDomain setObject:preset forKey:preset.domainName];
	}
	
	return acctPresetsByDomain;

}

@end
