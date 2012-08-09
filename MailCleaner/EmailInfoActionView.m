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
#import "AppHelper.h"
#import "AppDelegate.h"
#import "MailClientServerSyncController.h"

const CGFloat EMAIL_ACTION_VIEW_HEIGHT = 45.0;
const CGFloat EMAIL_ACTION_VIEW_TOP_ROW_VERT_CENTER = 15.0;
const CGFloat EMAIL_ACTION_VIEW_TOP_ROW_HEIGHT = 30.0;
const CGFloat EMAIL_ACTION_VIEW_HORIZ_MARGIN = 8.0;
const CGFloat EMAIL_ACTION_VIEW_STATUS_ROW_HEIGHT = 15.0;

const CGFloat ACTION_BUTTON_FONT_SIZE = 12.0f;
const CGFloat ACTION_BUTTON_SPACE = 5.0f;

@implementation EmailInfoActionView

@synthesize emailActionsButton;
@synthesize selectAllButton;
@synthesize unselectAllButton;
@synthesize refreshMsgsButton;
@synthesize refeshActivityIndicator;
@synthesize statusLabel;

@synthesize delegate;

-(NSString*)lastUpdatedStatus
{
	return [NSString stringWithFormat:LOCALIZED_STR(@"MSGS_ACTION_LAST_UPDATED_FORMAT"),
		@"TBD"];;
}

-(id)init
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, EMAIL_ACTION_VIEW_HEIGHT)];

    if (self) {

		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		self.statusLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.statusLabel.textAlignment = UITextAlignmentCenter;
		self.statusLabel.font = [UIFont systemFontOfSize:10.0];
		self.statusLabel.textColor = [UIColor whiteColor];
		self.statusLabel.numberOfLines = 1;
		self.statusLabel.backgroundColor = [UIColor clearColor];
		self.statusLabel.opaque = NO;
		self.statusLabel.text = [self lastUpdatedStatus];
 
		[self addSubview:self.statusLabel];
		
		self.refeshActivityIndicator = [[[UIActivityIndicatorView alloc] 
			initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		[self addSubview:self.refeshActivityIndicator];
		
        self.emailActionsButton = [UIHelper imageButton:@"deleteMsgs.png"
			withTarget:self andAction:@selector(actionButtonPressed)];
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
		
		self.refreshMsgsButton = [UIHelper imageButton:@"01-refresh.png"
			withTarget:self andAction:@selector(refreshMsgs)];
		[self addSubview:self.refreshMsgsButton];
		
    }
    return self;
}

-(void)dealloc
{
	[emailActionsButton release];
	[refreshMsgsButton release];
	[selectAllButton release];
	[unselectAllButton release];
	[refeshActivityIndicator release];
	[statusLabel release];
	[super dealloc];
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

-(void) refreshMsgs
{
	[[AppHelper theAppDelegate].mailSyncController syncWithServerInBackgroundThread];

}

- (id)initWithFrame:(CGRect)frame
{
	assert(0);
	return 0;
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGFloat centerButtonsWidth = 
		self.selectAllButton.frame.size.width +
		self.unselectAllButton.frame.size.width + 
		ACTION_BUTTON_SPACE;

	CGFloat currXOffset = self.frame.size.width/2.0 - centerButtonsWidth/2.0;
	
	// Layout the 2 center buttons for select and unselect all.		
	CGRect buttonFrame = self.unselectAllButton.frame;
	buttonFrame.origin.x = currXOffset;
	buttonFrame.origin.y = EMAIL_ACTION_VIEW_TOP_ROW_VERT_CENTER - buttonFrame.size.height/2.0;
	[self.unselectAllButton setFrame:buttonFrame];
	
	currXOffset += buttonFrame.size.width + ACTION_BUTTON_SPACE;
	
	buttonFrame = self.selectAllButton.frame;
	buttonFrame.origin.x = currXOffset;
	buttonFrame.origin.y = EMAIL_ACTION_VIEW_TOP_ROW_VERT_CENTER - buttonFrame.size.height/2.0;
	[self.selectAllButton setFrame:buttonFrame];
	
	// Layout the button for deleting selected/all messages on the RHS of the view		
	buttonFrame = self.emailActionsButton.frame;
	buttonFrame.origin.x = self.frame.size.width - buttonFrame.size.width - EMAIL_ACTION_VIEW_HORIZ_MARGIN;
	buttonFrame.origin.y = EMAIL_ACTION_VIEW_HEIGHT/2.0 - buttonFrame.size.height/2.0;
	[self.emailActionsButton setFrame:buttonFrame];


	// Layout the refresh button on the LHS of the view
	buttonFrame = self.refreshMsgsButton.frame;
	buttonFrame.origin.x = EMAIL_ACTION_VIEW_HORIZ_MARGIN;
	buttonFrame.origin.y = EMAIL_ACTION_VIEW_HEIGHT/2.0 - buttonFrame.size.height/2.0;
	[self.refreshMsgsButton setFrame:buttonFrame];
	
	// Center the refresh indicator relative to the refresh button.
	CGRect refreshIndicatorFrame = self.refeshActivityIndicator.frame;
	refreshIndicatorFrame.origin.x = buttonFrame.origin.x + buttonFrame.size.width/2.0 
		- refreshIndicatorFrame.size.width/2.0;
	refreshIndicatorFrame.origin.y = buttonFrame.origin.y + buttonFrame.size.height/2.0 
		- refreshIndicatorFrame.size.height/2.0;; //buttonFrame.origin.y;
	[self.refeshActivityIndicator setFrame:refreshIndicatorFrame];

	CGRect statusFrame = self.statusLabel.frame;
	statusFrame.origin.x = 0.0;
	statusFrame.origin.y = EMAIL_ACTION_VIEW_TOP_ROW_HEIGHT;
	statusFrame.size.width = self.frame.size.width;
	statusFrame.size.height = EMAIL_ACTION_VIEW_STATUS_ROW_HEIGHT;
	[self.statusLabel setFrame:statusFrame];
		
}

#pragma mark MailSyncProgressDelegate


-(void)startRefreshIndicator
{
	[self.refeshActivityIndicator setHidden:FALSE];
	[self.refreshMsgsButton setHidden:TRUE];
	[self.refeshActivityIndicator startAnimating];	
	self.statusLabel.text = LOCALIZED_STR(@"MSGS_ACTION_UPDATING_STATUS_FORMAT");
}

-(void)stopRefreshIndicator
{
	[self.refeshActivityIndicator setHidden:TRUE];
	[self.refreshMsgsButton setHidden:FALSE];
	[self.refeshActivityIndicator stopAnimating];
	self.statusLabel.text = [self lastUpdatedStatus];
}

-(void)mailSyncConnectionStarted
{
	NSLog(@"mail sync started in EmailActionView");
	// The UI updates need to be performedon the main thread.
	[self performSelectorOnMainThread:@selector(startRefreshIndicator) 
		withObject:self waitUntilDone:FALSE];
}

-(void)mailSyncConnectionEstablished
{
}

-(void)mailSyncUpdateProgress:(CGFloat)percentProgress
{
}

-(void)mailSyncConnectionTeardownStarted
{
}

-(void)mailSyncConnectionTeardownFinished
{
	NSLog(@"mail sync teardown finished in EmailActionView");
	// The UI updates need to be performedon the main thread.
	[self performSelectorOnMainThread:@selector(stopRefreshIndicator) 
		withObject:self waitUntilDone:FALSE];
}




@end
