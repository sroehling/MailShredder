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
		id<EmailActionViewDelegate> delegate;
}

@property(nonatomic,retain) UIButton *emailActionsButton;
@property(nonatomic,assign) id<EmailActionViewDelegate> delegate;

- (id)initWithDelegate:(id<EmailActionViewDelegate>)theDelegate;

@end

@protocol EmailActionViewDelegate <NSObject>

-(void)actionButtonPressed;

@end
