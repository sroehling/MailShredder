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


@implementation MsgListTableViewController

@synthesize emailInfoDmc;
@synthesize emailInfoFrc;
@synthesize filterDmc;


- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		self.emailInfoDmc = [AppHelper emailInfoDataModelController];
		self.filterDmc = [AppHelper appDataModelController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	assert(0);
	return nil;
}


-(UITableViewCellAccessoryType)accessoryTypeForEmailInfo:(EmailInfo*)theEmailInfo
{
	if(self.editing)
	{
		if([theEmailInfo.selectedInMsgList boolValue])
		{
			return UITableViewCellAccessoryCheckmark;
		}
		else 
		{
			return UITableViewCellAccessoryNone;
		}
	}
	else 
	{
		return UITableViewCellAccessoryDisclosureIndicator;
	}

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


- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EmailInfo *info = [self.emailInfoFrc objectAtIndexPath:indexPath];
	NSString *lockedFlag = [info.locked boolValue]?@"L":@"U";
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@",
		lockedFlag,info.from];
    cell.detailTextLabel.text = [DateHelper stringFromDate:info.sendDate];
	cell.editingAccessoryType = [info.selectedInMsgList boolValue]?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
	cell.accessoryType =UITableViewCellAccessoryDisclosureIndicator;
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
	
	[self.tableView reloadData];

}

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView 
	accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	EmailInfo *info = [self.emailInfoFrc objectAtIndexPath:indexPath];
	return [self accessoryTypeForEmailInfo:info];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView 
	editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cellForRow = [self.tableView cellForRowAtIndexPath:indexPath];
	assert(cellForRow!=nil);
    if(self.editing)
    {
        // Calling super's didSelectRowAtIndexPath will fetch the field edit 
        // info object for the given path and push the associated controller
        // We only do this in edit mode, so that while not in edit mode we can
        // just move the selection.
 		EmailInfo *info = [self.emailInfoFrc objectAtIndexPath:indexPath];
		if([info.selectedInMsgList boolValue])
		{
			info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
			cellForRow.editingAccessoryType =  UITableViewCellAccessoryNone;
		}
		else 
		{
			info.selectedInMsgList = [NSNumber numberWithBool:TRUE];
			cellForRow.editingAccessoryType =  UITableViewCellAccessoryCheckmark;
		}
		[self.emailInfoDmc saveContext];

    }
    else
    {
		// TODO - Open up detail view for message.
    }
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView
    cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    static NSString *CellIdentifier = @"Cell";
 
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] 
			initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease]; 
	}
 
    // Set up the cell...
    [self configureCell:cell atIndexPath:indexPath];
 
    return cell;
}


- (void)viewDidLoad {
    [super viewDidLoad];
 
	[self configureFetchedResultsController];
 
    self.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.tableView.allowsSelectionDuringEditing = TRUE;
	self.tableView.allowsSelection = TRUE;
	self.tableView.allowsMultipleSelection = FALSE;
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



#pragma mark NSFetchedResultsControllerDelegate 

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}
 
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
 
    UITableView *tableView = self.tableView;
 
    switch(type) {
 
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
 
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
 
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
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
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
 
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}
 
 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}



-(void)dealloc
{
	[emailInfoDmc release];
	[filterDmc release];
	[emailInfoFrc release];
	[super dealloc];
}

@end
