//
//  ExclusionRule.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MsgHandlingRule.h"

@class DataModelController;

extern NSString * const EXCLUSION_RULE_ENTITY_NAME;

@interface ExclusionRule : MsgHandlingRule

+(ExclusionRule*)createNewDefaultRule:(DataModelController*)dmcForNewRule;

@end
