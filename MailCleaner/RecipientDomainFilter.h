//
//  RecipientDomainFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 10/2/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EmailDomainFilter.h"

@class MessageFilter;

extern NSString * const RECIPIENT_DOMAIN_FILTER_ENTITY_NAME;


@interface RecipientDomainFilter : EmailDomainFilter

@property (nonatomic, retain) MessageFilter *messageFilterRecipientDomainFilter;

@end
