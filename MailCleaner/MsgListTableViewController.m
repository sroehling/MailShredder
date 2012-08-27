//
//  MsgListViewController.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgListTableViewController.h"
#import "DataModelController.h"
#import "AppHelper.h"
#import "EmailInfo.h"
#import "DateHelper.h"
#import "LocalizationHelper.h"
#import "CoreDataHelper.h"
#import "EmailInfoActionView.h"
#import "MsgTableCell.h"
#import "MsgListView.h"
#import "UIHelper.h"
#import "MailClientServerSyncController.h"
#import "ButtonListItemInfo.h"
#import "AppDelegate.h"
#import "EmailAddress.h"
#import "AppHelper.h"
#import "CompositeMailSyncProgressDelegate.h"
#import "DeleteMsgConfirmationView.h"
#import "MsgDetailViewController.h"
#import "SharedAppVals.h"
#import "MsgPredicateHelper.h"


@implementation MsgListTableViewController

@synthesize emailInfoFrc;
@synthesize appDmc;
@synthesize msgListView;
@synthesize selectedEmailInfos;


- (id)initWithAppDataModelController:(DataModelController*)theAppDmc
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		self.appDmc = theAppDmc;
		
		self.selectedEmailInfos = [[[NSMutableSet alloc] init] autorelease]; 
    }
    return self;
}

-(id)init
{
	assert(0);
	return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	assert(0);
	return nil;
}


-(NSPredicate*)msgListPredicate
{
	assert(0); // must be overridden
	return nil;
}

-(void)selectEmailInfo:(EmailInfo*)emailInfo
{
	assert(emailInfo != nil);
	[self.selectedEmailInfos addObject:emailInfo];
}

-(void)deselectEmailInfo:(EmailInfo*)emailInfo
{
	assert(emailInfo != nil);
	[self.selectedEmailInfos removeObject:emailInfo];
}


-(NSArray *)selectedInMsgList
{
	return [self.selectedEmailInfos allObjects];
}


-(void)unselectAllMsgs
{
	UITableView *tableView = self.msgListView.msgListTableView;
	
	for (int sectionNum = 0; sectionNum < [tableView numberOfSections]; sectionNum++) 
	{
		for (int rowNum = 0; rowNum < [tableView numberOfRowsInSection:sectionNum]; rowNum++) {
			NSIndexPath *emailInfoPath = [NSIndexPath indexPathForRow:rowNum	inSection:sectionNum];
			[tableView deselectRowAtIndexPath:emailInfoPath animated:FALSE];
			// Note that deselectRowAtIndexPath will not call didDeselectRowAtIndexPath,
			// the selection needs to be updated.
			[self deselectEmailInfo:[self.emailInfoFrc objectAtIndexPath:emailInfoPath]];
 		}
	}
	[self.selectedEmailInfos removeAllObjects];
}

-(void)selectAllMsgs
{
	UITableView *tableView = self.msgListView.msgListTableView;
	
	for (int sectionNum = 0; sectionNum < [tableView numberOfSections]; sectionNum++) 
	{
		for (int rowNum = 0; rowNum < [tableView numberOfRowsInSection:sectionNum]; rowNum++) {
			NSIndexPath *emailInfoPath = [NSIndexPath indexPathForRow:rowNum	inSection:sectionNum];
            [tableView selectRowAtIndexPath:emailInfoPath
                animated:FALSE scrollPosition:UITableViewScrollPositionNone];
			// Note that deselectRowAtIndexPath will not call didSelectRowAtIndexPath,
			// the selection needs to be updated.
			[self selectEmailInfo:[self.emailInfoFrc objectAtIndexPath:emailInfoPath]];
		}
	}

}

- (void)configureCell:(MsgTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EmailInfo *info = [self.emailInfoFrc objectAtIndexPath:indexPath];
    cell.fromLabel.text = [info.senderAddress nameOrAddress];
    cell.sendDateLabel.text = [info formattedSendDate];
	cell.subjectLabel.text = info.subject;
	if([self.selectedEmailInfos containsObject:info])
	{
		[self.msgListView.msgListTableView selectRowAtIndexPath:indexPath 
		animated:FALSE scrollPosition:UITableViewScrollPositionNone];
	}
	cell.accessoryType =UITableViewCellAccessoryDetailDisclosureButton;	
}

-(NSFetchRequest*)allMsgsFetchRequest
{
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_INFO_ENTITY_NAME 
		inManagedObjectContext:self.appDmc.managedObjectContext];
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
		initWithKey:EMAIL_INFO_SEND_DATE_KEY ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSPredicate *currentAcctPredicate = [MsgPredicateHelper emailInfoInCurrentAcctPredicate:self.appDmc];
		
	NSPredicate *matchFilterInCurrentAcct = [NSCompoundPredicate andPredicateWithSubpredicates:
		[NSArray arrayWithObjects:currentAcctPredicate, [self msgListPredicate],nil]];

	[fetchRequest setPredicate:matchFilterInCurrentAcct];
	[fetchRequest setFetchBatchSize:20];
	return fetchRequest;
}

-(NSArray*)allMsgsInMsgList
{
	return [CoreDataHelper executeFetchOrThrow:[self allMsgsFetchRequest] 
		inManagedObectContext:self.appDmc.managedObjectContext];
}

-(void)updateSelectionForCurrentResults
{
	NSArray *fetchedObjects = [self.emailInfoFrc fetchedObjects];

	NSMutableSet *emailInfosToDeselect = [[[NSMutableSet alloc] init] autorelease];
	for(EmailInfo *selectedInfo in self.selectedEmailInfos)
	{
		if(![fetchedObjects containsObject:selectedInfo])
		{
			[emailInfosToDeselect addObject:selectedInfo];
		}
	}
	for(EmailInfo *emailInfoToDeselect in emailInfosToDeselect)
	{
		[self deselectEmailInfo:emailInfoToDeselect];
	}
}

-(void)configureFetchedResultsController
{
 
	self.emailInfoFrc = [[[NSFetchedResultsController alloc] 
			initWithFetchRequest:[self allMsgsFetchRequest]
			managedObjectContext:self.appDmc.managedObjectContext 
			sectionNameKeyPath:nil cacheName:nil] autorelease];
	self.emailInfoFrc.delegate = self;

 
    NSError *error;
	if (![self.emailInfoFrc performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	// When the fetched results controller for this table is
	// reconfigured, the list of selected objects also needs to be 
	// changed to reflect the current visible/fetched results.
	[self updateSelectionForCurrentResults];
	
	[self.msgListView.msgListTableView reloadData];

}

- (void)setTitle:(NSString *)title
{
	[super setTitle:title];
	[UIHelper setCommonTitleForController:self withTitle:title];
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self deselectEmailInfo:[self.emailInfoFrc objectAtIndexPath:indexPath]];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[self selectEmailInfo:[self.emailInfoFrc objectAtIndexPath:indexPath]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
 
    MsgTableCell *cell = (MsgTableCell*)[tableView dequeueReusableCellWithIdentifier:MSG_TABLE_CELL_IDENTIFIER];
	if(cell == nil)
	{
		cell = [[[MsgTableCell alloc] init] autorelease]; 
	}
 
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
 
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	EmailInfo *info = [self.emailInfoFrc objectAtIndexPath:indexPath];

	MsgDetailViewController *msgDetailViewCtlr = 
		[[[MsgDetailViewController alloc] initWithEmailInfo:info 
		andMainThreadDmc:self.appDmc] autorelease];
		
	[self.navigationController pushViewController:msgDetailViewCtlr animated:TRUE];	
}


- (void)viewDidLoad {
    [super viewDidLoad];
 
	[self configureFetchedResultsController];
 
    self.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	
	self.msgListView = [[[MsgListView alloc] initWithFrame:CGRectZero] autorelease];
	self.msgListView.msgListActionFooter.delegate = self;
	self.msgListView.msgListTableView.delegate = self;
	self.msgListView.msgListTableView.dataSource = self;
	
	self.view = self.msgListView;
	
	// Register for notifications when the current account changes.
	[[AppHelper theAppDelegate].accountChangeListers addObject:self];
	
	// Register the footer view for progress updates when the mail synchronization
	// takes place.
	AppDelegate *appDelegate = [AppHelper theAppDelegate];
	assert(appDelegate.mailSyncProgressDelegates != nil);
	[appDelegate.mailSyncProgressDelegates addSubDelegate:self.msgListView.msgListActionFooter];
}

-(void)viewWillAppear:(BOOL)animated
{
	// If the filter has changed (and the view is appearing because of a return
	// from editig the filter), the changes need to be saved, and the fetched results
	// controller needs to be reconfigured.
	if([self.appDmc.managedObjectContext hasChanges])
	{
		[self.appDmc saveContextAndIgnoreErrors];
	}
	[self configureFetchedResultsController];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	self.emailInfoFrc = nil;
	
	[[AppHelper theAppDelegate].accountChangeListers removeObject:self];
	
	// De-register the footer view for progress updates when the mail synchronization
	// takes place.
	AppDelegate *appDelegate = [AppHelper theAppDelegate];
	assert(appDelegate.mailSyncProgressDelegates != nil);
	[appDelegate.mailSyncProgressDelegates removeSubDelegate:self.msgListView.msgListActionFooter];	

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    id  sectionInfo =
        [[self.emailInfoFrc sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


#pragma mark EmailActionViewDelegate

-(void)actionButtonPressed
{
	assert(0); // must be overriden
}

-(void)unselectAllButtonPressed
{
	[self unselectAllMsgs];
}

-(void)selectAllButtonPressed
{	
	[self selectAllMsgs];
}


#pragma mark NSFetchedResultsControllerDelegate 

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.msgListView.msgListTableView beginUpdates];
}
 
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
 
    UITableView *tableView = self.msgListView.msgListTableView;
 
    switch(type) {
 
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
 
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			// If the object happens to be selected, remove it from the selected list.
			[self.selectedEmailInfos removeObject:anObject];
            break;
 
        case NSFetchedResultsChangeUpdate:
            [self configureCell:(MsgTableCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
 
        case NSFetchedResultsChangeMove:
           [tableView deleteRowsAtIndexPaths:[NSArray
				arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
           [tableView insertRowsAtIndexPaths:[NSArray
				arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
           break;
    }
}
 
 
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
 
    switch(type) {
 
        case NSFetchedResultsChangeInsert:
            [self.msgListView.msgListTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
 
        case NSFetchedResultsChangeDelete:
            [self.msgListView.msgListTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
 
 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.msgListView.msgListTableView endUpdates];
}

#pragma mark Button list call-backs


-(void)deleteTrashedMsgList:(NSArray*)trashedMsgs
{
	if([trashedMsgs count] > 0)
	{
		DeleteMsgConfirmationView *deleteConfirmationView = [[[DeleteMsgConfirmationView alloc]
			initWithFrame:self.navigationController.view.frame
			andMsgsToDelete:trashedMsgs 
			andAppDataModelController:self.appDmc] autorelease];
		
		[self.navigationController.view addSubview:deleteConfirmationView];
	}

}

-(void)deleteAllTrashedMsgsButtonPressed
{
	[self deleteTrashedMsgList:[self allMsgsInMsgList]];
}

-(void)deleteSelectedTrashedMsgsButtonPressed
{
	[self deleteTrashedMsgList:[self selectedInMsgList]];
}

-(void)populateDeletePopupListActions:(NSMutableArray *)actionButtonInfo 
{
	[actionButtonInfo addObject:[[[ButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"TRASH_LIST_ACTION_DELETE_SELECTED_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(deleteSelectedTrashedMsgsButtonPressed)] autorelease]];

	[actionButtonInfo addObject:[[[ButtonListItemInfo alloc] 
		initWithTitle:LOCALIZED_STR(@"TRASH_LIST_ACTION_DELETE_ALL_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(deleteAllTrashedMsgsButtonPressed)] autorelease]];

}

#pragma mark CurrentEmailAccountChangedListener

-(void)currentAcctChanged:(EmailAccount *)currentAccount
{
	[self configureFetchedResultsController];
}

-(void)dealloc
{
	[appDmc release];
	[emailInfoFrc release];
	[msgListView release];
	[selectedEmailInfos release];
	[super dealloc];
}

@end
