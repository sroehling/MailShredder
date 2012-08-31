//
//  DeleteRuleFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageFilter;

#import "FormInfoCreator.h"

@interface SavedMessageFilterFormInfoCreator : NSObject <FormInfoCreator> {
	@private
		MessageFilter *messageFilter;
}

@property(nonatomic,retain) MessageFilter *messageFilter;

-(id)initWithMessageFilter:(MessageFilter*)theMessageFilter;

@end