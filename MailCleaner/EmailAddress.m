//
//  EmailAddress.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddress.h"


NSString * const EMAIL_ADDRESS_ENTITY_NAME = @"EmailAddress";

@implementation EmailAddress

@dynamic address;
@dynamic name;
@dynamic selectedAddressEmailAddress;

// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;


@end
