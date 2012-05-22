//
//  EmailInfoViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataModelController;
@class EmailActionView;

#import "TableHeaderDisclosureButtonDelegate.h"

@interface EmailInfoTableViewController : UITableViewController 
	<NSFetchedResultsControllerDelegate,UITableViewDelegate,
		TableHeaderDisclosureButtonDelegate>
{
	@private
		DataModelController *emailInfoDmc;
		DataModelController *filterDmc;
		NSFetchedResultsController *emailInfoFrc;
		
		EmailActionView *emailActionView;
}

@property(nonatomic,retain) DataModelController *emailInfoDmc;
@property(nonatomic,retain) NSFetchedResultsController *emailInfoFrc;
@property(nonatomic,retain) EmailActionView *emailActionView;
@property(nonatomic,retain) DataModelController *filterDmc;

@end
