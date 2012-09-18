//
//  AppDelegate.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GenericFieldBasedTableAddViewController.h"

#import "PasscodeValidator.h"
#import "PasscodeSetter.h"

@class DataModelController;
@class SharedAppVals;
@class MailClientServerSyncController;
@class CompositeMailSyncProgressDelegate;
@class CompositeMailDeleteProgressDelegate;
@class EmailAccountAdder;
@class EmailAccount;

@protocol CurrentEmailAccountChangedListener;

@interface AppDelegate : UIResponder <UIApplicationDelegate,
			GenericTableAddViewSaveCompleteDelegate,PasscodeValidationDelegate,PasscodeSetDelegate>
{
	@private
		DataModelController *appDmc;
		SharedAppVals *sharedAppVals;
		
		EmailAccountAdder *emailAccountAdder;
		
		NSOperationQueue *getBodyOperationQueue;
		
		CompositeMailSyncProgressDelegate *mailSyncProgressDelegates;
		CompositeMailDeleteProgressDelegate *mailDeleteProgressDelegates;
		NSOperationQueue *msgSyncAndDeleteOperationQueue;

		NSOperationQueue *countMessageFilterCountsQueue;
		
		NSMutableSet *accountChangeListers;
		
		UINavigationController *messageListNavController;

		PasscodeValidator *passcodeValidator;
		PasscodeSetter *passcodeSetter;
		
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,retain) UINavigationController *messageListNavController;

@property(nonatomic,retain) PasscodeValidator *passcodeValidator;
@property(nonatomic,retain) PasscodeSetter *passcodeSetter;

@property(nonatomic,retain) DataModelController *appDmc;
@property(nonatomic,retain) SharedAppVals *sharedAppVals;

@property(nonatomic,retain) CompositeMailSyncProgressDelegate *mailSyncProgressDelegates;
@property(nonatomic,retain) CompositeMailDeleteProgressDelegate *mailDeleteProgressDelegates;
@property(nonatomic,retain) NSOperationQueue *msgSyncAndDeleteOperationQueue;


@property(nonatomic,retain) EmailAccountAdder *emailAccountAdder;
@property(nonatomic,retain) NSOperationQueue *getBodyOperationQueue;
@property(nonatomic,retain) NSOperationQueue *countMessageFilterCountsQueue;

@property(nonatomic,retain) NSMutableSet *accountChangeListers;

-(void)updateMessageFilterCountsInBackground;
-(void)deleteMarkedMsgsInBackgroundThread;
-(void)syncWithServerInBackgroundThread;

@end

@protocol CurrentEmailAccountChangedListener <NSObject>
-(void)currentAcctChanged:(EmailAccount*)currentAccount;
@end
