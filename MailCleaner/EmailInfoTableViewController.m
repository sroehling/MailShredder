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
#import "MessageListActionView.h"
#import "CoreDataHelper.h"


@implementation EmailInfoTableViewController


@synthesize emailActionView;


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
	self.tableView.tableFooterView = [[[EmailInfoActionView alloc] initWithDelegate:self] autorelease];
	
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
	MessageListActionView *actionsList = [[[MessageListActionView alloc]
		initWithFrame:self.navigationController.view.frame andDelegate:self] autorelease];
	[self.navigationController.view addSubview:actionsList];
}

#pragma mark MessageListActionViewDelegate

-(void)trashMsgsButtonPressed
{
	NSLog(@"Trash msgs button pressed");
	NSArray *selectedMsgs = [self selectedInMsgList];
	for (EmailInfo *info in selectedMsgs)
	{
		info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
		info.trashed = [NSNumber numberWithBool:TRUE];
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


-(void)dealloc
{
	[emailActionView release];
	[super dealloc];
}

@end
