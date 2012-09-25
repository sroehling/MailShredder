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
#import "ButtonListItemInfo.h"
#import "AppDelegate.h"
#import "EmailAddress.h"
#import "AppHelper.h"
#import "CompositeMailSyncProgressDelegate.h"
#import "DeleteMsgConfirmationView.h"
#import "MsgDetailViewController.h"
#import "SharedAppVals.h"
#import "EmailAccount.h"
#import "MsgPredicateHelper.h"
#import "MailDeleteOperation.h"
#import "CompositeMailDeleteProgressDelegate.h"
#import "MailDeleteCompletionInfo.h"
#import "MBProgressHUD.h"


static NSUInteger const MSG_LIST_STARTING_PAGE_SIZE = 5;
static CGFloat const MSG_LIST_COMPLETE_STATUS_HUD_DISPLAY_TIME = 3.0f;

@implementation MsgListTableViewController

@synthesize emailInfoFrc;
@synthesize appDmc;
@synthesize saveMsgFilterDmc;
@synthesize msgListView;
@synthesize selectedEmailInfos;

@synthesize msgsConfirmedForDeletion;


-(void)newMessageFilterDidSaveNoficiationHandler:(NSNotification*)notification
{
	[self.appDmc.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	[[AppHelper theAppDelegate] updateMessageFilterCountsInBackground];
}

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


-(void)selectEmailInfo:(EmailInfo*)emailInfo
{
	assert(emailInfo != nil);
	[self.selectedEmailInfos addObject:emailInfo];
	[self.msgListView.msgListActionFooter updateMsgCount:self.selectedEmailInfos.count];
}

-(void)deselectEmailInfo:(EmailInfo*)emailInfo
{
	assert(emailInfo != nil);
	[self.selectedEmailInfos removeObject:emailInfo];
	[self.msgListView.msgListActionFooter updateMsgCount:self.selectedEmailInfos.count];
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
	
	[cell configureForMsgFlagged:[info.isStarred boolValue]];
	[cell configureForMsgRead:[info.isRead boolValue]];
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

-(EmailAccount*)currentEmailAcct
{
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	assert(sharedAppVals.currentEmailAcct != nil);
	return sharedAppVals.currentEmailAcct;
}


-(void)configureFetchedResultsController:(BOOL)doResetPageSize
{

	EmailAccount *currentAcct = [self currentEmailAcct];

	NSFetchRequest *currentFilterFetchRequest = [MsgPredicateHelper
		emailInfoFetchRequestForDataModelController:self.appDmc andFilter:currentAcct.msgListFilter];
		
	NSError* countError = nil;
	totalMsgCountCurrFilter = [self.appDmc.managedObjectContext countForFetchRequest:currentFilterFetchRequest error:&countError];
	NSLog(@"Total Count of messages matching filter: %d",totalMsgCountCurrFilter);
		
	if(doResetPageSize)
	{
		currentMsgListPageSize = MSG_LIST_STARTING_PAGE_SIZE;
	}
	// Limit the number of results which are returned to a "page full" of results.
	[currentFilterFetchRequest setFetchLimit:currentMsgListPageSize];
	
	NSUInteger loadedMsgCount = [self.appDmc.managedObjectContext countForFetchRequest:currentFilterFetchRequest error:&countError];
	[self.msgListView updateLoadedMessageCount:loadedMsgCount andTotalMessageCount:totalMsgCountCurrFilter];
		
	if([AppHelper generatingLaunchScreen])
	{
		NSFetchRequest *emptyRequest = [MsgPredicateHelper emptyFetchRequestForLaunchScreenGeneration:self.appDmc];
		currentFilterFetchRequest = emptyRequest;
	}
 
	self.emailInfoFrc = [[[NSFetchedResultsController alloc] 
			initWithFetchRequest:currentFilterFetchRequest
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
 
	[self configureFetchedResultsController:TRUE];
 
	NSString *viewTitle = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	if([AppHelper generatingLaunchScreen])
	{
		viewTitle = @" ";
	}
    self.title = viewTitle;
	
	self.msgListView = [[[MsgListView alloc] initWithFrame:CGRectZero] autorelease];
	self.msgListView.msgListActionFooter.delegate = self;
	self.msgListView.msgListTableView.delegate = self;
	self.msgListView.msgListTableView.dataSource = self;
	self.msgListView.delegate = self;
	
	self.view = self.msgListView;

	// Listen to change noficiations from new message filters.
	self.saveMsgFilterDmc = [[[DataModelController alloc] 
	initWithPersistentStoreCoord:self.appDmc.persistentStoreCoordinator] autorelease];
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(newMessageFilterDidSaveNoficiationHandler:)
		name:NSManagedObjectContextDidSaveNotification 
		object:self.saveMsgFilterDmc.managedObjectContext];	

	
	// Register for notifications when the current account changes.
	[[AppHelper theAppDelegate].accountChangeListers addObject:self];
	
	// Register the footer view for progress updates when the mail synchronization
	// takes place.
	AppDelegate *appDelegate = [AppHelper theAppDelegate];
	assert(appDelegate.mailSyncProgressDelegates != nil);
	[appDelegate.mailSyncProgressDelegates addSubDelegate:self.msgListView.msgListActionFooter];
	[appDelegate.mailSyncProgressDelegates addSubDelegate:self];
	[appDelegate.mailDeleteProgressDelegates addSubDelegate:self.msgListView.msgListActionFooter];
	[appDelegate.mailDeleteProgressDelegates addSubDelegate:self];
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
	[self configureFetchedResultsController:TRUE];
}

-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload 
{
	[super viewDidUnload];
	self.emailInfoFrc = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
		name:NSManagedObjectContextDidSaveNotification 
		object:self.saveMsgFilterDmc.managedObjectContext];


	[[AppHelper theAppDelegate].accountChangeListers removeObject:self];
	
	// De-register the footer view for progress updates when the mail synchronization
	// takes place.
	AppDelegate *appDelegate = [AppHelper theAppDelegate];
	assert(appDelegate.mailSyncProgressDelegates != nil);
	[appDelegate.mailSyncProgressDelegates removeSubDelegate:self.msgListView.msgListActionFooter];
	[appDelegate.mailSyncProgressDelegates removeSubDelegate:self];
	[appDelegate.mailDeleteProgressDelegates removeSubDelegate:self.msgListView.msgListActionFooter];
	[appDelegate.mailDeleteProgressDelegates removeSubDelegate:self];
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

#pragma mark MailDeleteProgressDelegate

-(void)showDeletionCompleteStatusHUD:(NSString*)completionStatus
{
	MBProgressHUD *hud = [[[MBProgressHUD alloc] initWithView:self.navigationController.view] autorelease];
	[self.navigationController.view addSubview:hud];

	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeCustomView;
	hud.labelText = LOCALIZED_STR(@"MESSAGE_DELETION_COMPLETION_STATUS_TITLE");
	hud.detailsLabelText =completionStatus;
	hud.margin = 5.f;
	hud.minSize = CGSizeMake(135.f, 135.f);
	hud.dimBackground = YES;
	hud.removeFromSuperViewOnHide = TRUE;
	hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"deletemsgsdone.png"]] autorelease];

	[hud show:TRUE];
	[hud hide:YES afterDelay:MSG_LIST_COMPLETE_STATUS_HUD_DISPLAY_TIME];

}

-(void)mailDeleteComplete:(BOOL)completeStatus withCompletionInfo:(MailDeleteCompletionInfo *)mailDeleteCompletionInfo
{
	if(completeStatus == TRUE)
	{
		assert(mailDeleteCompletionInfo != nil);
		NSLog(@"MsgListTableViewController: mailDeleteComplete: %@",[mailDeleteCompletionInfo completionSummary]);

		[self performSelectorOnMainThread:@selector(showDeletionCompleteStatusHUD:) 
			withObject:[mailDeleteCompletionInfo completionSummary] waitUntilDone:TRUE];
		
	}
}

-(void)reconfigFetchedResultsAfterSync
{
	[self configureFetchedResultsController:FALSE];
}

-(void)mailSyncComplete:(BOOL)successfulCompletion
{
	[self performSelectorOnMainThread:@selector(reconfigFetchedResultsAfterSync) withObject:nil waitUntilDone:TRUE];
}

#pragma mark EmailActionViewDelegate

-(void)deleteMsgsButtonPressed
{
	[self deleteSelectedMsgsWithConfirmation];
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
			[self deselectEmailInfo:anObject];
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



-(void)deleteSelectedMsgsWithConfirmation
{
	NSArray *trashedMsgs = [self selectedInMsgList];

	if([trashedMsgs count] > 0)
	{
		DeleteMsgConfirmationView *deleteConfirmationView = [[[DeleteMsgConfirmationView alloc]
			initWithFrame:self.navigationController.view.frame
			andMsgsToDelete:trashedMsgs 
			andAppDataModelController:self.appDmc
			andDelegate:self] autorelease];
		
		[self.navigationController.view addSubview:deleteConfirmationView];
	}

}

-(void)msgsConfirmedForDeletion:(NSSet *)confirmedMsgs
{
	self.msgsConfirmedForDeletion = confirmedMsgs;
	if(confirmedMsgs.count > 0)
	{
		NSString *preDeletionSummary = [self.currentEmailAcct msgDeletionPreDeletionSummary:confirmedMsgs.count];
	
		NSString *msgCountDescription = (confirmedMsgs.count == 1)?
			LOCALIZED_STR(@"MESSAGE_DELETE_SINGULAR_MESSAGE_LABEL"):
			LOCALIZED_STR(@"MESSAGE_DELETE_PLURAL_MESSAGE_LABEL");
	
		NSString *finalConfirmationMsg = [NSString 
			stringWithFormat:LOCALIZED_STR(@"MESSAGE_DELETE_FINAL_CONFIRMATION_FORMAT"),
				confirmedMsgs.count,msgCountDescription,preDeletionSummary];

		UIAlertView *finalConfirmationAlert = [[[UIAlertView alloc] 
			initWithTitle:LOCALIZED_STR(@"MESSAGE_DELETE_FINAL_CONFIRMATION_TITLE")
			message:finalConfirmationMsg delegate:self 
			cancelButtonTitle:LOCALIZED_STR(@"MESSAGE_DELETE_FINAL_CONFIRMATION_CANCEL_BUTTON_TITLE")
			otherButtonTitles:nil] autorelease];
		[finalConfirmationAlert addButtonWithTitle:LOCALIZED_STR(@"MESSAGE_DELETE_FINAL_CONFIRMATION_DELETE_BUTTON_TITLE")];
		[finalConfirmationAlert show];
	}
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"Alert view dismissed: buton index = %d",buttonIndex);
	if(alertView.cancelButtonIndex != buttonIndex)
	{
		assert(self.msgsConfirmedForDeletion != nil); // Must be set in msgsConfirmedForDeletionMethod
		for (EmailInfo *info in self.msgsConfirmedForDeletion)
		{
			info.deleted = [NSNumber numberWithBool:TRUE];		
		}
		[self.appDmc saveContext];
		
		AppDelegate *appDelegate = [AppHelper theAppDelegate];
		[appDelegate deleteMarkedMsgsInBackgroundThread];

		// Once the synchronization is complete, reconfigure
		// the FRC. This ensures the number of messages shown
		// stays within the current page size.
		[self configureFetchedResultsController:FALSE];
	}
}

-(void)msgListViewLoadMoreMessagesButtonPressed
{
	currentMsgListPageSize += MSG_LIST_STARTING_PAGE_SIZE;
	[self configureFetchedResultsController:FALSE];
}

#pragma mark CurrentEmailAccountChangedListener

-(void)currentAcctChanged:(EmailAccount *)currentAccount
{
	[self configureFetchedResultsController:TRUE];
}

-(void)dealloc
{
	[appDmc release];
	[emailInfoFrc release];
	[msgListView release];
	[selectedEmailInfos release];
	[saveMsgFilterDmc release];
	[msgsConfirmedForDeletion release];
	[super dealloc];
}

@end
