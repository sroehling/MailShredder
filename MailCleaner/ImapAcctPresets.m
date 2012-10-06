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
		NSArray *allLines = [presetData componentsSeparatedByString:@"\n"];
		
		self.presetsByDomainName = [[[NSMutableDictionary alloc] init] autorelease];
		self.presetsByIMAPHostName = [[[NSMutableDictionary alloc] init] autorelease];
		
		// Strip out any lines with comments, where comments are any line starting with
		// the '#' character.
		NSMutableArray *linesWithoutComments = [[[NSMutableArray alloc] init] autorelease];
		for(NSString *line in allLines)
		{
			if(!(line.length > 0 && ([line characterAtIndex:0] == '#')))
			{
				[linesWithoutComments addObject:line];
			}
		}
		
		NSUInteger lineNum = 0;
		while(lineNum < linesWithoutComments.count)
		{
		
			/////////////////////////////////////////////////////////////////////
			// Scan the first line for the server settings
			/////////////////////////////////////////////////////////////////////
			NSString *serverSettingsLine = [linesWithoutComments objectAtIndex:lineNum];
			lineNum++;

			NSArray *fields = [serverSettingsLine componentsSeparatedByString:@"\t"];
			NSLog(@"Loading preset info: domain:%@ server:%@ usessl:%@ portnum:%@ usernameisfulladdress:%@ immediately delete=%@",
				[fields objectAtIndex:0],[fields objectAtIndex:1],
				[fields objectAtIndex:2],[fields objectAtIndex:3],
				[fields objectAtIndex:4],[fields objectAtIndex:5]);
				
			ImapAcctPreset *preset = [[[ImapAcctPreset alloc] init] autorelease];
			preset.domainName = [fields objectAtIndex:0];
			
			NSString *scannedPortNum = [fields objectAtIndex:3];
			NSString *scannedUseSSL = [fields objectAtIndex:2];
			NSString *scannedFullUserNameIsEmail = [fields objectAtIndex:4];
			NSString *scannedImmediatelyDeleteMsg = [fields objectAtIndex:5];
			
			preset.portNum = [scannedPortNum integerValue];
			preset.useSSL = [scannedUseSSL boolValue];
			preset.imapServer = [fields objectAtIndex:1];
			preset.immediatelyDeleteMsg = [scannedImmediatelyDeleteMsg boolValue];
			
			preset.fullEmailIsUserName = [scannedFullUserNameIsEmail boolValue];
			
			/////////////////////////////////////////////////////////////////////
			// Scan the list of default synchronized folders. 
			// The second line is the number of folders in the default list of
			// synchronized folders
			/////////////////////////////////////////////////////////////////////
			assert(lineNum < linesWithoutComments .count);
			NSString *defaultSyncFoldersLine = [linesWithoutComments objectAtIndex:lineNum];
			lineNum++;
			NSArray *syncFields = [defaultSyncFoldersLine componentsSeparatedByString:@"\t"];
			NSString *scannedNumDefaultSyncFolders = [syncFields objectAtIndex:0];
			NSString *scannedMatchFirstSyncFolder = [syncFields objectAtIndex:1];
			
			NSInteger numDefaultSyncFolders = [scannedNumDefaultSyncFolders integerValue];
			preset.matchFirstDefaultSyncFolder = [scannedMatchFirstSyncFolder boolValue];
			assert(numDefaultSyncFolders >= 0);
			NSLog(@"Reading default synchronized folders: count = %d",numDefaultSyncFolders);
			for(NSInteger defaultFolder = 0; defaultFolder < numDefaultSyncFolders; defaultFolder++)
			{
				assert(lineNum<linesWithoutComments.count);
				NSString *defaultSyncFolderName = [linesWithoutComments objectAtIndex:lineNum];
				lineNum++; 
				
				[preset.defaultSyncFolders addObject:defaultSyncFolderName];
				NSLog(@"Default synchronized folder: %@",defaultSyncFolderName);
			}
			
			/////////////////////////////////////////////////////////////////////
			// Scan the list of default trash folders. 
			// The next line is the number of folders in the default list of
			// synchronized folders
			/////////////////////////////////////////////////////////////////////
			assert(lineNum < linesWithoutComments.count);
			NSString *numDefaultTrashFoldersLine = [linesWithoutComments objectAtIndex:lineNum];
			lineNum++;
			
			NSInteger numDefaultTrashFolders = [numDefaultTrashFoldersLine integerValue];
			assert(numDefaultTrashFolders >= 0);
			NSLog(@"Reading default trash folders: count = %d",numDefaultTrashFolders);
			for(NSInteger defaultFolder = 0; defaultFolder < numDefaultTrashFolders; defaultFolder++)
			{
				assert(lineNum<linesWithoutComments.count);
				NSString *defaultTrashFolderName = [linesWithoutComments objectAtIndex:lineNum];
				lineNum++; 
				
				[preset.defaultTrashFolders addObject:defaultTrashFolderName];
				NSLog(@"Default trash folder: %@",defaultTrashFolderName);
			}
			
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
