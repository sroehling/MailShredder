//
//  ImapAcctPresets.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ImapAcctPresets.h"
#import "ImapAcctPreset.h"

@implementation ImapAcctPresets

@synthesize presetsByDomainName;
@synthesize presetsByIMAPHostName;

-(void)dealloc
{
	[presetsByDomainName release];
	[presetsByIMAPHostName release];
	[super dealloc];
}

-(id)init
{
	self = [super init];
	if(self)
	{
		NSString   *path = [[NSBundle mainBundle] pathForResource: @"imapAcctPresets" ofType: @"txt"];
		NSString *presetData = [NSString stringWithContentsOfFile:path 
				encoding:NSUTF8StringEncoding error:nil];
		NSArray *lines = [presetData componentsSeparatedByString:@"\n"];
		
		self.presetsByDomainName = [[[NSMutableDictionary alloc] init] autorelease];
		self.presetsByIMAPHostName = [[[NSMutableDictionary alloc] init] autorelease];
		
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
			
			[self.presetsByDomainName setObject:preset forKey:preset.domainName];
			[self.presetsByIMAPHostName setObject:preset forKey:preset.imapServer];
		}
	}
	return self;
}

-(ImapAcctPreset*)findPresetWithDomainName:(NSString*)domainName
{
	return [self.presetsByDomainName objectForKey:domainName];
}

-(ImapAcctPreset*)findPresetWithImapHostName:(NSString*)imapHostName
{
	return [self.presetsByIMAPHostName objectForKey:imapHostName];
}


@end
