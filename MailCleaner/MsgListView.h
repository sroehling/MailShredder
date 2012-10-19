//
//  MsgListView.h
//
//  Created by Steve Roehling on 5/29/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
		
		UIButton *resetFilterButton;
		
		id<MsgListViewDelegate> delegate;
}

@property(nonatomic,retain) EmailInfoActionView *msgListActionFooter;
@property(nonatomic,retain) UITableView *msgListTableView;
@property(nonatomic,retain) UIView *headerView;

@property(nonatomic,retain) UIView *loadMoreMsgsTableFooter;
@property(nonatomic,retain) UILabel *loadMoreStatusLabel;
@property(nonatomic,retain) UIButton *loadMoreButton;
@property(nonatomic,retain) UIButton *resetFilterButton;

@property(nonatomic,assign) id<MsgListViewDelegate> delegate;

-(void)updateLoadedMessageCount:(NSUInteger)msgsLoaded
	andTotalMessageCount:(NSUInteger)totalMessageCount;

@end

@protocol MsgListViewDelegate <NSObject>

-(void)msgListViewLoadMoreMessagesButtonPressed;
-(void)msgListViewResetFilterButtonPressed;
-(BOOL)msgListViewUnfilteredMessageListActive;

@end
