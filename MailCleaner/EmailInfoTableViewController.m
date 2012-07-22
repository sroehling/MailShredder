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
#import "MsgListView.h"
#import "EmailAccount.h"
#import "MsgPredicateHelper.h"
#import "DateHelper.h"

#import "TableMenuViewController.h"
#import "TableMenuItem.h"
#import "TableMenuSection.h"
#import "WEPopoverController.h"
#import "WEPopoverHelper.h"

@implementation EmailInfoTableViewController

@synthesize messageFilterHeader;
@synthesize actionsPopupController;
@synthesize actionButton;

-(NSPredicate*)msgListPredicate
{
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.filterDmc];
	
	NSDate *baseDate = [DateHelper today]; 
	NSPredicate *filterPredicate = [sharedAppVals.msgListFilter filterPredicate:baseDate];
	assert(filterPredicate != nil);
	
	return filterPredicate;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
  
    self.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.filterDmc];

	self.messageFilterHeader  = [[[TableHeaderWithDisclosure alloc] initWithFrame:CGRectZero 
				andDisclosureButtonDelegate:self] autorelease];
	[self.messageFilterHeader configureWithCustomButtonImage:@"search.png"];
	self.messageFilterHeader.header.text = sharedAppVals.currentEmailAcct.acctName;
	self.messageFilterHeader.subTitle.text =  sharedAppVals.msgListFilter.filterSynopsis;
	[self.messageFilterHeader resizeForChildren];
	
	self.msgListView.headerView = self.messageFilterHeader;
	[self.msgListView addSubview:self.messageFilterHeader];	
	
	
	
	self.actionButton = [[[UIBarButtonItem alloc] 
		initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self 
		action:@selector(topActionButtonPressed)] autorelease];

	NSMutableArray *sections = [[[NSMutableArray alloc] init] autorelease];
	TableMenuSection *section = [[[TableMenuSection alloc] 
		initWithSectionName:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_NARROW_FILTER_SECTION_TITLE")] autorelease];
	[section addMenuItem:[[[TableMenuItem alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_NARROW_FILTER_SELECTED_ADDRESSES_MENU_TITLE")
		 andTarget:self andSelector:@selector(narrowToSelectedAddresses)] autorelease]];
	[sections addObject:section];
	
	TableMenuViewController *popupMenuController = [[[TableMenuViewController alloc] 
			initWithStyle:UITableViewStyleGrouped 
			andMenuSections:sections andMenuHeight:50.0f] autorelease];
	
	self.actionsPopupController = [[[WEPopoverController alloc] 
		initWithContentViewController:popupMenuController] autorelease];
	self.actionsPopupController.delegate = self;

	[actionsPopupController setContainerViewProperties:[WEPopoverHelper containerViewProperties]];


	self.navigationItem.rightBarButtonItem = actionButton;        
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.filterDmc];
	self.messageFilterHeader.subTitle.text =  sharedAppVals.msgListFilter.filterSynopsis;
	[self.messageFilterHeader resizeForChildren];

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
	
	[self populateDeletePopupListActions:actionButtonInfo];

	PopupButtonListView *popupActionList = [[[PopupButtonListView alloc]
		initWithFrame:self.navigationController.view.frame 
		andButtonListItemInfo:actionButtonInfo] autorelease];
	
	[self.navigationController.view addSubview:popupActionList];
}

#pragma mark Button list call-backs



-(void)narrowToSelectedAddresses
{
	NSLog(@"Narrow to selected addresses");
	[self.actionsPopupController dismissPopoverAnimated:TRUE];
}

-(void)topActionButtonPressed
{		
	[actionsPopupController presentPopoverFromBarButtonItem:self.actionButton 
		permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
}

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController
{
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController
{
	return TRUE;
}



-(void)dealloc
{
	[actionButton release];
	[actionsPopupController release];
	[messageFilterHeader release];
	[super dealloc];
}

@end
