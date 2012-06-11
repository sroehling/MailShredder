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
@class MsgListView;

@interface MsgListTableViewController : UIViewController 
	<NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,EmailActionViewDelegate> {
	@private
		DataModelController *emailInfoDmc;
		DataModelController *filterDmc;
		NSFetchedResultsController *emailInfoFrc;
		MsgListView *msgListView;
}

@property(nonatomic,retain) DataModelController *emailInfoDmc;
@property(nonatomic,retain) NSFetchedResultsController *emailInfoFrc;
@property(nonatomic,retain) DataModelController *filterDmc;
@property(nonatomic,retain) MsgListView *msgListView;

-(NSPredicate*)msgListPredicate;
-(NSArray *)selectedInMsgList;
-(NSArray*)allMsgsInMsgList;

- (id)initWithEmailInfoDataModelController:(DataModelController*)theEmailInfoDmc
	andAppDataModelController:(DataModelController*)theAppDmc;

@end
