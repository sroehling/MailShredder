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


@implementation MsgListTableViewController

@synthesize emailInfoDmc;
@synthesize emailInfoFrc;
@synthesize filterDmc;
@synthesize msgListView;


- (id)initWithEmailInfoDataModelController:(DataModelController*)theEmailInfoDmc
	andAppDataModelController:(DataModelController*)theAppDmc
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		self.emailInfoDmc = theEmailInfoDmc;
		self.filterDmc = theAppDmc;
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

-(NSArray *)selectedInMsgList
{
	NSPredicate *selectedPredicate = [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_SELECTED_IN_MSG_LIST_KEY,[NSNumber numberWithBool:YES]];
	NSPredicate *selectedInMsgListPredicate =  [NSCompoundPredicate andPredicateWithSubpredicates:
		[NSArray arrayWithObjects:[self msgListPredicate],selectedPredicate, nil]];

	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_INFO_ENTITY_NAME 
		inManagedObjectContext:self.emailInfoDmc.managedObjectContext];
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
		initWithKey:EMAIL_INFO_SEND_DATE_KEY ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[fetchRequest setPredicate:selectedInMsgListPredicate];	

	return [CoreDataHelper executeFetchOrThrow:fetchRequest 
		inManagedObectContext:self.emailInfoDmc.managedObjectContext];

}


- (void)configureCell:(MsgTableCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EmailInfo *info = [self.emailInfoFrc objectAtIndexPath:indexPath];
	NSString *lockedFlag = [info.locked boolValue]?@"L":@"U";
    cell.fromLabel.text = [NSString stringWithFormat:@"%@:%@",
		lockedFlag,info.from];
    cell.sendDateLabel.text = [DateHelper stringFromDate:info.sendDate];
	if([info.selectedInMsgList boolValue])
	{
		[self.msgListView.msgListTableView selectRowAtIndexPath:indexPath animated:FALSE scrollPosition:UITableViewScrollPositionNone];
	}
	cell.accessoryType =UITableViewCellAccessoryDetailDisclosureButton;
}

-(void)configureFetchedResultsController
{
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_INFO_ENTITY_NAME 
		inManagedObjectContext:self.emailInfoDmc.managedObjectContext];
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
		initWithKey:EMAIL_INFO_SEND_DATE_KEY ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[fetchRequest setPredicate:[self msgListPredicate]];	
	[fetchRequest setFetchBatchSize:20];
 
	self.emailInfoFrc = [[[NSFetchedResultsController alloc] 
			initWithFetchRequest:fetchRequest
			managedObjectContext:self.emailInfoDmc.managedObjectContext sectionNameKeyPath:nil
			cacheName:nil] autorelease];
	self.emailInfoFrc.delegate = self;

 
    NSError *error;
	if (![self.emailInfoFrc performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
	
	[self.msgListView.msgListTableView reloadData];

}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
	EmailInfo *info = [self.emailInfoFrc objectAtIndexPath:indexPath];
	info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
	[self.emailInfoDmc saveContext];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	EmailInfo *info = [self.emailInfoFrc objectAtIndexPath:indexPath];
	info.selectedInMsgList = [NSNumber numberWithBool:TRUE];
	[self.emailInfoDmc saveContext];
	
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
	NSLog(@"Detail button pressed");
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
	
}

-(void)viewWillAppear:(BOOL)animated
{
	// If the filter has changed (and the view is appearing because of a return
	// from editig the filter), the changes need to be saved, and the fetched results
	// controller needs to be reconfigured.
	if([self.filterDmc.managedObjectContext hasChanges])
	{
		[self.filterDmc saveContextAndIgnoreErrors];
	}
	[self configureFetchedResultsController];
}


- (void)viewDidUnload 
{
	[super viewDidUnload];
	self.emailInfoFrc = nil;
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
	NSLog(@"Unselect all");
}

-(void)selectAllButtonPressed
{
	NSLog(@"Select all");
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



-(void)dealloc
{
	[emailInfoDmc release];
	[filterDmc release];
	[emailInfoFrc release];
	[msgListView release];
	[super dealloc];
}

@end
