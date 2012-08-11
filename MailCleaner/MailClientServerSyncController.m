//
//  MailSyncController.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailClientServerSyncController.h"

#import "DataModelController.h"
#import "MailSyncConnectionContext.h"
#import "MailDeleteOperation.h"
#import "MailSyncOperation.h"

@implementation MailClientServerSyncController

@synthesize mainThreadDmc;
@synthesize progressDelegate;
@synthesize mailServerOperationQueue;

-(id)initWithMainThreadDataModelController:(DataModelController*)theMainThreadDmc
	andProgressDelegate:(id<MailSyncProgressDelegate>)theProgressDelegate
{
	self = [super init];
	if(self)
	{		
		assert(theMainThreadDmc != nil);
		self.mainThreadDmc = theMainThreadDmc;
		
		assert(theProgressDelegate != nil);
		self.progressDelegate = theProgressDelegate;
		
		self.mailServerOperationQueue = [[[NSOperationQueue alloc] init] autorelease];

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
	[mainThreadDmc release];
	[mailServerOperationQueue release];
	[super dealloc];
}

-(void)syncWithServerInBackgroundThread
{
	MailSyncConnectionContext *syncConnectionContext = [[[MailSyncConnectionContext alloc]
		initWithMainThreadDmc:self.mainThreadDmc
		andProgressDelegate:self.progressDelegate] autorelease];
		
	[self.mailServerOperationQueue addOperation:[[[MailSyncOperation alloc]  
		initWithConnectionContext:syncConnectionContext] autorelease]];
}


-(void)deleteMarkedMsgsInBackgroundThread
{
	MailSyncConnectionContext *syncConnectionContext = [[[MailSyncConnectionContext alloc]
		initWithMainThreadDmc:self.mainThreadDmc
		andProgressDelegate:self.progressDelegate] autorelease];
		
	[self.mailServerOperationQueue addOperation:[[[MailDeleteOperation alloc]  
		initWithConnectionContext:syncConnectionContext] autorelease]];
}


@end
