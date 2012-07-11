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

#import "TableHeaderDisclosureButtonDelegate.h"

@interface EmailInfoTableViewController : MsgListTableViewController 
	<TableHeaderDisclosureButtonDelegate> {
	@private
		TableHeaderWithDisclosure *messageFilterHeader;
}

@property(nonatomic,retain) TableHeaderWithDisclosure *messageFilterHeader;

@end
