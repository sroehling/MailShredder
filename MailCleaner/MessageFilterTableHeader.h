//
//  MessageFilterTableHeader.h
//
//  Created by Steve Roehling on 8/31/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageFilterTableHeaderDelegate;

@interface MessageFilterTableHeader : UIView 
{
    @private
		UILabel *header;
		UILabel *subTitle;
		UIButton *editFilterButton;
		UIButton *loadFilterButton;
		id<MessageFilterTableHeaderDelegate> delegate;
}

@property(nonatomic,retain) UILabel *header;
@property(nonatomic,retain) UILabel *subTitle;
@property(nonatomic,retain) UIButton *editFilterButton;
@property(nonatomic,retain) UIButton *loadFilterButton;
@property(nonatomic,assign) id<MessageFilterTableHeaderDelegate> delegate;

- (id)initWithDelegate:(id<MessageFilterTableHeaderDelegate>)theDelegate;
- (void)resizeForChildren;

@end

@protocol MessageFilterTableHeaderDelegate <NSObject>

- (void)messageFilterHeaderEditFilterButtonPressed;
- (void)messageFilterHeaderLoadFilterButtonPressed;

@end
