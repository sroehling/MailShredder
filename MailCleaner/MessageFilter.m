//
//  MessageFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilter.h"
#import "AgeFilter.h"

NSString * const MESSAGE_FILTER_ENTITY_NAME = @"MessageFilter";
NSString * const MESSAGE_FILTER_AGE_FILTER_KEY = @"ageFilter";

@implementation MessageFilter

@dynamic filterName;
@dynamic ageFilter;

// Inverse
@dynamic sharedAppValsMsgListFilter;


@end
