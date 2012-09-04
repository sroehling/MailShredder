//
//  EmailInfoActionView.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MailSyncProgressDelegate.h"

extern const CGFloat EMAIL_ACTION_VIEW_HEIGHT;

@protocol EmailActionViewDelegate;

@interface EmailInfoActionView : UIView <MailSyncProgressDelegate>
{
	@private
		UIButton *emailActionsButton;
		UIButton *unselectAllButton;
		UIButton *selectAllButton;
		UIButton *refreshMsgsButton;
		
		UIActivityIndicatorView *refeshActivityIndicator;
		UILabel *statusLabel;
		CGFloat syncProgress;
		
		id<EmailActionViewDelegate> delegate;
}

@property(nonatomic,retain) UIButton *emailActionsButton;
@property(nonatomic,retain) UIButton *selectAllButton;
@property(nonatomic,retain) UIButton *unselectAllButton;
@property(nonatomic,retain) UIButton *refreshMsgsButton;
@property(nonatomic,retain) UIActivityIndicatorView *refeshActivityIndicator;
@property(nonatomic,retain) UILabel *statusLabel;

@property(nonatomic,assign) id<EmailActionViewDelegate> delegate;

@end

@protocol EmailActionViewDelegate <NSObject>

-(void)deleteMsgsButtonPressed;
-(void)unselectAllButtonPressed;
-(void)selectAllButtonPressed;

@end
