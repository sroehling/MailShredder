//
//  TrashMsgListViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgListTableViewController.h"

@class TrashMsgListViewInfo;

@interface TrashMsgListViewController : MsgListTableViewController
{
	@private
		TrashMsgListViewInfo *viewInfo;
}

@property(nonatomic,retain) TrashMsgListViewInfo *viewInfo;

-(id)initWithViewInfo:(TrashMsgListViewInfo*)theViewInfo;

@end
