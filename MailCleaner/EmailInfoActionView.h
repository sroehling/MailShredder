//
//  EmailInfoActionView.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const NSInteger EMAIL_ACTION_VIEW_HEIGHT;

@interface EmailInfoActionView : UIView
{
	@private
		UIButton *emailActionsButton;
}

@property(nonatomic,retain) UIButton *emailActionsButton;

@end
