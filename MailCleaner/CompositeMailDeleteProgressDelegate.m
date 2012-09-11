//
//  CompositeMailDeleteProgressDelegate.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CompositeMailDeleteProgressDelegate.h"

@implementation CompositeMailDeleteProgressDelegate

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

-(void)addSubDelegate:(id<MailDeleteProgressDelegate>)subDelegate
{
	assert(subDelegate != nil);
	[self.subDelegates addObject:subDelegate];
}

-(void)removeSubDelegate:(id<MailDeleteProgressDelegate>)subDelegate
{
	[self.subDelegates removeObject:subDelegate];
}

-(void)mailServerConnectionStarted
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailServerConnectionStarted];
	}
}

-(void)mailServerConnectionEstablished
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailServerConnectionEstablished];
	}
}

-(void)mailServerConnectionFailed
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailServerConnectionFailed];
	}
}

-(void)mailServerConnectionTeardownStarted
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailServerConnectionTeardownStarted];
	}
}

-(void)mailServerConnectionTeardownFinished
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailServerConnectionTeardownFinished];
	}
}

-(void)mailDeleteComplete:(BOOL)completeStatus
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailDeleteComplete:completeStatus];
	}
}

-(void)mailDeleteUpdateProgress:(CGFloat)percentProgress
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		[subDelegate mailDeleteUpdateProgress:percentProgress];
	}
}

-(void)dealloc
{
	[subDelegates release];
	[super dealloc];
}


@end
