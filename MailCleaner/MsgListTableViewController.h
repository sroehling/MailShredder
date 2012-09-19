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

@class DataModelController;
@class MsgListView;

@interface MsgListTableViewController : UIViewController 
	<NSFetchedResultsControllerDelegate,UITableViewDelegate,
		UITableViewDataSource,EmailActionViewDelegate,
		CurrentEmailAccountChangedListener,MailDeleteProgressDelegate,
		DeleteMsgConfirmationViewDelegate> {
	@private
		DataModelController *appDmc;
		DataModelController *saveMsgFilterDmc;
		NSFetchedResultsController *emailInfoFrc;
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
-(void)configureFetchedResultsController;

- (id)initWithAppDataModelController:(DataModelController*)theAppDmc;

@end
