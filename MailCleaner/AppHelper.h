//
//  AppHelper.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataModelController;

@interface AppHelper : NSObject

extern NSString * const EMAIL_INFO_DATA_MODEL_NAME;
extern NSString * const EMAIL_INFO_STORE_NAME;
extern NSString * const APP_DATA_DATA_MODEL_NAME;
extern NSString * const APP_DATA_STORE_NAME;


+(DataModelController*)emailInfoDataModelController;
+(DataModelController*)appDataModelController;


@end
