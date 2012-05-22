//
//  MessageListActionView.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageListActionView.h"
#import "LocalizationHelper.h"

@implementation MessageListActionView

@synthesize lockMsgsButton;
@synthesize trashMsgsButton;
@synthesize cancelButton;
@synthesize delegate;

const CGFloat MESSAGE_LIST_BUTTON_HEIGHT = 30.0f;
const CGFloat MESSAGE_LIST_BUTTON_WIDTH = 280.0f;
const CGFloat MESSAGE_LIST_VERT_SPACE = 15.0f;


-(void)trashButtonPressed
{
	[self.delegate trashMsgsButtonPressed];
	[self removeFromSuperview];
}

-(void)lockMsgsButtonPressed
{
	[self.delegate lockMsgsButtonPressed];
	[self removeFromSuperview];
}

-(void)cancelButtonPressed
{
	[self removeFromSuperview];
}

- (id)initWithFrame:(CGRect)frame andDelegate:(id<MessageListActionViewDelegate>)theDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lockMsgsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[self.lockMsgsButton setTitle:
			LOCALIZED_STR(@"MESSAGE_LIST_ACTION_LOCK_MSGS_BUTTON_TITLE") forState:UIControlStateNormal];
		[self.lockMsgsButton addTarget:self
				action:@selector(lockMsgsButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.lockMsgsButton];

        self.trashMsgsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[self.trashMsgsButton setTitle:
			LOCALIZED_STR(@"MESSAGE_LIST_ACTION_TRASH_MSGS_BUTTON_TITLE") forState:UIControlStateNormal];
		[self.trashMsgsButton addTarget:self
				action:@selector(trashButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.trashMsgsButton];


		self.cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[self.cancelButton setTitle:
			LOCALIZED_STR(@"MESSAGE_LIST_ACTION_CANCEL_BUTTON_TITLE") forState:UIControlStateNormal];
		[self.cancelButton addTarget:self
				action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.cancelButton];

		
		self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.7];
		self.delegate = theDelegate;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
	assert(0);
	return nil;
}

-(void)layoutButton:(UIButton*)theButton 
	usingViewWidth:(CGFloat)viewWidth andYOffset:(CGFloat)yOffset
{
	assert(theButton != nil);
	CGRect buttonFrame = theButton.frame;
	buttonFrame.origin.y = yOffset;
	buttonFrame.size.width = MESSAGE_LIST_BUTTON_WIDTH;
	buttonFrame.origin.x = viewWidth/2.0 - (buttonFrame.size.width/2.0);
	buttonFrame.size.height = MESSAGE_LIST_BUTTON_HEIGHT;
	[theButton setFrame:buttonFrame];
}

-(void)layoutSubviews
{
	CGFloat viewWidth = self.frame.size.width;
	CGFloat viewHeight = self.frame.size.height;
	CGFloat numButtons = 2;
	CGFloat buttonsHeight = numButtons * MESSAGE_LIST_BUTTON_HEIGHT + (numButtons - 1.0) *
		MESSAGE_LIST_VERT_SPACE;
	buttonsHeight += 2 * MESSAGE_LIST_VERT_SPACE + MESSAGE_LIST_BUTTON_HEIGHT;
	CGFloat currYOffset = viewHeight/2.0 - buttonsHeight/2.0;
	
	[self layoutButton:self.trashMsgsButton usingViewWidth:viewWidth andYOffset:currYOffset];
	currYOffset += (MESSAGE_LIST_BUTTON_HEIGHT + MESSAGE_LIST_VERT_SPACE);
	
	[self layoutButton:self.lockMsgsButton usingViewWidth:viewWidth andYOffset:currYOffset];
	currYOffset += (MESSAGE_LIST_BUTTON_HEIGHT + 2*MESSAGE_LIST_VERT_SPACE);

	[self layoutButton:self.cancelButton usingViewWidth:viewWidth andYOffset:currYOffset];

	
	[super layoutSubviews];
}

-(void)dealloc
{	
	[lockMsgsButton release];
	[trashMsgsButton release];
	[cancelButton release];
	[super dealloc];
}

@end
