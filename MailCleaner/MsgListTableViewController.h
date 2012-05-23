//
//  MsgListViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EmailInfoActionView.h"

@class DataModelController;

@interface MsgListTableViewController : UITableViewController 
	<NSFetchedResultsControllerDelegate,UITableViewDelegate,EmailActionViewDelegate> {
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

- (id)initWithEmailInfoDataModelController:(DataModelController*)theEmailInfoDmc
	andAppDataModelController:(DataModelController*)theAppDmc;

@end
