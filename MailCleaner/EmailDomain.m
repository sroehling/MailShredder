//
//  EmailDomain.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailDomain.h"

NSString * const EMAIL_DOMAIN_ENTITY_NAME = @"EmailDomain";

@implementation EmailDomain

@dynamic domainName;


// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;


@end
