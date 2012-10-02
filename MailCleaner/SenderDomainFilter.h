//
//  SenderDomainFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 10/2/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EmailDomainFilter.h"

@class MessageFilter;

extern NSString * const SENDER_DOMAIN_FILTER_ENTITY_NAME;


@interface SenderDomainFilter : EmailDomainFilter

@property (nonatomic, retain) MessageFilter *messageFilterSenderDomainFilter;

@end
