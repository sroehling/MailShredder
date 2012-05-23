//
//  TrashMsgListViewController.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrashMsgListViewController.h"
#import "LocalizationHelper.h"
#import "EmailInfo.h"
#import "PopupButtonListItemInfo.h"
#import "PopupButtonListView.h"
#import "DataModelController.h"


@implementation TrashMsgListViewController

-(NSPredicate*)msgListPredicate
{
	NSPredicate *trashedPredicate = [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_TRASHED_KEY,[NSNumber numberWithBool:YES]];
	NSPredicate *notLocked = [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_LOCKED_KEY,[NSNumber numberWithBool:NO]];
	
	NSPredicate *trashListPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:
		[NSArray arrayWithObjects:trashedPredicate,notLocked, nil]];
		
	return trashListPredicate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = LOCALIZED_STR(@"TRASH_VIEW_TITLE");

	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark Button list call-backs

-(void)lockMsgsButtonPressed
{
	NSLog(@"Lock msgs button pressed");
	NSArray *selectedMsgs = [self selectedInMsgList];
	for (EmailInfo *info in selectedMsgs)
	{
		info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
		info.locked = [NSNumber numberWithBool:TRUE];
		info.trashed= [NSNumber numberWithBool:FALSE];
	}
	[self.emailInfoDmc saveContext];
	[self.tableView reloadData];
}

-(void)untrashMsgsButtonPressed
{
	NSLog(@"Un-trash msgs button pressed");
	NSArray *selectedMsgs = [self selectedInMsgList];
	
	for (EmailInfo *info in selectedMsgs)
	{
		info.selectedInMsgList = [NSNumber numberWithBool:FALSE];
		info.trashed = [NSNumber numberWithBool:FALSE];
	}
	[self.emailInfoDmc saveContext];
	[self.tableView reloadData];
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
		initWithTitle:LOCALIZED_STR(@"TRASH_LIST_ACTION_UNTRASH_BUTTON_TITLE")
		 andTarget:self andSelector:@selector(untrashMsgsButtonPressed)] autorelease]];
	
	PopupButtonListView *popupActionList = [[[PopupButtonListView alloc]
		initWithFrame:self.navigationController.view.frame 
		andButtonListItemInfo:actionButtonInfo] autorelease];
	
	[self.navigationController.view addSubview:popupActionList];
}





@end
