//
//  ExclusionRuleFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormInfoCreator.h"

@class ExclusionRule;

@interface ExclusionRuleFormInfoCreator : NSObject <FormInfoCreator> {
	@private
		ExclusionRule *rule;
}

@property(nonatomic,retain) ExclusionRule *rule;

-(id)initWithExclusionRule:(ExclusionRule*)theRule;

@end