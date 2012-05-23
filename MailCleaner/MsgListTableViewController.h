//
//  MsgListViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataModelController;

@interface MsgListTableViewController : UITableViewController 
	<NSFetchedResultsControllerDelegate,UITableViewDelegate> {
	@private
		DataModelController *emailInfoDmc;
		DataModelController *filterDmc;
		NSFetchedResultsController *emailInfoFrc;
}

@property(nonatomic,retain) DataModelController *emailInfoDmc;
@property(nonatomic,retain) NSFetchedResultsController *emailInfoFrc;
@property(nonatomic,retain) DataModelController *filterDmc;

-(NSPredicate*)msgListPredicate;
-(NSArray *)selectedInMsgList;

@end
