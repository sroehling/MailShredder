//
//  MessageFilterFormInfoCreator.h
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormInfoCreator.h"

@class MessageFilter;


@interface MessageFilterFormInfoCreator : NSObject <FormInfoCreator>
{
	@private
		MessageFilter *msgFilter;
}

@property(nonatomic,retain) MessageFilter *msgFilter;

-(id)initWithMsgFilter:(MessageFilter*)theMsgFilter;

@end
