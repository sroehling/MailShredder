//
//  CompositeMailSyncProgressDelegate.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CompositeMailSyncProgressDelegate.h"

@implementation CompositeMailSyncProgressDelegate

@synthesize subDelegates;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.subDelegates = [[[NSMutableArray alloc] init] autorelease];
	}
	return self;
}

-(void)addSubDelegate:(id<MailSyncProgressDelegate>)subDelegate
{
	assert(subDelegate != nil);
	[self.subDelegates addObject:subDelegate];
}

-(void)removeSubDelegate:(id<MailSyncProgressDelegate>)subDelegate
{
	[self.subDelegates removeObject:subDelegate];
}

-(void)mailSyncConnectionStarted
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailSyncConnectionStarted];
	}
}

-(void)mailSyncConnectionEstablished
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailSyncConnectionEstablished];
	}
}

-(void)mailSyncUpdateProgress:(CGFloat)percentProgress
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailSyncUpdateProgress:percentProgress];
	}
}

-(void)mailSyncConnectionTeardownStarted
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailSyncConnectionTeardownStarted];
	}
}

-(void)mailSyncConnectionTeardownFinished
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailSyncConnectionTeardownFinished];
	}
}

-(void)mailSyncComplete:(BOOL)successfulCompletion
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailSyncComplete:successfulCompletion];
	}
}

-(void)dealloc
{
	[subDelegates release];
	[super dealloc];
}

@end
