//
//  DeleteRuleFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrashRule;

#import "FormInfoCreator.h"

@interface TrashRuleFormInfoCreator : NSObject <FormInfoCreator> {
	@private
		TrashRule *rule;
}

@property(nonatomic,retain) TrashRule *rule;

-(id)initWithTrashRule:(TrashRule*)theRule;

@end