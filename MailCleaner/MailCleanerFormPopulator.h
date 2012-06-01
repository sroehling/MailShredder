//
//  MailCleanerFormPopulator.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FormPopulator.h"

@class MsgHandlingRule;

@interface MailCleanerFormPopulator : FormPopulator

-(void)populateAgeFilterInParentObj:(NSManagedObject*)parentObj
	withAgeFilterPropertyKey:(NSString*)ageFilterKey;

-(void)populateRuleEnabled:(MsgHandlingRule*)theRule withSubtitle:(NSString*)subTitle;

@end
