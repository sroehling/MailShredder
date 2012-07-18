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
#import "PopupButtonListItemInfo.h"
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
	self = [super initWithEmailInfoDataModelController:theViewInfo.emailInfoDmc 
			andAppDataModelController:theViewInfo.appDmc];
	if(self)
	{
		assert(theViewInfo != nil);
		self.viewInfo = theViewInfo;
	}
	return self;
}


-(id)initWithEmailInfoDataModelController:(DataModelController *)theEmailInfoDmc andAppDataModelController:(DataModelController *)theAppDmc
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

#pragma mark Button list call-backs

-(void)lockMsgsButtonPressed
{
	NSLog(@"Lock msgs button pressed");
	NSArray *selectedMsgs = [self selectedInMsgList];
	for (EmailInfo *info in selectedMsgs)
	{
		info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
		info.locked = [NSNumber numberWithBool:TRUE];
		info.trashed= [NSNumber numberWithBool:FALSE];
	}
	[self.emailInfoDmc saveContext];
	[self.msgListView.msgListTableView reloadData];
}

-(void)untrashMsgsButtonPressed
{
	NSLog(@"Un-trash msgs button pressed");
	NSArray *selectedMsgs = [self selectedInMsgList];
	
	for (EmailInfo *info in selectedMsgs)
	{
		info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
		info.trashed = [NSNumber numberWithBool:FALSE];
	}
	[self.emailInfoDmc saveContext];
	[self.msgListView.msgListTableView reloadData];
}

-(void)deleteTrashedMsgList:(NSArray*)trashedMsgs
{
	for (EmailInfo *info in trashedMsgs)
	{
		info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
		info.deleted = [NSNumber numberWithBool:TRUE];
		
	}
	[self.emailInfoDmc saveContext];
	[self.msgListView.msgListTableView reloadData];
	
	MailClientServerSyncController *mailSync = [[[MailClientServerSyncController alloc] 
			initWithDataModelController:self.emailInfoDmc
			andAppDataDmc:self.filterDmc] autorelease];
	[mailSync deleteMarkedMsgs];	

}

-(void)deleteAllTrashedMsgsButtonPressed
{
	NSLog(@"Delete All Trashed Messages button pressed");
	[self deleteTrashedMsgList:[self allMsgsInMsgList]];
}

-(void)deleteSelectedTrashedMsgsButtonPressed
{
	NSLog(@"Delete Selected Messages button pressed");
	[self deleteTrashedMsgList:[self selectedInMsgList]];
}

#pragma mark EmailActionViewDelegate

-(void)actionButtonPressed
{
	NSLog(@"Action button pressed");
	
	NSMutableArray *actionButtonInfo = [[[NSMutableArray alloc] init] autorelease];
	
	[actionButtonInfo addObject:[[[PopupButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_LOCK_MSGS_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(lockMsgsButtonPressed)] autorelease]];

	[actionButtonInfo addObject:[[[PopupButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"TRASH_LIST_ACTION_UNTRASH_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(untrashMsgsButtonPressed)] autorelease]];

	[actionButtonInfo addObject:[[[PopupButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"TRASH_LIST_ACTION_DELETE_SELECTED_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(deleteSelectedTrashedMsgsButtonPressed)] autorelease]];

	[actionButtonInfo addObject:[[[PopupButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"TRASH_LIST_ACTION_DELETE_ALL_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(deleteAllTrashedMsgsButtonPressed)] autorelease]];

	
	PopupButtonListView *popupActionList = [[[PopupButtonListView alloc]
		initWithFrame:self.navigationController.view.frame 
		andButtonListItemInfo:actionButtonInfo] autorelease];
	
	[self.navigationController.view addSubview:popupActionList];
}





@end
