//
//  MessageFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AgeFilter;
@class SharedAppVals;

extern NSString * const MESSAGE_FILTER_ENTITY_NAME;
extern NSString * const MESSAGE_FILTER_AGE_FILTER_KEY;

@interface MessageFilter : NSManagedObject

@property (nonatomic, retain) NSString * filterName;
@property (nonatomic, retain) AgeFilter *ageFilter;

// Inverse
@property (nonatomic, retain) SharedAppVals *sharedAppValsMsgListFilter;


-(NSPredicate*)filterPredicate;

@end
