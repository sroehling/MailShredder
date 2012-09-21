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
#import "MessageFilterTableHeader.h"
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
#import "ColorHelper.h"

#import "TableMenuViewController.h"
#import "TableMenuItem.h"
#import "TableMenuSection.h"
#import "WEPopoverController.h"
#import "WEPopoverHelper.h"

#import "EmailDomainFilter.h"
#import "FromAddressFilter.h"
#import "EmailDomain.h"
#import "EmailAddress.h"
#import "SavedMessageFilterFormInfoCreator.h"
#import "GenericFieldBasedTableAddViewController.h"
#import "AgeFilter.h"
#import "EmailFolderFilter.h"
#import "EmailFolder.h"
#import "RecipientAddressFilter.h"
#import "UIHelper.h"
#import "MoreFormInfoCreator.h"
#import "SavedMessageFilterTableMenuItem.h"
#import "CollectionHelper.h"
#import "ReadFilter.h"
#import "StarredFilter.h"
#import "SubjectFilter.h"
#import "AgeFilterComparison.h"

CGFloat const EMAIL_INFO_TABLE_ACTION_MENU_HEIGHT = 255.0f;

@implementation EmailInfoTableViewController

@synthesize messageFilterHeader;
@synthesize actionsPopupController;
@synthesize loadFilterPopoverController;
@synthesize editFilterDmc;

-(MessageFilter*)currentAcctMsgFilter
{
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	assert(sharedAppVals.currentEmailAcct != nil);
	return sharedAppVals.currentEmailAcct.msgListFilter;
}

-(void)showSettings
{
	MoreFormInfoCreator *settingsFormInfoCreator = 
		[[[MoreFormInfoCreator alloc] init] autorelease];
	UIViewController *settingsViewController = [[[GenericFieldBasedTableViewController alloc]
		initWithFormInfoCreator:settingsFormInfoCreator andDataModelController:self.appDmc] autorelease];

	[self.navigationController pushViewController:settingsViewController animated:YES];  
}

-(void)savedMessagFilterSelectedFromMenu:(MessageFilter*)selectedFilter
{
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	MessageFilter *currentFilter = sharedAppVals.currentEmailAcct.msgListFilter;

	currentFilter.filterName = selectedFilter.filterName;
	[currentFilter.emailDomainFilter setDomains:selectedFilter.emailDomainFilter.selectedDomains];
	[currentFilter.fromAddressFilter setAddresses:selectedFilter.fromAddressFilter.selectedAddresses];
	[currentFilter.recipientAddressFilter setAddresses:selectedFilter.recipientAddressFilter.selectedAddresses];
	[currentFilter.folderFilter setFolders:selectedFilter.folderFilter.selectedFolders];
	currentFilter.ageFilter = selectedFilter.ageFilter;
	
	[self.appDmc saveContext];
	[self refreshMessageList];
	
	[self.loadFilterPopoverController dismissPopoverAnimated:TRUE];

}

-(void)changeFilterResetToDefault
{
	NSLog(@"Reset filter to Default");
	
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	MessageFilter *currentFilter = sharedAppVals.currentEmailAcct.msgListFilter;
	
	[currentFilter resetToDefault:self.appDmc];

	[self.appDmc saveContext];
	[self refreshMessageList];
	
	[self.loadFilterPopoverController dismissPopoverAnimated:TRUE];
}


-(void)messageFilterHeaderLoadFilterButtonPressed
{

	NSMutableArray *sections = [[[NSMutableArray alloc] init] autorelease];

	TableMenuSection *section = [[[TableMenuSection alloc] initWithSectionName:@""] autorelease];
	[section addMenuItem:[[[TableMenuItem alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_RESET_FILTER_MENU_TITLE")
		 andTarget:self andSelector:@selector(changeFilterResetToDefault)] autorelease]];
	[sections addObject:section];
	
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];

	NSArray *sortedSavedFilters = [CollectionHelper 
			setToSortedArray:sharedAppVals.currentEmailAcct.savedMsgListFilters 
			withKey:MESSAGE_FILTER_NAME_KEY];
	NSUInteger numFilters = [sortedSavedFilters count];
	if(numFilters> 0)
	{
		section = [[[TableMenuSection alloc] 
			initWithSectionName:LOCALIZED_STR(@"MESSAGE_LIST_LOAD_FILTER_FILTER_SECTION_TITLE")] autorelease];
		[sections addObject:section];
		
		for(MessageFilter *savedFilter in sortedSavedFilters)
		{
			SavedMessageFilterTableMenuItem *filterMenuItem = 
				[[[SavedMessageFilterTableMenuItem alloc] initWithMessageFilter:savedFilter 
				andFilterSelectedDelegate:self] autorelease];
			[section addMenuItem:filterMenuItem];
		}
	}

	CGFloat tableMenuHeightForAllFilters;
	if(numFilters > 0)
	{
		tableMenuHeightForAllFilters = numFilters * TABLE_MENU_ROW_HEIGHT + 
							2 * TABLE_MENU_SECTION_HEIGHT + 40.0f;	
	}
	else 
	{
		tableMenuHeightForAllFilters = 44.0f;
	}
	CGFloat tableMenuHeight = MIN(EMAIL_INFO_TABLE_ACTION_MENU_HEIGHT,tableMenuHeightForAllFilters); 

	TableMenuViewController *loadFilterMenuController = [[[TableMenuViewController alloc] 
			initWithStyle:UITableViewStyleGrouped 
			andMenuSections:sections andMenuHeight:tableMenuHeight] autorelease];

	self.loadFilterPopoverController = [[[WEPopoverController alloc] 
		initWithContentViewController:loadFilterMenuController] autorelease];
	self.loadFilterPopoverController.delegate = self;

	[self.loadFilterPopoverController setContainerViewProperties:[WEPopoverHelper containerViewProperties]];
	
	// Convert the 'load filter' button's coordinate system to the navigation controller views coordinates
	CGRect loadFilterButtonWindowRect = [self.messageFilterHeader.loadFilterButton.superview 
		convertRect:self.messageFilterHeader.loadFilterButton.frame toView:nil];
	CGRect loadFilterRect = [self.navigationController.view  
		convertRect:loadFilterButtonWindowRect fromView:nil];
		
		
	[self.loadFilterPopoverController presentPopoverFromRect:loadFilterRect
		inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];
}

-(void)editFilterDidSaveNotificiationHandler:(NSNotification*)notification
{
	[self.appDmc.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	
	// If changes are made to the filter, then reset the filter name (if it's not already set
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.editFilterDmc];
	
	// This notification is for saving of the 
	// currently loaded filter. Normally, changes to a saved filter will require
	// the # of messages matching that filter to be updated. However, the
	// count for the current filter isn't displayed, so no background
	// operation is needed to update all the counts.
	
	if([sharedVals.currentEmailAcct.msgListFilter
		nonEmptyFilterName])
	{
		[sharedVals.currentEmailAcct.msgListFilter resetFilterName];
		[self.editFilterDmc saveContext];
	}
}

-(TableMenuViewController *)actionsPopupTableMenuController
{
	BOOL oneOrMoreMsgsSelected = ([self.selectedEmailInfos count] > 0)?TRUE:FALSE;
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];

	NSMutableArray *sections = [[[NSMutableArray alloc] init] autorelease];
	TableMenuSection *narrowFilterSection = [[[TableMenuSection alloc] 
		initWithSectionName:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_NARROW_FILTER_SECTION_TITLE")] autorelease];
	[narrowFilterSection addMenuItem:[[[TableMenuItem alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_SELECTED_ADDRESSES_MENU_TITLE")
		 andTarget:self andSelector:@selector(narrowToSelectedAddresses)
		 andEnabled:oneOrMoreMsgsSelected] autorelease]];
	[narrowFilterSection addMenuItem:[[[TableMenuItem alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_SELECTED_RECIPIENTS_MENU_TITLE")
		 andTarget:self andSelector:@selector(narrowToSelectedRecipients)
		 andEnabled:oneOrMoreMsgsSelected] autorelease]];	
	[narrowFilterSection addMenuItem:[[[TableMenuItem alloc] 
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_SELECTED_DOMAINS_MENU_TITLE")
		 andTarget:self andSelector:@selector(narrowToSelectedDomains)
		 andEnabled:oneOrMoreMsgsSelected] autorelease]];
		 
	TableMenuItem *ageFilterItem = [[[TableMenuItem alloc] 
		initWithTitle:sharedAppVals.defaultAgeFilterOlder3Months.filterSynopsis
		 andTarget:self andSelector:@selector(narrowToAgeFilter:)] autorelease];
	ageFilterItem.objectForSelector = sharedAppVals.defaultAgeFilterOlder3Months;
	[narrowFilterSection addMenuItem:ageFilterItem];

	ageFilterItem = [[[TableMenuItem alloc] 
		initWithTitle:sharedAppVals.defaultAgeFilterOlder6Months.filterSynopsis
		 andTarget:self andSelector:@selector(narrowToAgeFilter:)] autorelease];
	ageFilterItem.objectForSelector = sharedAppVals.defaultAgeFilterOlder6Months;
	[narrowFilterSection addMenuItem:ageFilterItem];

	ageFilterItem = [[[TableMenuItem alloc] 
		initWithTitle:sharedAppVals.defaultAgeFilterOlder1Year.filterSynopsis
		 andTarget:self andSelector:@selector(narrowToAgeFilter:)] autorelease];
	ageFilterItem.objectForSelector = sharedAppVals.defaultAgeFilterOlder1Year;
	[narrowFilterSection addMenuItem:ageFilterItem];
	
		 
	[sections addObject:narrowFilterSection];

	TableMenuSection *currentFilterSection = [[[TableMenuSection alloc]
	initWithSectionName:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_CURRENT_FILTER_SECTION_TITLE")] autorelease];

	[currentFilterSection addMenuItem:[[[TableMenuItem alloc]
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_SAVE_CURRENT_FILTER_TITLE")
		 andTarget:self andSelector:@selector(createMsgFilterCurrentFilter)] autorelease]];

	[currentFilterSection addMenuItem:[[[TableMenuItem alloc]
		initWithTitle:LOCALIZED_STR(@"MESSAGE_LIST_ACTION_EDIT_CURRENT_FILTER_TITLE")
		 andTarget:self andSelector:@selector(msgFilterShowFilterEditor)] autorelease]];


	[sections addObject:currentFilterSection];
	
		
	CGFloat popupMenuHeight = EMAIL_INFO_TABLE_ACTION_MENU_HEIGHT;
	
	return [[[TableMenuViewController alloc] 
			initWithStyle:UITableViewStyleGrouped 
			andMenuSections:sections andMenuHeight:popupMenuHeight] autorelease];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
  
 	NSString *viewTitle = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	if([AppHelper generatingLaunchScreen])
	{
		viewTitle = @" ";
	}
    self.title = viewTitle;


	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];

	self.messageFilterHeader  = [[[MessageFilterTableHeader alloc] initWithDelegate:self] autorelease];
	self.messageFilterHeader.header.text = sharedAppVals.currentEmailAcct.acctName;
	self.messageFilterHeader.subTitle.text =  sharedAppVals.currentEmailAcct.msgListFilter.filterSynopsis;
	[self.messageFilterHeader resizeForChildren];
	
	self.msgListView.headerView = self.messageFilterHeader;
	[self.msgListView addSubview:self.messageFilterHeader];	
	
	// Dedicated DataModelController, and underlying NSManagedObjectContext, for
	// editing the current message filter. This is needed to recieve notifications
	// when editing takes place and to clear the current filter name.
	self.editFilterDmc = [[[DataModelController alloc] 
		initWithPersistentStoreCoord:self.appDmc.persistentStoreCoordinator] autorelease];
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(editFilterDidSaveNotificiationHandler:)
		name:NSManagedObjectContextDidSaveNotification 
		object:self.editFilterDmc.managedObjectContext];	

	self.navigationItem.rightBarButtonItem = [UIHelper buttonItemWithImage:@"settings.png"
		andTarget:self andAction:@selector(showSettings)];
	
	// Once the message view is finished loading, start a synchronization to refresh the messages.
	AppDelegate *theAppDelegate = [AppHelper theAppDelegate];
	[theAppDelegate performSelector:@selector(syncWithServerInBackgroundThread) withObject:nil afterDelay:2.0];

}

- (void)refreshMessageFilterHeader
{
	EmailAccount *currentAcct = [AppHelper theAppDelegate].sharedAppVals.currentEmailAcct;
	assert(currentAcct != nil);
	
	NSString *filterHeaderText; 
	if([currentAcct.msgListFilter nonEmptyFilterName])
	{
		filterHeaderText = [NSString stringWithFormat:@"%@ - %@",
			currentAcct.acctName,currentAcct.msgListFilter.filterName];
	}
	else
	{
		filterHeaderText = currentAcct.acctName;
	}

	self.messageFilterHeader.header.text = filterHeaderText;
	self.messageFilterHeader.subTitle.text =  [self currentAcctMsgFilter].filterSynopsis;
	[self.messageFilterHeader resizeForChildren];

}

-(void)refreshMessageList
{
	[self refreshMessageFilterHeader];
		// TODO - Need to update selection to only include those messages which are seen.

	[self configureFetchedResultsController];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self refreshMessageFilterHeader];

}

-(void)viewDidUnload
{
	[super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
	name:NSManagedObjectContextDidSaveNotification 
	object:self.editFilterDmc.managedObjectContext];

}

#pragma mark MessageFilterTableHeaderDelegate

-(void)msgFilterEditDone
{
	[self.editFilterDmc saveContext];
	[self.editFilterDmc.managedObjectContext reset];
	[self.navigationController dismissModalViewControllerAnimated:TRUE];
}

- (void)msgFilterShowFilterEditor
{

	[self.actionsPopupController dismissPopoverAnimated:TRUE];

	[self.appDmc saveContext];
	[self.editFilterDmc.managedObjectContext reset];
	
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.editFilterDmc];
	
	MessageFilterFormInfoCreator *msgFilterFormInfoCreator = 
		[[[MessageFilterFormInfoCreator alloc] 
		initWithMsgFilter:sharedVals.currentEmailAcct.msgListFilter] autorelease];
		
	GenericFieldBasedTableViewController *msgFilterViewController = 
		[[[GenericFieldBasedTableViewController alloc] initWithFormInfoCreator:msgFilterFormInfoCreator 
		andDataModelController:self.editFilterDmc] autorelease];

	UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:msgFilterViewController] autorelease];
	navController.navigationBar.tintColor = [ColorHelper navBarTintColor];
	
	msgFilterViewController.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
		initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
		target:self action:@selector(msgFilterEditDone)] autorelease];

	navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;

	[self.navigationController presentModalViewController:navController animated:TRUE];
}

#pragma mark Button list call-backs

-(MessageFilter*)resetObjectContextAndCreateNewMessageFilter
{
	[self.saveMsgFilterDmc.managedObjectContext reset];
	MessageFilter *newFilter = [MessageFilter defaultMessageFilter:self.saveMsgFilterDmc];
	return newFilter;
}

-(NSSet*)selectedRecipients
{
	NSArray *selectedMsgs = [self selectedInMsgList];
	NSMutableSet *selectedRecipients = [[[NSMutableSet alloc] init] autorelease];
	
	for(EmailInfo *selectedEmailInfo in selectedMsgs)
	{
		for(EmailAddress *selectedRecipient in selectedEmailInfo.recipientAddresses)
		{
			[selectedRecipients addObject:selectedRecipient];
		}
	}
	return selectedRecipients;

}

-(NSSet*)selectedAddresses
{
	NSArray *selectedMsgs = [self selectedInMsgList];
	
	NSMutableSet *selectedAddresses = [[[NSMutableSet alloc] init] autorelease];
	
	for(EmailInfo *selectedEmailInfo in selectedMsgs)
	{
		[selectedAddresses addObject:selectedEmailInfo.senderAddress];
	}
	return selectedAddresses;
}

-(NSSet*)selectedDomains
{
	NSArray *selectedMsgs = [self selectedInMsgList];
		
	NSMutableSet *selectedDomains = [[[NSMutableSet alloc] init] autorelease];

	for(EmailInfo *selectedEmailInfo in selectedMsgs)
	{
		[selectedDomains addObject:selectedEmailInfo.senderDomain];
	}
	return selectedDomains;
}

-(void)narrowToSelectedAddresses
{
	NSLog(@"Narrow to selected addresses");
	
	NSSet *selectedAddresses = [self selectedAddresses];
	
	if([selectedAddresses count] > 0)
	{
		MessageFilter *currentFilter = [self currentAcctMsgFilter];
		[currentFilter resetFilterName];

		[currentFilter.fromAddressFilter setAddresses:selectedAddresses];
		[self.appDmc saveContext];
		
		[self refreshMessageList];
	}
	[self.actionsPopupController dismissPopoverAnimated:TRUE];
}

-(void)narrowToSelectedRecipients
{
	NSLog(@"Narrow to selected recipients");
	
	NSSet *selectedRecipients = [self selectedRecipients];
	
	if([selectedRecipients count] > 0)
	{
		MessageFilter *currentFilter = [self currentAcctMsgFilter];
		[currentFilter resetFilterName];
	
		[currentFilter.recipientAddressFilter setAddresses:selectedRecipients];
		[self.appDmc saveContext];
		
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
		MessageFilter *currentFilter = [self currentAcctMsgFilter];
		[currentFilter resetFilterName];

		[currentFilter.emailDomainFilter setDomains:selectedDomains];
		[self.appDmc saveContext];
		
		[self refreshMessageList];
	}
	[self.actionsPopupController dismissPopoverAnimated:TRUE];
}

-(void)narrowToAgeFilter:(id)ageFilter
{
	assert([ageFilter isKindOfClass:[AgeFilter class]]);
	AgeFilterComparison *theComparison = (AgeFilterComparison*)ageFilter;

	MessageFilter *currentFilter = [self currentAcctMsgFilter];
	[currentFilter resetFilterName];

	currentFilter.ageFilter = theComparison;
	[self.appDmc saveContext];
	
	[self refreshMessageList];
	
	[self.actionsPopupController dismissPopoverAnimated:TRUE];
}

-(void)pushNewMessageFilterForm:(MessageFilter*)newFilter
{
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.saveMsgFilterDmc];
	newFilter.emailAcctSavedFilter = sharedVals.currentEmailAcct;

	SavedMessageFilterFormInfoCreator *savedMessageFilterFormCreator = 
		[[[SavedMessageFilterFormInfoCreator alloc] initWithEmailAcct:sharedVals.currentEmailAcct 
		andMessageFilter:newFilter] autorelease];
	
	GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
		initWithFormInfoCreator:savedMessageFilterFormCreator andNewObject:newFilter
		andDataModelController:self.saveMsgFilterDmc] autorelease];
	addView.popDepth = 1;
	addView.saveWhenSaveButtonPressed = TRUE;

	[self.actionsPopupController dismissPopoverAnimated:FALSE];

	[self.navigationController pushViewController:addView animated:TRUE];
}



-(void)createMsgFilterCurrentFilter
{
	NSLog(@"Create trash rule from current filter settings");
	
	MessageFilter *newFilter = [self resetObjectContextAndCreateNewMessageFilter];
	MessageFilter *msgFilter = [self currentAcctMsgFilter];
	
	[newFilter.emailDomainFilter setDomains:
		[CoreDataHelper objectsInOtherContext:self.saveMsgFilterDmc.managedObjectContext 
		forOriginalObjs:msgFilter.emailDomainFilter.selectedDomains]];
		
	[newFilter.fromAddressFilter setAddresses:
		[CoreDataHelper objectsInOtherContext:self.saveMsgFilterDmc.managedObjectContext 
		forOriginalObjs:msgFilter.fromAddressFilter.selectedAddresses]];
		
	[newFilter.recipientAddressFilter setAddresses:
		[CoreDataHelper objectsInOtherContext:self.saveMsgFilterDmc.managedObjectContext 
		forOriginalObjs:msgFilter.recipientAddressFilter.selectedAddresses]];
		
	[newFilter.folderFilter setFolders:
		[CoreDataHelper objectsInOtherContext:self.saveMsgFilterDmc.managedObjectContext 
		forOriginalObjs:msgFilter.folderFilter.selectedFolders]];
		
	newFilter.ageFilter = (AgeFilter*)[CoreDataHelper objectInOtherContext:self.saveMsgFilterDmc.managedObjectContext
			forOriginalObj:msgFilter.ageFilter];
			
	newFilter.readFilter = (ReadFilter*)[CoreDataHelper objectInOtherContext:self.saveMsgFilterDmc.managedObjectContext
			forOriginalObj:msgFilter.readFilter];
			
	newFilter.starredFilter = (StarredFilter*)[CoreDataHelper objectInOtherContext:self.saveMsgFilterDmc.managedObjectContext
			forOriginalObj:msgFilter.starredFilter];
			
	newFilter.subjectFilter.searchString = msgFilter.subjectFilter.searchString;
	newFilter.subjectFilter.caseSensitive = msgFilter.subjectFilter.caseSensitive;

	[self pushNewMessageFilterForm:newFilter];
	
}


-(void)messageFilterHeaderEditFilterButtonPressed
{		
	TableMenuViewController *popupMenuController = [self actionsPopupTableMenuController];
	self.actionsPopupController = [[[WEPopoverController alloc] 
		initWithContentViewController:popupMenuController] autorelease];
	self.actionsPopupController.delegate = self;
	[actionsPopupController setContainerViewProperties:[WEPopoverHelper containerViewProperties]];


	// Convert the popup button from the view coordinates to local window coordinates
	CGRect editFilterButtonWindowRect = [self.messageFilterHeader.editFilterButton.superview
		convertRect:self.messageFilterHeader.editFilterButton.frame toView:nil];
	CGRect editFilterRect = [self.navigationController.view
		convertRect:editFilterButtonWindowRect fromView:nil];


	[self.actionsPopupController presentPopoverFromRect:editFilterRect
		inView:self.navigationController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:TRUE];

}

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)popoverController
{
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)popoverController
{
	return TRUE;
}

#pragma mark CurrentEmailAccountChangedListener

-(void)currentAcctChanged:(EmailAccount *)currentAccount
{
	[self refreshMessageList];
}

-(void)dealloc
{
	[actionsPopupController release];
	[messageFilterHeader release];
	[editFilterDmc release];
	[super dealloc];
}

@end
