//
//  EmailInfoViewController.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailInfoTableViewController.h"
#import "DataModelController.h"
#import "AppHelper.h"
#import "EmailInfo.h"
#import "DateHelper.h"
#import "LocalizationHelper.h"

#import "EmailInfoActionView.h"
#import "TableHeaderWithDisclosure.h"
#import "TableHeaderDisclosureButtonDelegate.h"
#import "MessageFilterFormInfoCreator.h"
#import "GenericFieldBasedTableEditViewController.h"
#import "SharedAppVals.h"
#import "MessageFilter.h"
#import "CoreDataHelper.h"
#import "PopupButtonListView.h"
#import "PopupButtonListItemInfo.h"

@implementation EmailInfoTableViewController


-(NSPredicate*)msgListPredicate
{
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.filterDmc];
	NSPredicate *filterPredicate = [sharedAppVals.msgListFilter filterPredicate];
	NSPredicate *noTrashPredicate = [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_TRASHED_KEY,[NSNumber numberWithBool:NO]];
	if(filterPredicate != nil)
	{
		NSPredicate *filterAndNoTrashPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:
			[NSArray arrayWithObjects:filterPredicate, noTrashPredicate, nil]];
		return filterAndNoTrashPredicate;
		
	}
	else 
	{
		return noTrashPredicate;
	}		
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
  
    self.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");

	TableHeaderWithDisclosure *tableHeader = 
			[[[TableHeaderWithDisclosure alloc] initWithFrame:CGRectZero 
				andDisclosureButtonDelegate:self] autorelease];
	tableHeader.header.text = @"Message Filter";
	[tableHeader resizeForChildren];
	self.tableView.tableHeaderView = tableHeader;
	
}


#pragma mark TableHeaderDisclosureViewDelegate

- (void)tableHeaderDisclosureButtonPressed
{
	NSLog(@"Disclosure button pressed");
		
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.filterDmc];
	
	MessageFilterFormInfoCreator *msgFilterFormInfoCreator = 
		[[[MessageFilterFormInfoCreator alloc] initWithMsgFilter:sharedAppVals.msgListFilter] autorelease];
		
	GenericFieldBasedTableViewController *msgFilterViewController = 
		[[[GenericFieldBasedTableViewController alloc] initWithFormInfoCreator:msgFilterFormInfoCreator 
		andDataModelController:self.filterDmc] autorelease];
		
	[self.navigationController pushViewController:msgFilterViewController animated:YES];       

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
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_UNLOCK_MSGS_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(unlockMsgsButtonPressed)] autorelease]];
	
	[actionButtonInfo addObject:[[[PopupButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_TRASH_MSGS_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(trashMsgsButtonPressed)] autorelease]];

	PopupButtonListView *popupActionList = [[[PopupButtonListView alloc]
		initWithFrame:self.navigationController.view.frame 
		andButtonListItemInfo:actionButtonInfo] autorelease];
	
	[self.navigationController.view addSubview:popupActionList];
}

#pragma mark Button list call-backs

-(void)trashMsgsButtonPressed
{
	NSLog(@"Trash msgs button pressed");
	NSArray *selectedMsgs = [self selectedInMsgList];
	
	for (EmailInfo *info in selectedMsgs)
	{
		info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
		if(![info.locked boolValue])
		{
			info.trashed = [NSNumber numberWithBool:TRUE];
		}
	}
	[self.emailInfoDmc saveContext];
	[self.tableView reloadData];
}

-(void)lockMsgsButtonPressed
{
	NSLog(@"Lock msgs button pressed");
	NSArray *selectedMsgs = [self selectedInMsgList];
	for (EmailInfo *info in selectedMsgs)
	{
		info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
		info.locked = [NSNumber numberWithBool:TRUE];
	}
	[self.emailInfoDmc saveContext];
	[self.tableView reloadData];
}

-(void)unlockMsgsButtonPressed
{
	NSLog(@"Unlock msgs button pressed");
	NSArray *selectedMsgs = [self selectedInMsgList];
	for (EmailInfo *info in selectedMsgs)
	{
		info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
		info.locked = [NSNumber numberWithBool:FALSE];
	}
	[self.emailInfoDmc saveContext];
	[self.tableView reloadData];
}


-(void)dealloc
{
	[super dealloc];
}

@end
