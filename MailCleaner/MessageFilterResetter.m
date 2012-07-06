//
//  MessageFilterResetter.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilterResetter.h"
#import "MessageFilter.h"
#import "GenericFieldBasedTableViewController.h"
#import "SingleButtonTableFooter.h"
#import "DataModelController.h"
#import "LocalizationHelper.h"

@implementation MessageFilterResetter

@synthesize messageFilter;
@synthesize filterDmc;

-(id)initWithMessageFilter:(MessageFilter*)theMessageFilter 
	andFilterDataModelController:(DataModelController*)theFilterDmc
{
	self = [super init];
	if(self)
	{
		self.messageFilter = theMessageFilter;
		self.filterDmc = theFilterDmc;
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
	[messageFilter release];
	[filterDmc release];
	[super dealloc];
}

-(void)tableFooterButtonPressed
{
	NSLog(@"Footer button pressed");
	
	assert(self.footerDelegate != nil);
	
	[self.messageFilter resetToDefault:self.filterDmc];
	[self.filterDmc saveContext];

	// Need to reload the parent table view, since the message filter has now been cleared.
	[self.footerDelegate reloadTableView];
}

-(NSString*)tableFooterButtonTitle
{
	return LOCALIZED_STR(@"MESSAGE_FILTER_RESET_FILTER_BUTTON_TITLE");
}

-(UIView*)footerView
{
	return	[[[SingleButtonTableFooter alloc] initWithDelegate:self] autorelease];

}


@end
