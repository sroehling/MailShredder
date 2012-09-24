//
//  MsgListView.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmailInfoActionView;

@protocol MsgListViewDelegate;

@interface MsgListView : UIView
{
	@private
		UITableView *msgListTableView;
		EmailInfoActionView *msgListActionFooter;
		UIView *headerView; // optional
		
		UIView *loadMoreMsgsTableFooter;
		UILabel *loadMoreStatusLabel;
		UIButton *loadMoreButton;
		
		id<MsgListViewDelegate> delegate;
}

@property(nonatomic,retain) EmailInfoActionView *msgListActionFooter;
@property(nonatomic,retain) UITableView *msgListTableView;
@property(nonatomic,retain) UIView *headerView;

@property(nonatomic,retain) UIView *loadMoreMsgsTableFooter;
@property(nonatomic,retain) UILabel *loadMoreStatusLabel;
@property(nonatomic,retain) UIButton *loadMoreButton;

@property(nonatomic,assign) id<MsgListViewDelegate> delegate;

-(void)updateLoadedMessageCount:(NSUInteger)msgsLoaded
	andTotalMessageCount:(NSUInteger)totalMessageCount;

@end

@protocol MsgListViewDelegate <NSObject>

-(void)msgListViewLoadMoreMessagesButtonPressed;

@end
