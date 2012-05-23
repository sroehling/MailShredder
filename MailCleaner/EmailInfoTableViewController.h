//
//  EmailInfoViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailInfoActionView.h"
#import "MsgListTableViewController.h"


@class DataModelController;

#import "TableHeaderDisclosureButtonDelegate.h"
#import "MessageListActionView.h"

@interface EmailInfoTableViewController : MsgListTableViewController 
	<TableHeaderDisclosureButtonDelegate,EmailActionViewDelegate,
	MessageListActionViewDelegate> {
		
	@private
		EmailInfoActionView *emailActionView;
}

@property(nonatomic,retain) EmailInfoActionView *emailActionView;

@end
