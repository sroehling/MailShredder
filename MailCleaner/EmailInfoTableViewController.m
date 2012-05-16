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

@interface EmailInfoTableViewController ()

@end

@implementation EmailInfoTableViewController

@synthesize emailInfoDmc;
@synthesize emailInfoFrc;

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		self.emailInfoDmc = [AppHelper emailInfoDataModelController];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	assert(0);
	return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
 
 
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_INFO_ENTITY_NAME 
		inManagedObjectContext:self.emailInfoDmc.managedObjectContext];
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
		initWithKey:EMAIL_INFO_SEND_DATE_KEY ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	[fetchRequest setFetchBatchSize:20];
 
	self.emailInfoFrc = [[[NSFetchedResultsController alloc] 
			initWithFetchRequest:fetchRequest
			managedObjectContext:self.emailInfoDmc.managedObjectContext sectionNameKeyPath:nil
			cacheName:@"Root"] autorelease];

 
    NSError *error;
	if (![self.emailInfoFrc performFetch:&error]) {
		// Update to handle the error appropriately.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
 
    self.title = @"Email Info";
 
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EmailInfo *info = [self.emailInfoFrc objectAtIndexPath:indexPath];
    cell.textLabel.text = info.from;
    cell.detailTextLabel.text = [DateHelper stringFromDate:info.sendDate];
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
	[emailInfoFrc release];
	[super dealloc];
}

@end
