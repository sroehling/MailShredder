//
//  MessageListActionView.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageListActionViewDelegate;

@interface MessageListActionView : UIView {
	@private
		UIButton *trashMsgsButton;
		UIButton *lockMsgsButton;
		UIButton *cancelButton;
}

@property(nonatomic,retain) UIButton *trashMsgsButton;
@property(nonatomic,retain) UIButton *lockMsgsButton;
@property(nonatomic,retain) UIButton *cancelButton;
@property(nonatomic,assign) id<MessageListActionViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame andDelegate:(id<MessageListActionViewDelegate>)theDelegate;

@end


@protocol MessageListActionViewDelegate <NSObject>

-(void)trashMsgsButtonPressed;
-(void)lockMsgsButtonPressed;

@end

