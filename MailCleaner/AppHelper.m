//
//  AppHelper.m
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "AppHelper.h"

#import "DataModelController.h"
#import "AppDelegate.h"

NSString * const APP_DATA_DATA_MODEL_NAME = @"AppData";
NSString * const APP_DATA_STORE_NAME = @"AppData.sqlite";
NSString * const MAIL_SHREDDER_APP_ID = @"572539748";

@implementation AppHelper


+(DataModelController*)appDataModelController
{
	DataModelController *appDmc = 
		[[[DataModelController alloc] 
			initForDatabaseUsageWithDataModelNamed:APP_DATA_DATA_MODEL_NAME
			andStoreNamed:APP_DATA_STORE_NAME] autorelease];
	return appDmc;
}

+(AppDelegate*)theAppDelegate
{
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	assert(appDelegate != nil);
	return appDelegate;	
}

+(BOOL)generatingLaunchScreen
{
	// To (re)generate the launch screens, temporarily
	// return TRUE, then copy the screens from the
	// screens from the simulator.
	return FALSE;
}


@end
