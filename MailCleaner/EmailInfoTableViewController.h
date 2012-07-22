//
//  EmailInfoViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgListTableViewController.h"


@class DataModelController;
@class TableHeaderWithDisclosure;
@class WEPopoverController;

#import "WEPopoverController.h"
#import "TableHeaderDisclosureButtonDelegate.h"

@interface EmailInfoTableViewController : MsgListTableViewController 
	<TableHeaderDisclosureButtonDelegate,WEPopoverControllerDelegate> {
	@private
		TableHeaderWithDisclosure *messageFilterHeader;
		WEPopoverController *actionsPopupController;
		UIBarButtonItem *actionButton;

}

@property(nonatomic,retain) TableHeaderWithDisclosure *messageFilterHeader;
@property(nonatomic,retain) WEPopoverController *actionsPopupController;
@property(nonatomic,retain) UIBarButtonItem *actionButton;

@end
