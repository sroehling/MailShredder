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
#import "WEPopoverController.h"
#import "TableMenuViewController.h"
#import "TableMenuItem.h"
#import "FormContext.h"
#import "TableMenuSection.h"

@implementation MessageFilterTableFooterController

@synthesize messageFilter;
@synthesize parentContext;
@synthesize filterOptionsPopupController;

-(id)initWithMessageFilter:(MessageFilter*)theMessageFilter 
	andParentContext:(FormContext*)theParentContext
{
	self = [super init];
	if(self)
	{
		self.messageFilter = theMessageFilter;
		self.parentContext = theParentContext;
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
	[parentContext release];
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
	ButtonListView *footerButtonList = [[[ButtonListView alloc] initWithFrame:buttonListFrame 
		andButtonListItemInfo:buttonInfo] autorelease];
	return footerButtonList;

}

-(void)resetFilter
{

	[self.messageFilter resetToDefault:self.parentContext.dataModelController];
	
	[self.parentContext.dataModelController saveContext];

	// Need to reload the parent table view, since the message filter has now been cleared.
	[self.footerDelegate reloadTableView];

}






@end
