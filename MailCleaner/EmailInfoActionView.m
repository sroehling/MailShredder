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
#import "SharedAppVals.h"
#import "EmailAccount.h"
#import "DateHelper.h"

CGFloat const EMAIL_ACTION_VIEW_HEIGHT = 55.0;
CGFloat const EMAIL_ACTION_VIEW_SELECTION_ROW_HEIGHT = 5.0;

CGFloat const EMAIL_ACTION_VIEW_BUTTON_ROW_VERT_CENTER = 15.0;
CGFloat const EMAIL_ACTION_VIEW_BUTTON_ROW_HEIGHT = 30.0;

CGFloat const EMAIL_ACTION_VIEW_HORIZ_MARGIN = 8.0;
CGFloat const EMAIL_ACTION_VIEW_STATUS_ROW_HEIGHT = 18.0;

CGFloat const ACTION_BUTTON_FONT_SIZE = 13.0f;
CGFloat const ACTION_BUTTON_SPACE = 5.0f;
CGFloat const ACTION_BUTTON_SIZE = 24.0f;

CGFloat const  EMAIL_ACTION_VIEW_STATUS_LABEL_FONT_SIZE = 11.0f;

@implementation EmailInfoActionView

@synthesize emailActionsButton;
@synthesize selectAllButton;
@synthesize unselectAllButton;
@synthesize refreshMsgsButton;
@synthesize refeshActivityIndicator;
@synthesize statusLabel;
@synthesize numSelectedMsgsLabel;

@synthesize delegate;

-(NSString*)lastUpdatedStatus
{
	EmailAccount *currAcct = [AppHelper theAppDelegate].sharedAppVals.currentEmailAcct;
	if(currAcct != nil)
	{
		[currAcct.managedObjectContext refreshObject:currAcct mergeChanges:TRUE];
		if(currAcct.lastSync != nil)
		{
			return [NSString stringWithFormat:LOCALIZED_STR(@"MSGS_ACTION_LAST_UPDATED_FORMAT"),
				[[DateHelper theHelper].longDateFormatter stringFromDate:currAcct.lastSync]];
		}
	}
	return [NSString stringWithFormat:LOCALIZED_STR(@"MSGS_ACTION_LAST_UPDATED_FORMAT"),
				LOCALIZED_STR(@"MSGS_ACTION_LAST_UPDATED_NEVER")];

}

-(UILabel*)emailInfoViewStatusLabel
{
	UILabel *theStatusLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	theStatusLabel.textAlignment = UITextAlignmentCenter;
	theStatusLabel.font = [UIFont systemFontOfSize:EMAIL_ACTION_VIEW_STATUS_LABEL_FONT_SIZE];
	theStatusLabel.textColor = [UIColor whiteColor];
	theStatusLabel.numberOfLines = 1;
	theStatusLabel.backgroundColor = [UIColor clearColor];
	theStatusLabel.opaque = NO;
	return theStatusLabel;
}

-(id)init
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	self = [super initWithFrame:CGRectMake(0, 0, screenRect.size.width, EMAIL_ACTION_VIEW_HEIGHT)];

    if (self) {

		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
		self.statusLabel = [self emailInfoViewStatusLabel];
		self.statusLabel.text = [self lastUpdatedStatus];
		[self addSubview:self.statusLabel];
		
		self.numSelectedMsgsLabel = [self emailInfoViewStatusLabel];
 		[self addSubview:self.numSelectedMsgsLabel];

		if([AppHelper generatingLaunchScreen])
		{
			self.statusLabel.hidden = TRUE;
		}
		
		CGSize buttonSize = CGSizeMake(ACTION_BUTTON_SIZE,ACTION_BUTTON_SIZE);
		CGSize actionButtonSize = CGSizeMake(100.0f, 25.0f);
		
		self.refeshActivityIndicator = [[[UIActivityIndicatorView alloc] 
			initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		[self addSubview:self.refeshActivityIndicator];
		
        self.emailActionsButton = [UIHelper imageButton:@"deleteMsgs.png"
			withSize:buttonSize
			withTarget:self andAction:@selector(actionButtonPressed)];
		[self addSubview:self.emailActionsButton];
		
		NSString *selectAllTitle = LOCALIZED_STR(@"MSGS_ACTION_SELECT_ALL");
		NSString *unselectAllTitle = LOCALIZED_STR(@"MSGS_ACTION_UNSELECT_ALL");
		
		if([AppHelper generatingLaunchScreen])
		{
			selectAllTitle = @"";
			unselectAllTitle = @"";
		}
	
		self.selectAllButton = [UIHelper imageButton:@"msgActionButton.png"
			andSize:actionButtonSize
			withTitle:selectAllTitle 
			andFontSize:ACTION_BUTTON_FONT_SIZE andFontColor:[UIColor whiteColor]
			andTarget:self andAction:@selector(selectAll)];
		[self addSubview:self.selectAllButton];
		
		self.unselectAllButton = [UIHelper imageButton:@"msgActionButton.png" 
		    andSize:actionButtonSize
			withTitle:unselectAllTitle
			andFontSize:ACTION_BUTTON_FONT_SIZE andFontColor:[UIColor whiteColor]
			andTarget:self andAction:@selector(unselectAll)];
		[self addSubview:self.unselectAllButton];
		
		self.refreshMsgsButton = [UIHelper imageButton:@"refresh.png"
			withSize:buttonSize
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
	[numSelectedMsgsLabel release];
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
	[self.delegate deleteMsgsButtonPressed];
}

-(void) refreshMsgs
{
	[[AppHelper theAppDelegate] syncWithServerInBackgroundThread];

}

- (id)initWithFrame:(CGRect)frame
{
	assert(0);
	return 0;
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGFloat currYOffset = EMAIL_ACTION_VIEW_SELECTION_ROW_HEIGHT;
	
	CGFloat centerButtonsWidth = 
		self.selectAllButton.frame.size.width +
		self.unselectAllButton.frame.size.width + 
		ACTION_BUTTON_SPACE;

	CGFloat currXOffset = self.frame.size.width/2.0 - centerButtonsWidth/2.0;
	
	// Layout the 2 center buttons for select and unselect all.		
	CGRect buttonFrame = self.unselectAllButton.frame;
	buttonFrame.origin.x = currXOffset;
	buttonFrame.origin.y = currYOffset + EMAIL_ACTION_VIEW_BUTTON_ROW_VERT_CENTER - buttonFrame.size.height/2.0;
	[self.unselectAllButton setFrame:buttonFrame];
	
	currXOffset += buttonFrame.size.width + ACTION_BUTTON_SPACE;
	
	buttonFrame = self.selectAllButton.frame;
	buttonFrame.origin.x = currXOffset;
	buttonFrame.origin.y = currYOffset + EMAIL_ACTION_VIEW_BUTTON_ROW_VERT_CENTER - buttonFrame.size.height/2.0;
	[self.selectAllButton setFrame:buttonFrame];

	
	// Layout the button for deleting selected/all messages on the RHS of the view		
	buttonFrame = self.emailActionsButton.frame;
	buttonFrame.origin.x = self.frame.size.width - buttonFrame.size.width - EMAIL_ACTION_VIEW_HORIZ_MARGIN;
	buttonFrame.origin.y = EMAIL_ACTION_VIEW_HEIGHT/2.0 - buttonFrame.size.height/2.0;
	[self.emailActionsButton setFrame:buttonFrame];
	
	// Center the selection count above the delete button
	[self.numSelectedMsgsLabel sizeToFit];
	CGRect numMsgsFrame = self.numSelectedMsgsLabel.frame;
	numMsgsFrame.origin.x = buttonFrame.origin.x + buttonFrame.size.width/2.0 -
		numMsgsFrame.size.width/2.0;
	numMsgsFrame.origin.y = 2.0;
	[self.numSelectedMsgsLabel setFrame:numMsgsFrame];



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
	
	currYOffset += EMAIL_ACTION_VIEW_BUTTON_ROW_HEIGHT;

	CGRect statusFrame = self.statusLabel.frame;
	statusFrame.origin.x = 0.0;
	statusFrame.origin.y = currYOffset;
	statusFrame.size.width = self.frame.size.width;
	statusFrame.size.height = EMAIL_ACTION_VIEW_STATUS_ROW_HEIGHT;
	[self.statusLabel setFrame:statusFrame];
		
}

-(void)updateMsgCount:(NSUInteger)selectedMsgCount
{
	if(selectedMsgCount>0)
	{
		self.numSelectedMsgsLabel.text = [NSString stringWithFormat:@"%d",selectedMsgCount];
	}
	else
	{
		self.numSelectedMsgsLabel.text = @"";
	}
	[self.numSelectedMsgsLabel sizeToFit];
}

#pragma mark MailSyncProgressDelegate


-(void)startRefreshIndicator
{
	[self.refeshActivityIndicator setHidden:FALSE];
	[self.refreshMsgsButton setHidden:TRUE];
	[self.refeshActivityIndicator startAnimating];	
	self.statusLabel.text = LOCALIZED_STR(@"MSGS_ACTION_CONNECTING_STATUS");
}

-(void)startingUpdateStatus
{
	self.statusLabel.text = LOCALIZED_STR(@"MSGS_ACTION_UPDATING_STATUS_FORMAT");
}

-(void)stopRefreshIndicator
{
	[self.refeshActivityIndicator setHidden:TRUE];
	[self.refreshMsgsButton setHidden:FALSE];
	[self.refeshActivityIndicator stopAnimating];
	self.statusLabel.text = [self lastUpdatedStatus];
}

-(void)mailServerConnectionStarted
{
	NSLog(@"mail sync started in EmailActionView");
	// The UI updates need to be performedon the main thread.
	[self performSelectorOnMainThread:@selector(startRefreshIndicator) 
		withObject:self waitUntilDone:FALSE];
}

-(void)mailServerConnectionEstablished
{
	[self performSelectorOnMainThread:@selector(startingUpdateStatus) 
		withObject:self waitUntilDone:FALSE];
}

-(void)updateStatusWithPercProgress
{
	self.statusLabel.text = [NSString stringWithFormat:@"%@ (%.0f%%)",
		LOCALIZED_STR(@"MSGS_ACTION_UPDATING_STATUS_FORMAT"),syncProgress*100.0];
}

-(void)updateDeleteStatusWithPercProgress
{
	self.statusLabel.text = [NSString stringWithFormat:@"%@ (%.0f%%)",
		LOCALIZED_STR(@"MSGS_ACTION_DELETING_STATUS_FORMAT"),syncProgress*100.0];
}

-(void)mailSyncUpdateProgress:(CGFloat)percentProgress
{
	syncProgress = percentProgress;
	[self performSelectorOnMainThread:@selector(updateStatusWithPercProgress) 
		withObject:self waitUntilDone:TRUE];
}

-(void)mailDeleteUpdateProgress:(CGFloat)percentProgress
{
	syncProgress = percentProgress;
	[self performSelectorOnMainThread:@selector(updateDeleteStatusWithPercProgress) 
		withObject:self waitUntilDone:TRUE];
}

-(void)updateProgressForTeardown
{
	self.statusLabel.text = LOCALIZED_STR(@"MSGS_ACTION_FINISHING_STATUS_FORMAT");

}

-(void)mailServerConnectionTeardownStarted
{
	[self performSelectorOnMainThread:@selector(updateProgressForTeardown) 
		withObject:self waitUntilDone:FALSE];

}


-(void)mailSyncComplete:(BOOL)successfulCompletion
{
	NSLog(@"mail sync teardown finished in EmailActionView");
	// The UI updates need to be performedon the main thread.
	[self performSelectorOnMainThread:@selector(stopRefreshIndicator) 
		withObject:self waitUntilDone:FALSE];
}

-(void)mailDeleteComplete:(BOOL)completeStatus withCompletionInfo:(MailDeleteCompletionInfo *)mailDeleteCompletionInfo
{
	[self performSelectorOnMainThread:@selector(stopRefreshIndicator) 
		withObject:self waitUntilDone:FALSE];
}

@end
