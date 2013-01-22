//
//  DeleteMsgConfirmationView.m
//
//  Created by Steve Roehling on 7/19/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
#import "CollectionHelper.h"
#import <QuartzCore/QuartzCore.h>


CGFloat const DELETE_CONFIRMATION_BUTTON_HEIGHT = 30.0f;
CGFloat const DELETE_CONFIRMATION_BUTTON_FONT_SIZE = 15.0f;
CGFloat const DELETE_CONFIRMATION_TITLE_FONT_SIZE = 16.0f;
CGFloat const DELETE_CONFIRMATION_BUTTON_WIDTH = 280.0f;
CGFloat const DELETE_CONFIRMATION_VERT_SPACE = 12.0f;
CGFloat const DELETE_CONFIRMATION_TITLE_SPACE = 8.0f;
CGFloat const DELETE_CONFIRMATION_LEFT_MARGIN = 10.0f;
CGFloat const DELETE_CONFIRMATION_RIGHT_MARGIN = 10.0f;
CGFloat const DELETE_CONFIRMATION_TOP_MARGIN = 10.0f;
CGFloat const DELETE_CONFIRMATION_BOTTOM_MARGIN = 10.0f;
CGFloat const DELETE_CONFIRMATION_CAPTION_WIDTH = 60.0f;
CGFloat const DELETE_CONFIRMATION_BACKGROUND_INSET = 5.0f;
CGFloat const DELETE_CONFIRMATION_BACKGROUND_TOP_MARGIN = 15.0f;
CGFloat const DELETE_CONFIRMATION_BACKGROUND_BOTTOM_MARGIN = 20.0f;
CGFloat const DELETE_CONFIRMATION_MSG_NUMBER_FRAME_HEIGHT= 20.0f;


@implementation DeleteMsgConfirmationView

@synthesize confirmationTitle;

@synthesize cancelButton;
@synthesize deleteButton;
@synthesize deleteAllButton;
@synthesize skipButton;

@synthesize sendDateLabel;
@synthesize sendDateCaption;

@synthesize fromLabel;
@synthesize fromCaption;

@synthesize subjectLabel;
@synthesize subjectCaption;

@synthesize backgroundImage;

@synthesize currentMsgNumber;

@synthesize msgsToDelete;
@synthesize msgDisplayView;
@synthesize msgsConfirmedForDeletion;
@synthesize appDmc;
@synthesize delegate;

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
	andDelegate:(id<DeleteMsgConfirmationViewDelegate>)deleteDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
	
		self.appDmc = theAppDmc;
	
		assert(theMsgsToDelete != nil);
		assert([theMsgsToDelete count] > 0);

		self.msgsToDelete = [CollectionHelper sortArray:theMsgsToDelete
			withKey:EMAIL_INFO_SEND_DATE_KEY andAscending:FALSE];

		currentMsgIndex = 0;
		self.delegate = deleteDelegate;
		
		self.msgsConfirmedForDeletion = [[[NSMutableSet alloc] init] autorelease];
		
		self.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.7];
		
		UIImage *bkgImage = [UIImage imageNamed:@"confirmDeleteBkg.png"];
		UIImage *stretchableBackgroundImage =
			[bkgImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
		self.backgroundImage = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
		self.backgroundImage.image = stretchableBackgroundImage;
		self.backgroundImage.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:self.backgroundImage];
		
		self.confirmationTitle = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.confirmationTitle.backgroundColor = [UIColor clearColor];
        self.confirmationTitle.opaque = NO;
        self.confirmationTitle.textColor = [UIColor whiteColor];
		self.confirmationTitle.textAlignment = NSTextAlignmentCenter;
        self.confirmationTitle.highlightedTextColor = [UIColor whiteColor];
        self.confirmationTitle.font = [UIFont boldSystemFontOfSize:DELETE_CONFIRMATION_TITLE_FONT_SIZE];
		self.confirmationTitle.text = LOCALIZED_STR(@"MESSAGE_DELETE_CONFIRMATION_TITLE");
		[self.confirmationTitle sizeToFit];
		[self addSubview:self.confirmationTitle];

 
		self.deleteButton = [UIHelper buttonWithBackgroundColor:[UIColor redColor] 
			andTitleColor:[UIColor whiteColor] andTarget:self andAction:@selector(deleteButtonPressed) andTitle:LOCALIZED_STR(@"DELETE_CONFIRMATION_DELETE_BUTTON_TITLE")  
				andFontSize:DELETE_CONFIRMATION_BUTTON_FONT_SIZE];
 		[self addSubview:self.deleteButton];

		self.deleteAllButton = [UIHelper buttonWithBackgroundColor:[UIColor redColor] 
			andTitleColor:[UIColor whiteColor] andTarget:self andAction:@selector(deleteAllButtonPressed) andTitle:LOCALIZED_STR(@"DELETE_CONFIRMATION_DELETE_ALL_BUTTON_TITLE") andFontSize:DELETE_CONFIRMATION_BUTTON_FONT_SIZE];
 		[self addSubview:self.deleteAllButton];

		self.cancelButton = [UIHelper buttonWithBackgroundColor:[UIColor whiteColor] 
			andTitleColor:[UIColor blackColor] andTarget:self andAction:@selector(cancelButtonPressed) andTitle:LOCALIZED_STR(@"DELETE_CONFIRMATION_CANCEL_BUTTON_TITLE")  andFontSize:DELETE_CONFIRMATION_BUTTON_FONT_SIZE];
		[self addSubview:self.cancelButton];
		
		self.skipButton = [UIHelper buttonWithBackgroundColor:[UIColor whiteColor] 
			andTitleColor:[UIColor blackColor] andTarget:self andAction:@selector(skipButtonPressed) andTitle:LOCALIZED_STR(@"DELETE_CONFIRMATION_SKIP_BUTTON_TITLE") andFontSize:DELETE_CONFIRMATION_BUTTON_FONT_SIZE];
		[self addSubview:self.skipButton];

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
		
		self.currentMsgNumber = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.currentMsgNumber.backgroundColor = [UIColor clearColor];
		self.currentMsgNumber.opaque = NO;
		self.currentMsgNumber.textAlignment = NSTextAlignmentRight;
		self.currentMsgNumber.textColor = [UIColor whiteColor];
		self.currentMsgNumber.highlightedTextColor = [UIColor whiteColor];
		self.currentMsgNumber.font = [UIFont boldSystemFontOfSize:12];
		[self addSubview:self.currentMsgNumber];
		[self configureMsgNumberLabel];

		[self configureCurrentMsg];
		
		// By default, the view starts off invisible, then
		// is faded in with the showWithAnimation method.
		self.alpha = 0.0;
	   
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
	
	CGFloat numButtons = 4;
	CGFloat controlsHeight =
		self.confirmationTitle.frame.size.height + DELETE_CONFIRMATION_TITLE_SPACE
		+ self.msgDisplayView.frame.size.height
		+ DELETE_CONFIRMATION_MSG_NUMBER_FRAME_HEIGHT
		+ DELETE_CONFIRMATION_VERT_SPACE
		+ DELETE_CONFIRMATION_BUTTON_HEIGHT*numButtons // Space for the buttons themselves
		+ DELETE_CONFIRMATION_VERT_SPACE*((numButtons-1) + 1.5); // Space between the buttons (2 spaces before cancel, 1.5 before delete all button)
	
	CGFloat currYOffset = viewHeight/2.0 - controlsHeight/2.0;
	CGFloat startYOffset = currYOffset;
	
	[self.confirmationTitle sizeToFit];
	CGRect titleFrame = self.confirmationTitle.frame;
	titleFrame.origin.y = currYOffset;
	titleFrame.origin.x = viewWidth/2.0 - titleFrame.size.width/2.0;
	[self.confirmationTitle setFrame:titleFrame];
	
	currYOffset += titleFrame.size.height + DELETE_CONFIRMATION_TITLE_SPACE;
	
	CGRect msgDisplayViewFrame = self.msgDisplayView.frame;
	msgDisplayViewFrame.origin.y = currYOffset;
	[self.msgDisplayView setFrame:msgDisplayViewFrame];
	
	
	// Layout the buttons for confirming the deletion or canceling.
 
	currYOffset +=  self.msgDisplayView.frame.size.height;
	
	CGRect msgNumberFrame = self.currentMsgNumber.frame;
	msgNumberFrame.origin.x = DELETE_CONFIRMATION_LEFT_MARGIN;
	msgNumberFrame.size.width = DELETE_CONFIRMATION_BUTTON_WIDTH;
	msgNumberFrame.size.height = DELETE_CONFIRMATION_MSG_NUMBER_FRAME_HEIGHT;
	msgNumberFrame.origin.y = currYOffset;
	[self.currentMsgNumber setFrame:msgNumberFrame];
	
	currYOffset += msgNumberFrame.size.height + DELETE_CONFIRMATION_VERT_SPACE;
	[self layoutButton:self.skipButton usingViewWidth:viewWidth andYOffset:currYOffset];
	
	currYOffset +=  DELETE_CONFIRMATION_BUTTON_HEIGHT + DELETE_CONFIRMATION_VERT_SPACE;
	[self layoutButton:self.deleteButton usingViewWidth:viewWidth andYOffset:currYOffset];
	
	currYOffset +=  1.5*DELETE_CONFIRMATION_BUTTON_HEIGHT + DELETE_CONFIRMATION_VERT_SPACE;
	[self layoutButton:self.deleteAllButton usingViewWidth:viewWidth andYOffset:currYOffset];

	// Double the space between the last button and cancel button
	currYOffset += DELETE_CONFIRMATION_VERT_SPACE*2.0 + DELETE_CONFIRMATION_BUTTON_HEIGHT;

	[self layoutButton:self.cancelButton usingViewWidth:viewWidth andYOffset:currYOffset];

	currYOffset +=  DELETE_CONFIRMATION_BUTTON_HEIGHT;

	
	CGRect bkgFrame = CGRectInset(self.frame, DELETE_CONFIRMATION_BACKGROUND_INSET,
			DELETE_CONFIRMATION_BACKGROUND_INSET);
	bkgFrame.origin.y = startYOffset - DELETE_CONFIRMATION_BACKGROUND_TOP_MARGIN;
	bkgFrame.size.height = currYOffset - bkgFrame.origin.y + DELETE_CONFIRMATION_BACKGROUND_BOTTOM_MARGIN;
	
	[self.backgroundImage setFrame:bkgFrame];
	
	[super layoutSubviews];
}

-(void)showWithAnimation
{
	[UIView animateWithDuration:0.35
		delay:0.0 options:UIViewAnimationCurveEaseInOut 
			 animations:^{self.alpha = 1.0;}
			 completion:^(BOOL finished) {}];		
}

-(void)hideWithAnimation
{
	[UIView animateWithDuration:0.35
		delay:0.0 options:UIViewAnimationCurveEaseInOut 
			 animations:^{self.alpha = 0.0;}
			 completion:^(BOOL finished) {
				[self removeFromSuperview];
			 }
	];
}

-(void)cancelButtonPressed
{
	[self hideWithAnimation];
}

-(void)deleteConfirmedMsgsInBackgroundThread
{
	if(self.delegate != nil)
	{
		[self.delegate msgsConfirmedForDeletion:self.msgsConfirmedForDeletion];
	}
}

-(void)configureMsgNumberLabel
{
	self.currentMsgNumber.text = [NSString stringWithFormat:
		LOCALIZED_STR(@"DELETE_CONFIRMATION_CURRENT_MESSAGE_FORMAT"),
		currentMsgIndex+1,self.msgsToDelete.count];
}

-(void)advanceCurrentMessage
{
	currentMsgIndex ++;
	if(currentMsgIndex >= [self.msgsToDelete count])
	{		
		[self deleteConfirmedMsgsInBackgroundThread];
		[self hideWithAnimation];
	}
	else 
	{
		[self configureMsgNumberLabel];
		[self configureCurrentMsg];
		[self setNeedsLayout];
	}
}

-(void)skipButtonPressed
{
	[self advanceCurrentMessage];
}

-(void)confirmCurrentMessageForDeletion
{
	EmailInfo *currentMsgInfo = [self currentMsg];
	assert(currentMsgInfo != nil);
	[self.msgsConfirmedForDeletion addObject:currentMsgInfo];
}

-(void)deleteButtonPressed
{
	[self confirmCurrentMessageForDeletion];
	
	[self advanceCurrentMessage];
}

-(void)deleteAllButtonPressed
{
	[self confirmCurrentMessageForDeletion];
	currentMsgIndex++;
	
	while(currentMsgIndex < [self.msgsToDelete count])
	{
		[self confirmCurrentMessageForDeletion];
		currentMsgIndex++;
	}
	
	[self deleteConfirmedMsgsInBackgroundThread];
	[self hideWithAnimation];
}


-(void)dealloc
{
	[confirmationTitle release];

	[sendDateLabel release];
	[sendDateCaption release];
	
	[fromLabel release];
	[fromCaption release];
	
	[subjectLabel release];
	[subjectCaption release];
	
	[currentMsgNumber release];
	
	[msgDisplayView release];
	[backgroundImage release];

	[cancelButton release];
	[deleteButton release];
	[deleteAllButton release];
	[skipButton release];

	[msgsToDelete release];
	[msgsConfirmedForDeletion release];

	[appDmc release];

	[super dealloc];
}

@end
