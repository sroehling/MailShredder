//
//  SavedMessageFilterTableMenuItem.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableMenuItem.h"

@class MessageFilter;
@protocol SavedMessageFilterTableMenuItemSelectedDelegate;

@interface SavedMessageFilterTableMenuItem : TableMenuItem
{
	@private
		id<SavedMessageFilterTableMenuItemSelectedDelegate> selectionDelegate;
		MessageFilter *messageFilter;
}

@property(nonatomic,assign) id<SavedMessageFilterTableMenuItemSelectedDelegate> selectionDelegate;
@property(nonatomic,retain) MessageFilter *messageFilter;

-(id)initWithMessageFilter:(MessageFilter*)theMessageFilter 
	andFilterSelectedDelegate:(id<SavedMessageFilterTableMenuItemSelectedDelegate>)theSelectionDelegate;

@end


@protocol SavedMessageFilterTableMenuItemSelectedDelegate <NSObject>

-(void)savedMessagFilterSelectedFromMenu:(MessageFilter*)selectedFilter;

@end