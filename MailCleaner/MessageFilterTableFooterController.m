//
//  MessageFilterTableFooterController.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilterTableFooterController.h"
#import "ButtonListView.h"
#import "LocalizationHelper.h"
#import "ButtonListItemInfo.h"
#import "MessageFilter.h"
#import "DataModelController.h"

@implementation MessageFilterTableFooterController

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

-(UIView*)footerView
{
	NSMutableArray *buttonInfo = [[[NSMutableArray alloc] init] autorelease];

	[buttonInfo addObject:[[[ButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_FILTER_RESET_FILTER_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(resetFilter)] autorelease]];
		 
	CGRect buttonListFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-10, 
		[ButtonListView buttonListHeight:buttonInfo]);	 
	return [[[ButtonListView alloc] initWithFrame:buttonListFrame andButtonListItemInfo:buttonInfo] autorelease];

}

-(void)resetFilter
{

	[self.messageFilter resetToDefault:self.filterDmc];
	[self.filterDmc saveContext];

	// Need to reload the parent table view, since the message filter has now been cleared.
	[self.footerDelegate reloadTableView];

}

@end
