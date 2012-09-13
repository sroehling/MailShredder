//
//  StarredFilterFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StaticFieldEditInfo.h"

@class StarredFilter;

@interface StarredFilterFieldEditInfo : StaticFieldEditInfo
{
	@private
		StarredFilter *starredFilter;
} 

@property(nonatomic,retain) StarredFilter *starredFilter;

-(id)initWithStarredFilter:(StarredFilter *)theStarredFilter;

@end