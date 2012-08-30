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
@class EmailAccount;

@protocol CurrentEmailAccountChangedListener;

@interface AppDelegate : UIResponder <UIApplicationDelegate,
			GenericTableAddViewSaveCompleteDelegate>
{
	@private
		DataModelController *appDmc;
		SharedAppVals *sharedAppVals;
		MailClientServerSyncController *mailSyncController;
		CompositeMailSyncProgressDelegate *mailSyncProgressDelegates;
		EmailAccountAdder *emailAccountAdder;
		NSOperationQueue *getBodyOperationQueue;
		
		NSMutableSet *accountChangeListers;
		
		UINavigationController *messageListNavController;
		
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,retain) UINavigationController *messageListNavController;

@property(nonatomic,retain) DataModelController *appDmc;
@property(nonatomic,retain) SharedAppVals *sharedAppVals;
@property(nonatomic,retain) MailClientServerSyncController *mailSyncController;
@property(nonatomic,retain) CompositeMailSyncProgressDelegate *mailSyncProgressDelegates;
@property(nonatomic,retain) EmailAccountAdder *emailAccountAdder;
@property(nonatomic,retain) NSOperationQueue *getBodyOperationQueue;

@property(nonatomic,retain) NSMutableSet *accountChangeListers;

@end

@protocol CurrentEmailAccountChangedListener <NSObject>
-(void)currentAcctChanged:(EmailAccount*)currentAccount;
@end
