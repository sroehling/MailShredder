//
//  AppHelper.h
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataModelController;
@class AppDelegate;

@interface AppHelper : NSObject

extern NSString * const APP_DATA_DATA_MODEL_NAME;
extern NSString * const APP_DATA_STORE_NAME;


+(DataModelController*)appDataModelController;
+(AppDelegate*)theAppDelegate;
+(BOOL)generatingLaunchScreen;

@end
