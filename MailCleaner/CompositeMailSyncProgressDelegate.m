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

-(void)mailServerConnectionStarted
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailServerConnectionStarted)])
		{
			[subDelegate mailServerConnectionStarted];
		}
	}
}

-(void)mailServerConnectionEstablished
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailServerConnectionEstablished)])
		{
			[subDelegate mailServerConnectionEstablished];
		}
	}
}

-(void)mailServerConnectionFailed
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailServerConnectionFailed)])
		{
			[subDelegate mailServerConnectionFailed];
		}
	}
}

-(void)mailSyncUpdateProgress:(CGFloat)percentProgress
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailSyncUpdateProgress:)])
		{
			[subDelegate mailSyncUpdateProgress:percentProgress];
		}
	}
}

-(void)mailServerConnectionTeardownStarted
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailServerConnectionTeardownStarted)])
		{
			[subDelegate mailServerConnectionTeardownStarted];
		}
	}
}

-(void)mailServerConnectionTeardownFinished
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailServerConnectionTeardownFinished)])
		{
			[subDelegate mailServerConnectionTeardownFinished];
		}
	}
}

-(void)mailSyncComplete:(BOOL)successfulCompletion
{
	for(id<MailSyncProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailSyncComplete:)])
		{
			[subDelegate mailSyncComplete:successfulCompletion];
		}
	}
}

-(void)dealloc
{
	[subDelegates release];
	[super dealloc];
}

@end
