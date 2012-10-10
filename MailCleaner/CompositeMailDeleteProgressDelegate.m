//
//  CompositeMailDeleteProgressDelegate.m
//
//  Created by Steve Roehling on 9/11/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
		if([subDelegate respondsToSelector:@selector(mailServerConnectionStarted)])
		{
			[subDelegate mailServerConnectionStarted];
		}
	}
}

-(void)mailServerConnectionEstablished
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailServerConnectionEstablished)])
		{
			[subDelegate mailServerConnectionEstablished];
		}
	}
}

-(void)mailServerConnectionFailed
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailServerConnectionFailed)])
		{
			[subDelegate mailServerConnectionFailed];
		}
	}
}

-(void)mailServerConnectionTeardownStarted
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailServerConnectionTeardownStarted)])
		{
			[subDelegate mailServerConnectionTeardownStarted];
		}
	}
}

-(void)mailServerConnectionTeardownFinished
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailServerConnectionTeardownFinished)])
		{
			[subDelegate mailServerConnectionTeardownFinished];
		}
	}
}

-(void)mailDeleteComplete:(BOOL)completeStatus withCompletionInfo:(MailDeleteCompletionInfo *)mailDeleteCompletionInfo
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailDeleteComplete:withCompletionInfo:)])
		{
			[subDelegate mailDeleteComplete:completeStatus withCompletionInfo:mailDeleteCompletionInfo];
		}
	}
}

-(void)mailDeleteUpdateProgress:(CGFloat)percentProgress
{
	for(id<MailDeleteProgressDelegate> subDelegate in self.subDelegates)
	{
		if([subDelegate respondsToSelector:@selector(mailDeleteUpdateProgress:)])
		{
			[subDelegate mailDeleteUpdateProgress:percentProgress];
		}
	}
}

-(void)dealloc
{
	[subDelegates release];
	[super dealloc];
}


@end
