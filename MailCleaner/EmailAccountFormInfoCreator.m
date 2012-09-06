//
//  EmailAccountFormInfoCreator.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAccountFormInfoCreator.h"
#import "EmailAccount.h"


@implementation EmailAccountFormInfoCreator

@synthesize emailAccount;

- (FormInfo*)createFormInfoWithContext:(FormContext*)parentContext
{
	assert(0); // must be overridden
	return nil;
}

-(id)init
{
	assert(0); // must init with an EmailAccount
	return nil;
}

-(void)dealloc
{
	[emailAccount release];
	[super dealloc];
}

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct
{
	self = [super init];
	if(self)
	{
		self.emailAccount = theEmailAcct;
	}
	return self;
}


@end
