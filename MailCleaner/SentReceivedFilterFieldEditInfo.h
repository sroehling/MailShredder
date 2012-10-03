//
//  SentReceivedFilterFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 10/3/12.
//
//

#import <Foundation/Foundation.h>

#import "StaticFieldEditInfo.h"

@class SentReceivedFilter;

@interface SentReceivedFilterFieldEditInfo : StaticFieldEditInfo
{
	@private
		SentReceivedFilter *sentReceivedFilter;
} 

@property(nonatomic,retain) SentReceivedFilter *sentReceivedFilter;


-(id)initWithSentReceivedFilter:(SentReceivedFilter *)theFilter;

@end
