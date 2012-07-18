//
//  TrashMsgListViewFactory.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GenericTableViewFactory.h"

@class TrashMsgListViewInfo;

@interface TrashMsgListViewFactory : NSObject <GenericTableViewFactory>
{
	@private
		TrashMsgListViewInfo *viewInfo;
}

@property(nonatomic,retain) TrashMsgListViewInfo *viewInfo;

-(id)initWithViewInfo:(TrashMsgListViewInfo*)theViewInfo;

@end
