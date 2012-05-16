//
//  AppHelper.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppHelper.h"

#import "DataModelController.h"

@implementation AppHelper

+(DataModelController*)emailInfoDataModelController
{
	DataModelController *emailInfoDmc = 
		[[[DataModelController alloc] 
			initForDatabaseUsageWithDataModelNamed:@"EmailInfo"
			andStoreNamed:@"EmailInfo.sqlite"] autorelease];
	return emailInfoDmc;
}


@end
