//
//  SavedMessageFilterTableMenuItem.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SavedMessageFilterTableMenuItem.h"
#import "MessageFilter.h"

@implementation SavedMessageFilterTableMenuItem

@synthesize selectionDelegate;
@synthesize messageFilter;

-(void)savedFilterMenuItemSelected
{
	[self.selectionDelegate savedMessagFilterSelectedFromMenu:self.messageFilter];
}

-(id)initWithMessageFilter:(MessageFilter*)theMessageFilter 
	andFilterSelectedDelegate:(id<SavedMessageFilterTableMenuItemSelectedDelegate>)theSelectionDelegate
{
	NSInteger matchingMessages = [theMessageFilter.matchingMsgs integerValue];
	NSString *filterNameWithCount = [NSString stringWithFormat:@"%@ (%d)",
		theMessageFilter.filterName,[theMessageFilter.matchingMsgs integerValue]];

	BOOL filterMatchesMessages = matchingMessages>0?TRUE:FALSE;

	self = [super initWithTitle:filterNameWithCount
		andTarget:self andSelector:@selector(savedFilterMenuItemSelected)
		andEnabled:filterMatchesMessages];
	if(self)
	{
		self.messageFilter = theMessageFilter;
		self.selectionDelegate = theSelectionDelegate;
	}
	return self;
}

-(void)dealloc
{
	[messageFilter release];
	[super dealloc];
}

@end
