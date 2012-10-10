//
//  MsgListView.m
//
//  Created by Steve Roehling on 5/29/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MsgListView.h"
#import "EmailInfoActionView.h"
#import "UIHelper.h"
#import "LocalizationHelper.h"
#import "AppHelper.h"

static CGFloat const MSG_LIST_LOAD_MORE_BUTTON_FONT = 13.0f;
static CGFloat const MSG_LIST_LOAD_MORE_BUTTON_MARGIN = 5.0f;

static CGFloat const MSG_LIST_LOAD_MORE_LABEL_HEIGHT = 20.0f;
static CGFloat const MSG_LIST_LOAD_MORE_BUTTON_HEIGHT = 25.0f;
static CGFloat const MSG_LIST_LOAD_MORE_FOOTER_HEIGHT = 50.0f;

@implementation MsgListView

@synthesize msgListTableView;
@synthesize msgListActionFooter;
@synthesize headerView;
@synthesize loadMoreMsgsTableFooter;
@synthesize loadMoreStatusLabel;
@synthesize loadMoreButton;

@synthesize delegate;

-(void)loadMoreMsgs
{
	assert(self.delegate != nil);
	[self.delegate msgListViewLoadMoreMessagesButtonPressed];
	NSLog(@"Load more messages");
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		
		self.backgroundColor = [UIColor lightGrayColor];
		
		self.msgListTableView = [[[UITableView alloc] initWithFrame:CGRectZero 
				style:UITableViewStylePlain] autorelease];
		self.msgListTableView.allowsSelection = TRUE;
		self.msgListTableView.allowsMultipleSelection = TRUE;
		[self addSubview:self.msgListTableView];
		
		// Setup a footer view for the table with a "show more"
		// messages button and summary of messages shown.
		self.loadMoreStatusLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.loadMoreStatusLabel.textAlignment = UITextAlignmentCenter;
		self.loadMoreStatusLabel.font = [UIFont systemFontOfSize:11.0f];
		self.loadMoreStatusLabel.textColor = [UIColor darkGrayColor];
		self.loadMoreStatusLabel.numberOfLines = 1;
		self.loadMoreStatusLabel.backgroundColor = [UIColor clearColor];
		self.loadMoreStatusLabel.opaque = NO;
		[self.loadMoreStatusLabel setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-(2 * MSG_LIST_LOAD_MORE_BUTTON_MARGIN), MSG_LIST_LOAD_MORE_LABEL_HEIGHT)];
		
		self.loadMoreButton = [UIHelper buttonWithBackgroundColor:[UIColor lightGrayColor]
		andTitleColor:[UIColor whiteColor]
		andTarget:self andAction:@selector(loadMoreMsgs)
			andTitle:LOCALIZED_STR(@"MESSAGE_LIST_LOAD_MORE_MESSAGES_BUTTON_TITLE")
		andFontSize:MSG_LIST_LOAD_MORE_BUTTON_FONT];

		CGRect buttonFrame = CGRectMake(MSG_LIST_LOAD_MORE_BUTTON_MARGIN, MSG_LIST_LOAD_MORE_LABEL_HEIGHT,
			[UIScreen mainScreen].bounds.size.width-(2 * MSG_LIST_LOAD_MORE_BUTTON_MARGIN),
			MSG_LIST_LOAD_MORE_BUTTON_HEIGHT);
		[loadMoreButton setFrame:buttonFrame];
		
		self.loadMoreMsgsTableFooter = [[[UIView alloc] initWithFrame:CGRectMake(0,0,
			[UIScreen mainScreen].bounds.size.width,MSG_LIST_LOAD_MORE_FOOTER_HEIGHT)] autorelease];
		[self.loadMoreMsgsTableFooter addSubview:self.loadMoreStatusLabel];
		[self.loadMoreMsgsTableFooter addSubview:self.loadMoreButton];
		
		if([AppHelper generatingLaunchScreen])
		{
			self.loadMoreMsgsTableFooter.hidden = TRUE;
		}

		
		self.msgListTableView.tableFooterView = self.loadMoreMsgsTableFooter;

		self.msgListActionFooter = [[[EmailInfoActionView alloc] init] autorelease];
		[self addSubview:self.msgListActionFooter];
		


    }
    return self;
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect actionFooterFrame = self.msgListActionFooter.frame;
	actionFooterFrame.origin.x = 0;
	actionFooterFrame.origin.y = self.frame.size.height - EMAIL_ACTION_VIEW_HEIGHT;
	actionFooterFrame.size.width = self.frame.size.width;
	actionFooterFrame.size.height = EMAIL_ACTION_VIEW_HEIGHT;
	[self.msgListActionFooter setFrame:actionFooterFrame];
	
	CGFloat headerHeight = 0.0;
	if(self.headerView != nil)
	{
		CGRect headerFrame = self.headerView.frame;
		headerHeight = headerFrame.size.height;
		headerFrame.origin.x = 0;
		headerFrame.origin.y = 0;
		headerFrame.size.width = self.frame.size.width;
		[headerView setFrame:headerFrame];
	}
	
	CGRect tableFrame = self.msgListTableView.frame;
	tableFrame.origin.x = 0;
	tableFrame.origin.y = headerHeight;
	tableFrame.size.width = self.frame.size.width;
	tableFrame.size.height = self.frame.size.height - EMAIL_ACTION_VIEW_HEIGHT - headerHeight;
	[self.msgListTableView setFrame:tableFrame];

}

-(void)updateLoadedMessageCount:(NSUInteger)msgsLoaded
	andTotalMessageCount:(NSUInteger)totalMessageCount
{
	NSLog(@"MsgListView: Update message counts: loaded %d of total %d", msgsLoaded,totalMessageCount);
	if(totalMessageCount == 0)
	{
		self.loadMoreStatusLabel.text = LOCALIZED_STR(@"MESSAGE_LIST_LOAD_NO_MATCHING_STATUS");
		self.loadMoreButton.hidden = TRUE;
	}
	else if(msgsLoaded < totalMessageCount)
	{
		self.loadMoreStatusLabel.text = [NSString stringWithFormat:LOCALIZED_STR(@"MESSAGE_LIST_LOAD_FIRST_STATUS_FORMAT"),
			msgsLoaded,totalMessageCount];
		self.loadMoreButton.hidden = FALSE;
	}
	else
	{
		self.loadMoreStatusLabel.text = [NSString stringWithFormat:LOCALIZED_STR(@"MESSAGE_LIST_LOAD_ALL_STATUS_FORMAT"),
			totalMessageCount];
		self.loadMoreButton.hidden = TRUE;
	}
}

-(void)dealloc
{
	[msgListActionFooter release];
	[msgListTableView release];
	[loadMoreMsgsTableFooter release];
	[loadMoreStatusLabel release];
	[loadMoreButton release];
	[super dealloc];
}


@end
