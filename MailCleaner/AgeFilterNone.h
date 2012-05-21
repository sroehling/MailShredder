//
//  AgeFilterNone.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AgeFilter.h"

extern NSString * const AGE_FILTER_NONE_ENTITY_NAME;

@class SharedAppVals;

@interface AgeFilterNone : AgeFilter

// Inverse
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultAgeFilterNone;


@end
