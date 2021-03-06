//
//  ReadFilterFieldEditInfo.h
//
//  Created by Steve Roehling on 9/12/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StaticFieldEditInfo.h"
@class ReadFilter;

@interface ReadFilterFieldEditInfo : StaticFieldEditInfo
{
	@private
		ReadFilter *readFilter;
} 

@property(nonatomic,retain) ReadFilter *readFilter;

-(id)initWithReadFilter:(ReadFilter *)theReadFilter;

@end
