//
//  DeleteRule.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MsgHandlingRule.h"

extern NSString * const TRASH_RULE_ENTITY_NAME;

@class DataModelController;

@interface TrashRule : MsgHandlingRule


+(TrashRule*)createNewDefaultRule:(DataModelController*)dmcForNewRule;


@end
