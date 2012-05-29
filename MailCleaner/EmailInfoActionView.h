//
//  EmailInfoActionView.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSInteger EMAIL_ACTION_VIEW_HEIGHT;

@protocol EmailActionViewDelegate;

@interface EmailInfoActionView : UIView
{
	@private
		UIButton *emailActionsButton;
		UIButton *unselectAllButton;
		UIButton *selectAllButton;
		id<EmailActionViewDelegate> delegate;
}

@property(nonatomic,retain) UIButton *emailActionsButton;
@property(nonatomic,retain) UIButton *selectAllButton;
@property(nonatomic,retain) UIButton *unselectAllButton;

@property(nonatomic,assign) id<EmailActionViewDelegate> delegate;

- (id)initWithDelegate:(id<EmailActionViewDelegate>)theDelegate;

@end

@protocol EmailActionViewDelegate <NSObject>

-(void)actionButtonPressed;
-(void)unselectAllButtonPressed;
-(void)selectAllButtonPressed;

@end
