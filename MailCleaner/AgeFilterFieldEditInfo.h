//
//  AgeFilterFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StaticFieldEditInfo.h"

@class AgeFilter;

@interface AgeFilterFieldEditInfo : StaticFieldEditInfo {
	@private
		AgeFilter *ageFilter;
}

@property(nonatomic,retain) AgeFilter *ageFilter;

-(id)initWithAgeFilter:(AgeFilter *)theAgeFilter andCaption:(NSString *)theCaption andContent:(NSString *)theContent
	andSubtitle:(NSString*)theSubtitle;

@end
