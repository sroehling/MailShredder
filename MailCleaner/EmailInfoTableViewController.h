//
//  EmailInfoViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataModelController;

@interface EmailInfoTableViewController : UITableViewController 
	<NSFetchedResultsControllerDelegate,UITableViewDelegate>
{
	@private
		DataModelController *emailInfoDmc;
		NSFetchedResultsController *emailInfoFrc;
}

@property(nonatomic,retain) DataModelController *emailInfoDmc;
@property(nonatomic,retain) NSFetchedResultsController *emailInfoFrc;

@end
