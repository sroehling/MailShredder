//
//  MsgListView.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmailInfoActionView;

@interface MsgListView : UIView
{
	@private
		UITableView *msgListTableView;
		EmailInfoActionView *msgListActionFooter;
		UIView *headerView; // optional
}

@property(nonatomic,retain) EmailInfoActionView *msgListActionFooter;
@property(nonatomic,retain) UITableView *msgListTableView;
@property(nonatomic,retain) UIView *headerView;

@end
