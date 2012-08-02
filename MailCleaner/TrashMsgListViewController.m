//
//  TrashMsgListViewController.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrashMsgListViewController.h"
#import "LocalizationHelper.h"
#import "EmailInfo.h"
#import "PopupButtonListView.h"
#import "DataModelController.h"
#import "MsgListView.h"
#import "MailClientServerSyncController.h"
#import "VariableHeightTableHeader.h"
#import "MsgListView.h"
#import "MsgListTableViewController.h"
#import "TrashMsgListViewInfo.h"

@implementation TrashMsgListViewController

@synthesize viewInfo;

-(id)initWithViewInfo:(TrashMsgListViewInfo*)theViewInfo
{
	self = [super initWithAppDataModelController:theViewInfo.appDmc];
	if(self)
	{
		assert(theViewInfo != nil);
		self.viewInfo = theViewInfo;
	}
	return self;
}


-(id)initWithAppDataModelController:(DataModelController *)theAppDmc
{
	assert(0);
	return nil;
}

-(void)dealloc
{
	[viewInfo release];
	[super dealloc];
}

-(NSPredicate*)msgListPredicate
{
	return self.viewInfo.msgListPredicate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = LOCALIZED_STR(@"TRASH_VIEW_TITLE");

	// Create a view subtitle and header to describe what's shown in the list
	
	VariableHeightTableHeader *tableHeader = 
		[[[VariableHeightTableHeader alloc] initWithFrame:CGRectZero] autorelease];
	tableHeader.header.text = self.viewInfo.listHeader;
	tableHeader.subHeader.text = self.viewInfo.listSubheader;
	[tableHeader resizeForChildren];
	self.msgListView.headerView = tableHeader;
	[self.msgListView addSubview:tableHeader];	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


#pragma mark EmailActionViewDelegate

-(void)actionButtonPressed
{
	NSLog(@"Action button pressed");
	
	NSMutableArray *actionButtonInfo = [[[NSMutableArray alloc] init] autorelease];
	
	[self populateDeletePopupListActions:actionButtonInfo];
	
	PopupButtonListView *popupActionList = [[[PopupButtonListView alloc]
		initWithFrame:self.navigationController.view.frame 
		andButtonListItemInfo:actionButtonInfo] autorelease];
	
	[self.navigationController.view addSubview:popupActionList];
}





@end
