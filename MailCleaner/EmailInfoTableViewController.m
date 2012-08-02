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

#import "EmailDomainFilter.h"
#import "EmailAddressFilter.h"
#import "EmailDomain.h"
#import "EmailAddress.h"
#import "TrashRule.h"
#import "TrashRuleFormInfoCreator.h"
#import "GenericFieldBasedTableAddViewController.h"
#import "AgeFilter.h"
#import "EmailFolderFilter.h"
#import "EmailFolder.h"

CGFloat const EMAIL_INFO_TABLE_ACTION_MENU_HEIGHT = 182.0f;

@implementation EmailInfoTableViewController

@synthesize messageFilterHeader;
@synthesize actionsPopupController;
@synthesize actionButton;

-(NSPredicate*)msgListPredicate
{
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	
	NSDate *baseDate = [DateHelper today]; 
	NSPredicate *filterPredicate = [sharedAppVals.msgListFilter filterPredicate:baseDate];
	assert(filterPredicate != nil);
	
	return filterPredicate;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
  
    self.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];

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
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_SELECTED_ADDRESSES_MENU_TITLE")
		 andTarget:self andSelector:@selector(narrowToSelectedAddresses)] autorelease]];
	[section addMenuItem:[[[TableMenuItem alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_SELECTED_DOMAINS_MENU_TITLE")
		 andTarget:self andSelector:@selector(narrowToSelectedDomains)] autorelease]];
	[sections addObject:section];

	section = [[[TableMenuSection alloc] 
		initWithSectionName:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_CREATE_TRASH_RULE_SECTION_TITLE")] autorelease];
	[section addMenuItem:[[[TableMenuItem alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_SELECTED_ADDRESSES_MENU_TITLE")
		 andTarget:self andSelector:@selector(createTrashRuleSelectedAddresses)] autorelease]];
	[section addMenuItem:[[[TableMenuItem alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_SELECTED_DOMAINS_MENU_TITLE")
		 andTarget:self andSelector:@selector(createTrashRuleSelectedDomains)] autorelease]];
	[section addMenuItem:[[[TableMenuItem alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_CURRENT_FILTER_MENU_TITLE")
		 andTarget:self andSelector:@selector(createTrashRuleCurrentFilter)] autorelease]];
	[sections addObject:section];

	
	TableMenuViewController *popupMenuController = [[[TableMenuViewController alloc] 
			initWithStyle:UITableViewStyleGrouped 
			andMenuSections:sections andMenuHeight:EMAIL_INFO_TABLE_ACTION_MENU_HEIGHT] autorelease];
	
	self.actionsPopupController = [[[WEPopoverController alloc] 
		initWithContentViewController:popupMenuController] autorelease];
	self.actionsPopupController.delegate = self;

	[actionsPopupController setContainerViewProperties:[WEPopoverHelper containerViewProperties]];


	self.navigationItem.rightBarButtonItem = actionButton;        
}

- (void)refreshMessageFilterHeader
{
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	self.messageFilterHeader.subTitle.text =  sharedAppVals.msgListFilter.filterSynopsis;
	[self.messageFilterHeader resizeForChildren];

}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self refreshMessageFilterHeader];

}

#pragma mark TableHeaderDisclosureViewDelegate

- (void)tableHeaderDisclosureButtonPressed
{
	NSLog(@"Disclosure button pressed");
		
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	
	MessageFilterFormInfoCreator *msgFilterFormInfoCreator = 
		[[[MessageFilterFormInfoCreator alloc] initWithMsgFilter:sharedAppVals.msgListFilter] autorelease];
		
	GenericFieldBasedTableViewController *msgFilterViewController = 
		[[[GenericFieldBasedTableViewController alloc] initWithFormInfoCreator:msgFilterFormInfoCreator 
		andDataModelController:self.appDmc] autorelease];
		
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

-(void)refreshMessageList
{
	[self refreshMessageFilterHeader];
		// TODO - Need to update selection to only include those messages which are seen.

	[self configureFetchedResultsController];
}

-(NSSet*)selectedAddresses
{
	NSArray *selectedMsgs = [self selectedInMsgList];

	NSMutableDictionary *currAddressesByAddress = [EmailAddress addressesByName:self.appDmc];
	NSMutableSet *selectedAddresses = [[[NSMutableSet alloc] init] autorelease];
	
	for(EmailInfo *selectedEmailInfo in selectedMsgs)
	{
		[selectedAddresses addObject:[EmailAddress findOrAddAddress:selectedEmailInfo.from 
			withCurrentAddresses:currAddressesByAddress inDataModelController:self.appDmc]];
	}
	return selectedAddresses;
}

-(NSSet*)selectedDomains
{
	NSArray *selectedMsgs = [self selectedInMsgList];
	NSMutableDictionary *currDomainsByName = [EmailDomain emailDomainsByDomainName:self.appDmc];
	NSMutableSet *selectedDomains = [[[NSMutableSet alloc] init] autorelease];

	for(EmailInfo *selectedEmailInfo in selectedMsgs)
	{
		[selectedDomains addObject:[EmailDomain findOrAddDomainName:selectedEmailInfo.domain 
			withCurrentDomains:currDomainsByName inDataModelController:self.appDmc]];
	}
	return selectedDomains;
}

-(void)narrowToSelectedAddresses
{
	NSLog(@"Narrow to selected addresses");
	
	NSSet *selectedAddresses = [self selectedAddresses];
	
	if([selectedAddresses count] > 0)
	{
		SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
		[sharedAppVals.msgListFilter.emailAddressFilter setAddresses:selectedAddresses];
		
		[self refreshMessageList];
	}
	[self.actionsPopupController dismissPopoverAnimated:TRUE];
}

-(void)narrowToSelectedDomains
{
	NSLog(@"Narrow to selected domains");
	
	NSSet *selectedDomains = [self selectedDomains];
	if([selectedDomains count] > 0)
	{
		SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];		
		[sharedAppVals.msgListFilter.emailDomainFilter setDomains:selectedDomains];
		
		[self refreshMessageList];
	}
	[self.actionsPopupController dismissPopoverAnimated:TRUE];
}

-(void)pushNewRuleForm:(TrashRule*)newRule
{
	TrashRuleFormInfoCreator *ruleFormCreator = 
		[[[TrashRuleFormInfoCreator alloc] initWithTrashRule:newRule] autorelease];
	
	GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
		initWithFormInfoCreator:ruleFormCreator andNewObject:newRule
		andDataModelController:self.appDmc] autorelease];
	addView.popDepth = 1;

	[self.actionsPopupController dismissPopoverAnimated:FALSE];

	[self.navigationController pushViewController:addView animated:TRUE];
}


-(void)createTrashRuleSelectedAddresses
{
	NSLog(@"Create trash rule from selected addresses");
	
	NSSet *selectedAddresses = [self selectedAddresses];
	
	if([selectedAddresses count] > 0)
	{
		TrashRule *newRule = [TrashRule createNewDefaultRule:self.appDmc];
		[newRule.emailAddressFilter setAddresses:selectedAddresses];

		[self pushNewRuleForm:newRule];
	}
	else 
	{
		[self.actionsPopupController dismissPopoverAnimated:TRUE];
	}

}


-(void)createTrashRuleSelectedDomains
{
	NSLog(@"Create trash rule from selected domains");
	
	NSSet *selectedDomains = [self selectedDomains];
	if([selectedDomains count] > 0)
	{
		TrashRule *newRule = [TrashRule createNewDefaultRule:self.appDmc];
		[newRule.emailDomainFilter setDomains:selectedDomains];
		[self pushNewRuleForm:newRule];
	}
	else 
	{
		[self.actionsPopupController dismissPopoverAnimated:TRUE];
	}
}

-(void)createTrashRuleCurrentFilter
{
	NSLog(@"Create trash rule from current filter settings");
	
	TrashRule *newRule = [TrashRule createNewDefaultRule:self.appDmc];
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];		
	
	[newRule.emailDomainFilter setDomains:sharedAppVals.msgListFilter.emailDomainFilter.selectedDomains];
	[newRule.emailAddressFilter setAddresses:sharedAppVals.msgListFilter.emailAddressFilter.selectedAddresses];
	[newRule.folderFilter setFolders:sharedAppVals.msgListFilter.folderFilter.selectedFolders];
	newRule.ageFilter = sharedAppVals.msgListFilter.ageFilter;

	[self pushNewRuleForm:newRule];
	
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
