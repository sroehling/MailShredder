//
//  MsgListViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EmailInfoActionView.h"
#import "AppDelegate.h"

@class DataModelController;
@class MsgListView;

@interface MsgListTableViewController : UIViewController 
	<NSFetchedResultsControllerDelegate,UITableViewDelegate,
		UITableViewDataSource,EmailActionViewDelegate,CurrentEmailAccountChangedListener> {
	@private
		DataModelController *appDmc;
		DataModelController *saveMsgFilterDmc;
		NSFetchedResultsController *emailInfoFrc;
		MsgListView *msgListView;
		NSMutableSet *selectedEmailInfos;
}

@property(nonatomic,retain) NSFetchedResultsController *emailInfoFrc;
@property(nonatomic,retain) DataModelController *appDmc;
@property(nonatomic,retain) DataModelController *saveMsgFilterDmc;
@property(nonatomic,retain) MsgListView *msgListView;
@property(nonatomic,retain) NSMutableSet *selectedEmailInfos;

-(NSPredicate*)msgListPredicate;
-(NSArray *)selectedInMsgList;
-(void)unselectAllMsgs;
-(NSArray*)allMsgsInMsgList;

// Reconfigure the fetched results controller, based upon the message filter
// parameters, then reload the table data.
-(void)configureFetchedResultsController;

// Reusable methods for deleting selected or all messages when
// initiated in a popup list of actions.
-(void)deleteTrashedMsgList:(NSArray*)trashedMsgs;
-(void)deleteAllTrashedMsgsButtonPressed;
-(void)deleteSelectedTrashedMsgsButtonPressed;
-(void)populateDeletePopupListActions:(NSMutableArray *)actionButtonInfo;

- (id)initWithAppDataModelController:(DataModelController*)theAppDmc;

@end
