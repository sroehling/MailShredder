//
//  EmailInfoActionView.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailInfoActionView.h"
#import "LocalizationHelper.h"
#import "TableCellHelper.h"

const NSInteger EMAIL_ACTION_VIEW_HEIGHT = 30.0;

@implementation EmailInfoActionView

@synthesize emailActionsButton;
@synthesize delegate;

- (id)initWithDelegate:(id<EmailActionViewDelegate>)theDelegate
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, EMAIL_ACTION_VIEW_HEIGHT)];

    if (self) {

		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		assert(theDelegate != nil);
		self.delegate = theDelegate;

        self.emailActionsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[self.emailActionsButton setTitle:
			LOCALIZED_STR(@"MSGS_ACTION_BUTTON_TITLE") forState:UIControlStateNormal];
		[self.emailActionsButton sizeToFit];
		
		[self.emailActionsButton addTarget:self.delegate 
				action:@selector(actionButtonPressed) forControlEvents:UIControlEventTouchUpInside];

		
		[self addSubview:self.emailActionsButton];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	assert(0);
	return 0;
}

-(id)init
{
	assert(0);
	return 0;
}

-(void)layoutSubviews
{
		[super layoutSubviews];
		
		[TableCellHelper horizCenterAlignChild:self.emailActionsButton withinParentFrame:self.frame];
		
		
}


-(void)dealloc
{
	[emailActionsButton release];
	[super dealloc];
}


@end
