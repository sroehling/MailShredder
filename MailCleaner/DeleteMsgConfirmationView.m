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
#import <QuartzCore/QuartzCore.h>


const CGFloat DELETE_CONFIRMATION_BUTTON_HEIGHT = 30.0f;
const CGFloat DELETE_CONFIRMATION_BUTTON_WIDTH = 280.0f;
const CGFloat DELETE_CONFIRMATION_VERT_SPACE = 15.0f;
const CGFloat DELETE_CONFIRMATION_LEFT_MARGIN = 10.0f;
const CGFloat DELETE_CONFIRMATION_RIGHT_MARGIN = 10.0f;
const CGFloat DELETE_CONFIRMATION_TOP_MARGIN = 10.0f;
const CGFloat DELETE_CONFIRMATION_BOTTOM_MARGIN = 10.0f;

@implementation DeleteMsgConfirmationView

@synthesize cancelButton;
@synthesize deleteButton;
@synthesize skipButton;
@synthesize sendDateLabel;
@synthesize fromLabel;
@synthesize subjectLabel;
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
    self.sendDateLabel.text = [currentMsgInfo formattedSendDate];;
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
		
		
		self.fromLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];       
		self.fromLabel.backgroundColor = [UIColor clearColor];
		self.fromLabel.opaque = NO;
		self.fromLabel.textColor = [UIColor blackColor];
		self.fromLabel.textAlignment = UITextAlignmentLeft;
		self.fromLabel.highlightedTextColor = [UIColor blackColor];
		self.fromLabel.font = [UIFont boldSystemFontOfSize:13];       
		[self.msgDisplayView addSubview: self.fromLabel]; 
		
		self.sendDateLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.sendDateLabel.backgroundColor = [UIColor clearColor];
		self.sendDateLabel.opaque = NO;
		self.sendDateLabel.textColor = [ColorHelper blueTableTextColor];
		self.sendDateLabel.textAlignment = UITextAlignmentRight;
		self.sendDateLabel.highlightedTextColor = [ColorHelper blueTableTextColor];
		self.sendDateLabel.font = [UIFont systemFontOfSize:13];       
		[self.msgDisplayView addSubview:self.sendDateLabel];
		
		self.subjectLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.subjectLabel.backgroundColor = [UIColor clearColor];
		self.subjectLabel.opaque = NO;
		self.subjectLabel.textColor = [UIColor darkGrayColor];
		self.subjectLabel.textAlignment = UITextAlignmentLeft;
		self.subjectLabel.highlightedTextColor = [UIColor darkGrayColor];
		self.subjectLabel.font = [UIFont systemFontOfSize:13];        
		self.subjectLabel.lineBreakMode = UILineBreakModeTailTruncation;
		self.subjectLabel.numberOfLines = 1;
		[self.msgDisplayView addSubview: self.subjectLabel]; 
		
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

-(void)layoutMsgDisplayView
{
	[self configureCurrentMsg];
	
	[sendDateLabel sizeToFit];
	[fromLabel sizeToFit];
	[subjectlabel sizeToFit];

	CGFloat viewWidth = self.frame.size.width;
	
	CGFloat msgDisplayWidth = DELETE_CONFIRMATION_BUTTON_WIDTH;
	
	CGFloat currYOffset = DELETE_CONFIRMATION_TOP_MARGIN;
	
	CGRect sendDateFrame = sendDateLabel.frame;
	sendDateFrame.origin.x = msgDisplayWidth - sendDateFrame.size.width - DELETE_CONFIRMATION_RIGHT_MARGIN;
	sendDateFrame.origin.y = currYOffset;
	[sendDateLabel setFrame:sendDateFrame];
	
	CGRect fromFrame = fromLabel.frame;
	fromFrame.origin.x = DELETE_CONFIRMATION_LEFT_MARGIN;
	fromFrame.origin.y = currYOffset;
	[fromLabel setFrame:fromFrame];
	
	CGFloat firstRowHeight = MAX(sendDateLabel.frame.size.height,fromLabel.frame.size.height);
	currYOffset += firstRowHeight + DELETE_CONFIRMATION_VERT_SPACE;
	
	CGRect subjectFrame = subjectLabel.frame;
	subjectFrame.origin.x = DELETE_CONFIRMATION_LEFT_MARGIN;
	subjectFrame.origin.y = currYOffset;
	subjectFrame.size.width = msgDisplayWidth  - DELETE_CONFIRMATION_RIGHT_MARGIN - DELETE_CONFIRMATION_LEFT_MARGIN;
	subjectFrame.size.height = 20.0f;
	[subjectLabel setFrame:subjectFrame];
	NSLog(@"subject frame: %@",NSStringFromCGRect(subjectFrame));
	
	currYOffset += subjectFrame.size.height + DELETE_CONFIRMATION_BOTTOM_MARGIN;
	
	CGRect msgDisplayViewFrame = self.msgDisplayView.frame;
	msgDisplayViewFrame.size.width = msgDisplayWidth;
	msgDisplayViewFrame.size.height = currYOffset;
	msgDisplayViewFrame.origin.y = 0.0f;
	msgDisplayViewFrame.origin.x = viewWidth/2.0 - (msgDisplayViewFrame.size.width/2.0);
	[self.msgDisplayView setFrame:msgDisplayViewFrame];
	NSLog(@"msgDisplayView frame: %@",NSStringFromCGRect(msgDisplayViewFrame));


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
	[cancelButton release];
	[deleteButton release];
	[skipButton release];

	[sendDateLabel release];
	[fromLabel release];
	[subjectLabel release];
	[msgDisplayView release];
	
	[msgsToDelete release];
	[msgsConfirmedForDeletion release];

	[appDmc release];

	[super dealloc];
}

@end
