//
//  PortNumberValidator.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PortNumberValidator.h"
#import "NumberFieldValidator.h"
#import "LocalizationHelper.h"

@implementation PortNumberValidator

- (id)init
{
	self = [super initWithValidationMsg:LOCALIZED_STR(@"EMAIL_ACCOUNT_PORTNUM_VALIDATION_MSG")];
	return self;
}

-(BOOL)validateNumber:(NSNumber *)theNumber
{
	assert(theNumber != nil);
	if([theNumber integerValue] > 0)
	{
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}


@end
