//
//  MailOperation.m
//
//  Created by Steve Roehling on 8/10/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MailOperation.h"

@implementation MailOperation

@synthesize connectionContext;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
{
	self = [super init];
	if(self)
	{
		self.connectionContext = theConnectionContext;
	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}

-(void)dealloc
{
	[connectionContext release];
	[super dealloc];
}


@end
