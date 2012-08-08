//
//  AppDelegate.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericFieldBasedTableAddViewController.h"

@class DataModelController;
@class MailClientServerSyncController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,
			GenericTableAddViewSaveCompleteDelegate>
{
	@private
		DataModelController *appDmc;
		MailClientServerSyncController *mailSyncController;
		
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property(nonatomic,retain) DataModelController *appDmc;
@property(nonatomic,retain) MailClientServerSyncController *mailSyncController;

@end
