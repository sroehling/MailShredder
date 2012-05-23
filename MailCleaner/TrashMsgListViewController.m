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

@interface TrashMsgListViewController ()

@end

@implementation TrashMsgListViewController

-(NSPredicate*)msgListPredicate
{
	NSPredicate *trashPredicate = [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_TRASHED_KEY,[NSNumber numberWithBool:YES]];
	return trashPredicate;
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


@end
