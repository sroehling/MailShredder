//
//  AppHelper.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppHelper.h"

#import "DataModelController.h"

NSString * const EMAIL_INFO_DATA_MODEL_NAME = @"EmailInfo";
NSString * const EMAIL_INFO_STORE_NAME = @"EmailInfo.sqlite";
NSString * const APP_DATA_DATA_MODEL_NAME = @"AppData";
NSString * const APP_DATA_STORE_NAME = @"AppData.sqlite";

@implementation AppHelper

+(DataModelController*)emailInfoDataModelController
{
	DataModelController *emailInfoDmc = 
		[[[DataModelController alloc] 
			initForDatabaseUsageWithDataModelNamed:EMAIL_INFO_DATA_MODEL_NAME
			andStoreNamed:EMAIL_INFO_STORE_NAME] autorelease];
	return emailInfoDmc;
}


+(DataModelController*)appDataModelController
{
	DataModelController *appDmc = 
		[[[DataModelController alloc] 
			initForDatabaseUsageWithDataModelNamed:APP_DATA_DATA_MODEL_NAME
			andStoreNamed:APP_DATA_STORE_NAME] autorelease];
	return appDmc;
}


@end
