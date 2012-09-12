//
//  DeleteMsgConfirmationView.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DeleteMsgConfirmationView.h"
#import "LocalizationHelper.h"
#import "UIHelper.h"
#import "ColorHelper.h"
#import "EmailInfo.h"
#import "DateHelper.h"
 #import "DataModelController.h"
#import "AppDelegate.h"
#import "AppHelper.h"
#import "EmailAddress.h"
#import "MsgDetailHelper.h"
#import <QuartzCore/QuartzCore.h>


const CGFloat DELETE_CONFIRMATION_BUTTON_HEIGHT = 30.0f;
const CGFloat DELETE_CONFIRMATION_BUTTON_WIDTH = 280.0f;
const CGFloat DELETE_CONFIRMATION_VERT_SPACE = 15.0f;
const CGFloat DELETE_CONFIRMATION_LEFT_MARGIN = 10.0f;
const CGFloat DELETE_CONFIRMATION_RIGHT_MARGIN = 10.0f;
const CGFloat DELETE_CONFIRMATION_TOP_MARGIN = 10.0f;
const CGFloat DELETE_CONFIRMATION_BOTTOM_MARGIN = 10.0f;
const CGFloat DELETE_CONFIRMATION_CAPTION_WIDTH = 60.0f;

@implementation DeleteMsgConfirmationView

@synthesize cancelButton;
@synthesize deleteButton;
@synthesize skipButton;

@synthesize sendDateLabel;
@synthesize sendDateCaption;

@synthesize fromLabel;
@synthesize fromCaption;

@synthesize subjectLabel;
@synthesize subjectCaption;

@synthesize msgsToDelete;
@synthesize msgDisplayView;
@synthesize msgsConfirmedForDeletion;
@synthesize appDmc;

-(EmailInfo*)currentMsg
{    
	EmailInfo *info = [self.msgsToDelete objectAtIndex:currentMsgIndex];
	assert(info != nil);
	return info;
}

-(void)configureCurrentMsg
{
    EmailInfo *currentMsgInfo = [self currentMsg];
    self.fromLabel.text = [currentMsgInfo.senderAddress formattedAddress];
    self.sendDateLabel.text = [currentMsgInfo formattedSendDateAndTime];
	self.subjectLabel.text = currentMsgInfo.subject;
}

- (id)initWithFrame:(CGRect)frame andMsgsToDelete:(NSArray*)theMsgsToDelete
	andAppDataModelController:(DataModelController*)theAppDmc
{
    self = [super initWithFrame:frame];
    if (self) {
	
		self.appDmc = theAppDmc;
	
		assert(theMsgsToDelete != nil);
		assert([theMsgsToDelete count] > 0);
		self.msgsToDelete = theMsgsToDelete;
		currentMsgIndex = 0;
		self.msgsConfirmedForDeletion = [[[NSMutableSet alloc] init] autorelease];
 
		self.deleteButton = [UIHelper buttonWithBackgroundColor:[UIColor redColor] andTitleColor:[UIColor whiteColor]];
 		[self.deleteButton setTitle:
			LOCALIZED_STR(@"DELETE_CONFIRMATION_DELETE_BUTTON_TITLE") 
			forState:UIControlStateNormal];
		[self.deleteButton addTarget:self
				action:@selector(deleteButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.deleteButton];

		self.cancelButton = [UIHelper buttonWithBackgroundColor:[UIColor whiteColor] andTitleColor:[UIColor blackColor]];
		[self.cancelButton setTitle:
			LOCALIZED_STR(@"DELETE_CONFIRMATION_CANCEL_BUTTON_TITLE") 
			forState:UIControlStateNormal];
		[self.cancelButton addTarget:self
				action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.cancelButton];
		
		self.skipButton = [UIHelper buttonWithBackgroundColor:[UIColor whiteColor] andTitleColor:[UIColor blackColor]];
		[self.skipButton setTitle:LOCALIZED_STR(@"DELETE_CONFIRMATION_SKIP_BUTTON_TITLE") 
			forState:UIControlStateNormal];
		[self.skipButton addTarget:self action:@selector(skipButtonPressed) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:self.skipButton];

 
   		self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
		
		self.msgDisplayView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		self.msgDisplayView.backgroundColor = [UIColor whiteColor];
		self.msgDisplayView.layer.borderColor = [UIColor blackColor].CGColor;
		self.msgDisplayView.layer.borderWidth = 0.5f;
		self.msgDisplayView.layer.cornerRadius = 5.0f;
		[self addSubview:self.msgDisplayView];
		
		
		self.fromLabel = [MsgDetailHelper msgHeaderTextLabel];
		self.fromCaption = [MsgDetailHelper msgHeaderCaptionLabel];
		self.fromCaption.text = LOCALIZED_STR(@"MESSAGE_DETAIL_FROM_CAPTION");
		[self.msgDisplayView addSubview: self.fromLabel]; 
		[self.msgDisplayView addSubview: self.fromCaption]; 
		
		self.sendDateLabel = [MsgDetailHelper msgHeaderTextLabel];
		self.sendDateCaption = [MsgDetailHelper msgHeaderCaptionLabel];
		self.sendDateCaption.text = LOCALIZED_STR(@"MESSAGE_DETAIL_DATE_CAPTION");
		[self.msgDisplayView addSubview:self.sendDateCaption];     
		[self.msgDisplayView addSubview:self.sendDateLabel];
		
		self.subjectLabel = [MsgDetailHelper msgHeaderTextLabel];
		self.subjectCaption = [MsgDetailHelper msgHeaderCaptionLabel];
		self.subjectCaption.text =  LOCALIZED_STR(@"MESSAGE_DETAIL_SUBJECT_CAPTION");
		[self.msgDisplayView addSubview:self.subjectLabel]; 
		[self.msgDisplayView addSubview:self.subjectCaption];
		
		[self configureCurrentMsg];
	   
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
	buttonFrame.size.width = DELETE_CONFIRMATION_BUTTON_WIDTH;
	buttonFrame.origin.x = viewWidth/2.0 - (buttonFrame.size.width/2.0);
	buttonFrame.size.height = DELETE_CONFIRMATION_BUTTON_HEIGHT;
	[theButton setFrame:buttonFrame];
}

-(CGFloat)layoutHeaderLineWithCaption:(UILabel*)captionLabel andText:(UILabel*)textLabel
	andCurrYOffset:(CGFloat)yOffset
{
	[captionLabel sizeToFit];
	[textLabel sizeToFit];
	
	CGFloat headerWidth = DELETE_CONFIRMATION_BUTTON_WIDTH;
		
	CGRect captionFrame = captionLabel.frame;
	captionFrame.origin.x = DELETE_CONFIRMATION_LEFT_MARGIN;
	captionFrame.origin.y = yOffset;
	captionFrame.size.width = DELETE_CONFIRMATION_CAPTION_WIDTH;
	[captionLabel setFrame:captionFrame];
	
	CGFloat maxTextWidth = headerWidth
		 - DELETE_CONFIRMATION_RIGHT_MARGIN - DELETE_CONFIRMATION_LEFT_MARGIN 
		 - DELETE_CONFIRMATION_CAPTION_WIDTH;
	CGSize maxTextSize = CGSizeMake(maxTextWidth, 200);
	CGSize textSize = [textLabel.text sizeWithFont:textLabel.font
		constrainedToSize:maxTextSize lineBreakMode:textLabel.lineBreakMode];

	
	CGRect textFrame = textLabel.frame;
	textFrame.origin.x = DELETE_CONFIRMATION_LEFT_MARGIN + DELETE_CONFIRMATION_CAPTION_WIDTH;
	textFrame.origin.y = yOffset;
	textFrame.size.width = textSize.width;
	textFrame.size.height = textSize.height;
	[textLabel setFrame:textFrame];
	
	CGFloat headerLineHeight = MAX(CGRectGetHeight(textFrame),CGRectGetHeight(captionFrame));
	
	return headerLineHeight;
}

-(void)layoutMsgDisplayView
{
	[self configureCurrentMsg];
	
	[sendDateLabel sizeToFit];
	[fromLabel sizeToFit];
	[subjectlabel sizeToFit];
		
	CGFloat currYOffset = DELETE_CONFIRMATION_TOP_MARGIN;
		
	currYOffset +=	[self layoutHeaderLineWithCaption:self.fromCaption 
		andText:self.fromLabel andCurrYOffset:currYOffset];

	currYOffset +=	[self layoutHeaderLineWithCaption:self.sendDateCaption 
			andText:self.sendDateLabel andCurrYOffset:currYOffset];
	
	currYOffset +=	[self layoutHeaderLineWithCaption:self.subjectCaption 
		andText:self.subjectLabel andCurrYOffset:currYOffset];
	
	currYOffset += DELETE_CONFIRMATION_BOTTOM_MARGIN;
	
	CGRect msgDisplayViewFrame = self.msgDisplayView.frame;
	msgDisplayViewFrame.size.width = DELETE_CONFIRMATION_BUTTON_WIDTH;
	msgDisplayViewFrame.size.height = currYOffset;
	msgDisplayViewFrame.origin.y = 0.0f;
	CGFloat confirmDeleteViewWidth = self.frame.size.width;
	msgDisplayViewFrame.origin.x = confirmDeleteViewWidth/2.0 - (msgDisplayViewFrame.size.width/2.0);
	[self.msgDisplayView setFrame:msgDisplayViewFrame];
}


-(void)layoutSubviews
{
	CGFloat viewWidth = self.frame.size.width;
	CGFloat viewHeight = self.frame.size.height;
	
	[self layoutMsgDisplayView];
	
	CGFloat numButtons = 3;
	CGFloat controlsHeight =  self.msgDisplayView.frame.size.height + DELETE_CONFIRMATION_VERT_SPACE
		+ DELETE_CONFIRMATION_BUTTON_HEIGHT*numButtons // Space for the buttons themselves
		+ DELETE_CONFIRMATION_VERT_SPACE*((numButtons-1) + 1); // Space between the buttons (2 spaces before cancel button)
	
	CGFloat currYOffset = viewHeight/2.0 - controlsHeight/2.0;
	
	CGRect msgDisplayViewFrame = self.msgDisplayView.frame;
	msgDisplayViewFrame.origin.y = currYOffset;
	[self.msgDisplayView setFrame:msgDisplayViewFrame];
	
	
	// Layout the buttons for confirming the deletion or canceling.
 
	currYOffset +=  self.msgDisplayView.frame.size.height + DELETE_CONFIRMATION_VERT_SPACE;
	
	[self layoutButton:self.deleteButton usingViewWidth:viewWidth andYOffset:currYOffset];
	
	currYOffset +=  DELETE_CONFIRMATION_VERT_SPACE + DELETE_CONFIRMATION_BUTTON_HEIGHT;
	
	[self layoutButton:self.skipButton usingViewWidth:viewWidth andYOffset:currYOffset];
	
	// Double the space between the last button and cancel button
	currYOffset += DELETE_CONFIRMATION_VERT_SPACE*2.0 + DELETE_CONFIRMATION_BUTTON_HEIGHT;

	[self layoutButton:self.cancelButton usingViewWidth:viewWidth andYOffset:currYOffset];
	
	[super layoutSubviews];
}

-(void)cancelButtonPressed
{
	[self removeFromSuperview];
}

-(void)advanceCurrentMessage
{
	currentMsgIndex ++;
	if(currentMsgIndex >= [self.msgsToDelete count])
	{
		// Done confirming the messages.
		for (EmailInfo *info in self.msgsConfirmedForDeletion)
		{
			info.deleted = [NSNumber numberWithBool:TRUE];		
		}
		[self.appDmc saveContext];
		
		AppDelegate *appDelegate = [AppHelper theAppDelegate];
		[appDelegate deleteMarkedMsgsInBackgroundThread];
		

		[self removeFromSuperview];
	}
	else 
	{
		[self configureCurrentMsg];
		[self setNeedsLayout];
	}

}

-(void)skipButtonPressed
{
	[self advanceCurrentMessage];
}

-(void)deleteButtonPressed
{
	NSLog(@"Delete button pressed");
	
	EmailInfo *currentMsgInfo = [self currentMsg];
	[self.msgsConfirmedForDeletion addObject:currentMsgInfo];
	
	[self advanceCurrentMessage];
}


-(void)dealloc
{
	[sendDateLabel release];
	[sendDateCaption release];
	
	[fromLabel release];
	[fromCaption release];
	
	[subjectLabel release];
	[subjectCaption release];
	
	[msgDisplayView release];

	[cancelButton release];
	[deleteButton release];
	[skipButton release];

	[msgsToDelete release];
	[msgsConfirmedForDeletion release];

	[appDmc release];

	[super dealloc];
}

@end
