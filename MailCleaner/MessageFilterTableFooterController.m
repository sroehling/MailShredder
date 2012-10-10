//
//  MessageFilterTableFooterController.m
//
//  Created by Steve Roehling on 7/20/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
#import "UIHelper.h"

CGFloat const MESSAGE_FILTER_FOOTER_RESET_BUTTON_HEIGHT = 30.0f;
CGFloat const MESSAGE_FILTER_FOOTER_RESET_BUTTON_MARGIN = 10.0f;
CGFloat const MESSAGE_FILTER_FOOTER_RESET_BUTTON_FONT_SIZE = 15.0f;


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
		 
	UIButton *resetButton = [UIHelper buttonWithBackgroundColor:[UIColor whiteColor] 
			andTitleColor:[UIColor darkGrayColor] 
			andTarget:self andAction:@selector(resetFilter) andTitle:LOCALIZED_STR(@"MESSAGE_FILTER_RESET_FILTER_BUTTON_TITLE") 
			andFontSize:MESSAGE_FILTER_FOOTER_RESET_BUTTON_FONT_SIZE];

	CGRect buttonFrame = CGRectMake(MESSAGE_FILTER_FOOTER_RESET_BUTTON_MARGIN, 0, 
		[UIScreen mainScreen].bounds.size.width-(2 * MESSAGE_FILTER_FOOTER_RESET_BUTTON_MARGIN), 
		MESSAGE_FILTER_FOOTER_RESET_BUTTON_HEIGHT);
	[resetButton setFrame:buttonFrame];
	
	UIView *theFooterView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,
		[UIScreen mainScreen].bounds.size.width,MESSAGE_FILTER_FOOTER_RESET_BUTTON_HEIGHT)] autorelease];
	[theFooterView addSubview:resetButton];
	
	return theFooterView;
		

}

-(void)resetFilter
{

	[self.messageFilter resetToDefault:self.parentContext.dataModelController];
	
	[self.parentContext.dataModelController saveContext];

	// Need to reload the parent table view, since the message filter has now been cleared.
	[self.footerDelegate reloadTableView];

}






@end
