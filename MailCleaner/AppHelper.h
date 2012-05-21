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

+(DataModelController*)emailInfoDataModelController;
+(DataModelController*)appDataModelController;


@end
