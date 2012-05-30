//
//  MsgListView.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgListView.h"
#import "EmailInfoActionView.h"

@implementation MsgListView

@synthesize msgListTableView;
@synthesize msgListActionFooter;
@synthesize headerView;

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

-(void)dealloc
{
	[msgListActionFooter release];
	[msgListTableView release];
	[super dealloc];
}


@end
