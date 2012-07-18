//
//  TrashMsgListViewFactory.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrashMsgListViewFactory.h"

#import "FormContext.h"
#import "TrashMsgListViewController.h"

@implementation TrashMsgListViewFactory

@synthesize viewInfo;

-(id)initWithViewInfo:(TrashMsgListViewInfo*)theViewInfo
{
	self = [super init];
	if(self)
	{
		assert(theViewInfo != nil);
		self.viewInfo = theViewInfo;
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
	[viewInfo release];
	[super dealloc];
}

- (UIViewController*)createTableView:(FormContext*)parentContext
{
	TrashMsgListViewController *trashedMsgsController = [[[TrashMsgListViewController alloc]  
		initWithViewInfo:self.viewInfo] autorelease];
	return trashedMsgsController;
}

@end
