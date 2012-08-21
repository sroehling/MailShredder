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
@class SharedAppVals;
@class MailClientServerSyncController;
@class CompositeMailSyncProgressDelegate;
@class EmailAccountAdder;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,
			GenericTableAddViewSaveCompleteDelegate>
{
	@private
		DataModelController *appDmc;
		SharedAppVals *sharedAppVals;
		MailClientServerSyncController *mailSyncController;
		CompositeMailSyncProgressDelegate *mailSyncProgressDelegates;
		EmailAccountAdder *emailAccountAdder;
		
		
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property(nonatomic,retain) DataModelController *appDmc;
@property(nonatomic,retain) SharedAppVals *sharedAppVals;
@property(nonatomic,retain) MailClientServerSyncController *mailSyncController;
@property(nonatomic,retain) CompositeMailSyncProgressDelegate *mailSyncProgressDelegates;
@property(nonatomic,retain) EmailAccountAdder *emailAccountAdder;

@end
