//
//  EmailInfoViewController.h
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgListTableViewController.h"


@class DataModelController;
@class MessageFilterTableHeader;
@class WEPopoverController;
@class DataModelController;

#import "WEPopoverController.h"
#import "SavedMessageFilterTableMenuItem.h"
#import "MessageFilterTableHeader.h"

@interface EmailInfoTableViewController : MsgListTableViewController 
	<MessageFilterTableHeaderDelegate,WEPopoverControllerDelegate,
		SavedMessageFilterTableMenuItemSelectedDelegate> {
	@private
		MessageFilterTableHeader *messageFilterHeader;
		WEPopoverController *actionsPopupController;
		WEPopoverController *loadFilterPopoverController;
		DataModelController *editFilterDmc;
		
		BOOL firstTimeLoading;
}

@property(nonatomic,retain) MessageFilterTableHeader *messageFilterHeader;
@property(nonatomic,retain) WEPopoverController *actionsPopupController;
@property(nonatomic,retain) WEPopoverController *loadFilterPopoverController;
@property(nonatomic,retain) DataModelController *editFilterDmc;

@end
