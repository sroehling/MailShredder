//
//  EmailInfoViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailInfoActionView.h"


@class DataModelController;

#import "TableHeaderDisclosureButtonDelegate.h"
#import "MessageListActionView.h"

@interface EmailInfoTableViewController : UITableViewController 
	<NSFetchedResultsControllerDelegate,UITableViewDelegate,
		TableHeaderDisclosureButtonDelegate,EmailActionViewDelegate,MessageListActionViewDelegate>
{
	@private
		DataModelController *emailInfoDmc;
		DataModelController *filterDmc;
		NSFetchedResultsController *emailInfoFrc;
		
		EmailInfoActionView *emailActionView;
}

@property(nonatomic,retain) DataModelController *emailInfoDmc;
@property(nonatomic,retain) NSFetchedResultsController *emailInfoFrc;
@property(nonatomic,retain) EmailInfoActionView *emailActionView;
@property(nonatomic,retain) DataModelController *filterDmc;

@end
