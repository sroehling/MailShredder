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
#import "UIHelper.h"

const NSInteger EMAIL_ACTION_VIEW_HEIGHT = 30.0;

const CGFloat ACTION_BUTTON_FONT_SIZE = 12.0f;
const CGFloat ACTION_BUTTON_SPACE = 5.0f;

@implementation EmailInfoActionView

@synthesize emailActionsButton;
@synthesize selectAllButton;
@synthesize unselectAllButton;

@synthesize delegate;

-(id)init
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, EMAIL_ACTION_VIEW_HEIGHT)];

    if (self) {

		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
        self.emailActionsButton = [UIHelper imageButton:@"msgActionButton.png" 
			withTitle:LOCALIZED_STR(@"MSGS_ACTION_BUTTON_TITLE")
			andFontSize:ACTION_BUTTON_FONT_SIZE andFontColor:[UIColor whiteColor]
			andTarget:self andAction:@selector(actionButtonPressed)];
		[self addSubview:self.emailActionsButton];
	
		self.selectAllButton = [UIHelper imageButton:@"msgActionButton.png" 
			withTitle:LOCALIZED_STR(@"MSGS_ACTION_SELECT_ALL") 
			andFontSize:ACTION_BUTTON_FONT_SIZE andFontColor:[UIColor whiteColor]
			andTarget:self andAction:@selector(selectAll)];
		[self addSubview:self.selectAllButton];

		self.unselectAllButton = [UIHelper imageButton:@"msgActionButton.png" 
			withTitle:LOCALIZED_STR(@"MSGS_ACTION_UNSELECT_ALL") 
			andFontSize:ACTION_BUTTON_FONT_SIZE andFontColor:[UIColor whiteColor]
			andTarget:self andAction:@selector(unselectAll)];
		[self addSubview:self.unselectAllButton];
		

		
    }
    return self;
}

-(void)selectAll
{
	assert(self.delegate != nil); // delegate must be initialized
	[self.delegate selectAllButtonPressed];
}

-(void)unselectAll
{
	assert(self.delegate != nil);
	[self.delegate unselectAllButtonPressed];
}

-(void)actionButtonPressed
{
	assert(self.delegate != nil);
	[self.delegate actionButtonPressed];
}

- (id)initWithFrame:(CGRect)frame
{
	assert(0);
	return 0;
}



-(void)layoutSubviews
{
		[super layoutSubviews];
		
		CGFloat buttonsWidth = self.selectAllButton.frame.size.width +
			self.unselectAllButton.frame.size.width + 
			self.emailActionsButton.frame.size.width + 2 * ACTION_BUTTON_SPACE;
		CGFloat currXOffset = self.frame.size.width/2.0 - buttonsWidth/2.0;
		
		CGRect buttonFrame = self.emailActionsButton.frame;
		buttonFrame.origin.x = currXOffset;
		buttonFrame.origin.y = self.frame.size.height/2.0 - buttonFrame.size.height/2.0;
		[self.emailActionsButton setFrame:buttonFrame];
		
		currXOffset += buttonFrame.size.width + ACTION_BUTTON_SPACE;
		
		buttonFrame = self.unselectAllButton.frame;
		buttonFrame.origin.x = currXOffset;
		buttonFrame.origin.y = self.frame.size.height/2.0 - buttonFrame.size.height/2.0;
		[self.unselectAllButton setFrame:buttonFrame];
		
		currXOffset += buttonFrame.size.width + ACTION_BUTTON_SPACE;
		
		buttonFrame = self.selectAllButton.frame;
		buttonFrame.origin.x = currXOffset;
		buttonFrame.origin.y = self.frame.size.height/2.0 - buttonFrame.size.height/2.0;
		[self.selectAllButton setFrame:buttonFrame];
		
}


-(void)dealloc
{
	[emailActionsButton release];
	[super dealloc];
}


@end
