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
#import "MailDeleteOperation.h"
#import "MBProgressHUD.h"
#import "DeleteMsgConfirmationView.h"
#import "MsgListView.h"

@class DataModelController;

@interface MsgListTableViewController : UIViewController 
	<NSFetchedResultsControllerDelegate,UITableViewDelegate,
		UITableViewDataSource,EmailActionViewDelegate,
		CurrentEmailAccountChangedListener,MailDeleteProgressDelegate,
		DeleteMsgConfirmationViewDelegate,MsgListViewDelegate> {
	@private
		DataModelController *appDmc;
		DataModelController *saveMsgFilterDmc;
		
		NSFetchedResultsController *emailInfoFrc;
		NSUInteger totalMsgCountCurrFilter;
		NSUInteger currentMsgListPageSize;
		
		MsgListView *msgListView;
		NSMutableSet *selectedEmailInfos;
		
		NSSet *msgsConfirmedForDeletion;
}

@property(nonatomic,retain) NSFetchedResultsController *emailInfoFrc;
@property(nonatomic,retain) DataModelController *appDmc;
@property(nonatomic,retain) DataModelController *saveMsgFilterDmc;
@property(nonatomic,retain) MsgListView *msgListView;
@property(nonatomic,retain) NSMutableSet *selectedEmailInfos;
@property(nonatomic,retain) NSSet *msgsConfirmedForDeletion;

-(NSArray *)selectedInMsgList;
-(void)unselectAllMsgs;

// Reconfigure the fetched results controller, based upon the message filter
// parameters, then reload the table data.
-(void)configureFetchedResultsController:(BOOL)doResetPageSize;

- (id)initWithAppDataModelController:(DataModelController*)theAppDmc;

@end
