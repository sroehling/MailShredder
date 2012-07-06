//
//  MessageFilterFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormInfoCreator.h"
#import "SingleButtonTableFooter.h"

@class MessageFilter;


@interface MessageFilterFormInfoCreator : NSObject <FormInfoCreator>
{
	@private
		MessageFilter *msgFilter;
}

@property(nonatomic,retain) MessageFilter *msgFilter;

-(id)initWithMsgFilter:(MessageFilter*)theMsgFilter;

@end
