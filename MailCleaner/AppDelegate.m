//
//  AppDelegate.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "LocalizationHelper.h"

#import "DataModelController.h"
#import "AppHelper.h"
#import "DateHelper.h"
#import "EmailInfo.h"
#import "EmailInfoTableViewController.h"
#import "GenericFieldBasedTableEditViewController.h"
#import "SharedAppVals.h"
#import "MoreFormInfoCreator.h"
#import "ColorHelper.h"

#import "PasscodeHelper.h"
#import "PTPasscodeViewController.h"

#import "CompositeMailSyncProgressDelegate.h"

#import "EmailAccount.h"
#import "EmailAccountFormInfoCreator.h"
#import "GenericFieldBasedTableAddViewController.h"
#import "EmailAccountAdder.h"
#import "FormContext.h"
#import "MessageFilterCountOperation.h"
#import "MailSyncConnectionContext.h"
#import "MailSyncOperation.h"
#import "CompositeMailDeleteProgressDelegate.h"

@implementation AppDelegate

@synthesize appDmc;
@synthesize window = _window;
@synthesize mailSyncProgressDelegates;
@synthesize sharedAppVals;
@synthesize emailAccountAdder;
@synthesize getBodyOperationQueue;
@synthesize accountChangeListers;
@synthesize messageListNavController;
@synthesize countMessageFilterCountsQueue;
@synthesize msgSyncAndDeleteOperationQueue;
@synthesize mailDeleteProgressDelegates;
@synthesize passcodeValidator;
@synthesize passcodeSetter;

- (void)dealloc
{
	[_window release];
	[messageListNavController release];
	[appDmc release];
	[mailSyncProgressDelegates release];
	[sharedAppVals release];
	[emailAccountAdder release];
	[getBodyOperationQueue release];
	[accountChangeListers release];
	[countMessageFilterCountsQueue release];
	[msgSyncAndDeleteOperationQueue release];
	[mailDeleteProgressDelegates release];
	[passcodeValidator release];
	[passcodeSetter release];
    [super dealloc];
}

////////////////////////////////////////////////////////////////
// The following methods are for startup screens to prompt for 
// email account information and passcode verification. There
// can be up 2 views shown before the regular message is shown:
// 1. If no email account is defined, prompt for email account
//    information.
// 2. If passcode protection is enabled, prompt for the passcode.
// 3. Set the root view to the message list and synchronize
//    the messages.
////////////////////////////////////////////////////////////////


-(void)genericAddViewSaveCompleteForObject:(NSManagedObject*)addedObject
{
	// Called after an email account is specified.
	assert([addedObject isKindOfClass:[EmailAccount class]]);
		
	// The first account becomes the current email account
	self.sharedAppVals.currentEmailAcct = (EmailAccount*)addedObject;
	
	[self.appDmc saveContext];
	
	if ([self passcodeViewPromptNeeded])
	{
		[self showPasscodeView];
	}
	else 
	{
		[self finishStartupWithDefinedEmailAcctSettings];
	}	
}

-(void)promptForEmailAcctInfoForDataModelController
{
    GenericFieldBasedTableAddViewController *addView = 
		[self.emailAccountAdder addViewControllerForNewAccountAddr:self.appDmc];
	addView.popDepth = 0;
	addView.showCancelButton = FALSE;
	
	// Setup self.emailAccountAddr so it uses addView as the parent view controller
	// when the final form for the account settings is presented. Also setup
	// self.emailAccountAddr so it calls the delegate method when the final save is complete.
	FormContext *parentContext = [[[FormContext alloc] 
		initWithParentController:addView andDataModelController:self.appDmc] autorelease];
	self.emailAccountAdder.currParentContext = parentContext;
	self.emailAccountAdder.acctSaveCompleteDelegate = self;

	UINavigationController *emailAcctNavController = [[[UINavigationController alloc] 
			initWithRootViewController:addView] autorelease];
	emailAcctNavController.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_VIEW_TITLE");
	emailAcctNavController.navigationBar.tintColor = [ColorHelper navBarTintColor];;	
		
	self.window.rootViewController = emailAcctNavController;	
    [self.window makeKeyAndVisible];
}

-(void)passcodeSet
{
	[self finishStartupWithDefinedEmailAcctSettings];
}

-(void)passcodeValidated
{
	[self finishStartupWithDefinedEmailAcctSettings];
}

-(BOOL)passcodeViewPromptNeeded
{
	if(![PasscodeHelper passcodeHasBeenSetAtLeastOnce])
	{
		// The app has just launched for the first time
		// and we need to set the passcode by default.
		return TRUE;
	}
	else if ( [PasscodeHelper passcodeIsEnabled])
	{
		// The user has kept the passcode enabled,
		// so we need to prompt for it.
		return TRUE;
	}
	else
	{
		return FALSE;
	}
}


-(void)showPasscodeView
{
	id<PTPasscodeViewControllerDelegate> passcodeDelegate;
	
	if([PasscodeHelper passcodeHasBeenSetAtLeastOnce])
	{
		passcodeDelegate = self.passcodeValidator;
	}
	else 
	{
		passcodeDelegate = self.passcodeSetter;
	}

	PTPasscodeViewController *passcodeViewController = 
		[[[PTPasscodeViewController alloc] initWithDelegate:passcodeDelegate] autorelease];
	UINavigationController *passcodeNavController = [[[UINavigationController alloc]
		   initWithRootViewController:passcodeViewController] autorelease];

	self.window.rootViewController = passcodeNavController;
    [self.window makeKeyAndVisible];

}

-(void)assignFirstEmailAccountToCurrentIfNotSelected
{
	// If the currentEmailAcct isn't set when the first EmailAccount is created, go 
	// ahead and set it here.
	if(self.sharedAppVals.currentEmailAcct == nil)
	{
		NSArray *emailAccounts = [[self.appDmc fetchObjectsForEntityName:EMAIL_ACCOUNT_ENTITY_NAME] allObjects];
		EmailAccount *firstAcct = [emailAccounts objectAtIndex:0];
		assert(firstAcct != nil);
		self.sharedAppVals.currentEmailAcct = firstAcct;
		
		[self.appDmc saveContext];
	}
}


-(void)finishStartupWithDefinedEmailAcctSettings
{
	[self assignFirstEmailAccountToCurrentIfNotSelected];

	self.window.rootViewController = self.messageListNavController;	
    [self.window makeKeyAndVisible];

	// If the currently selected email account changes, then update re-sync the email
	// messages.
	[self.sharedAppVals addObserver:self forKeyPath:SHARED_APP_VALS_CURRENT_EMAIL_ACCOUNT_KEY 
			options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
}



-(void)configStartingViewController
{
	if(![appDmc entitiesExistForEntityName:EMAIL_ACCOUNT_ENTITY_NAME])
	{
		[self promptForEmailAcctInfoForDataModelController];
	}
	else if ([self passcodeViewPromptNeeded])
	{
		[self showPasscodeView];
	}
	else 
	{
		[self finishStartupWithDefinedEmailAcctSettings];
	}

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[SharedAppVals initFromDatabase];

	self.emailAccountAdder = [[[EmailAccountAdder alloc] init] autorelease];
	
	self.accountChangeListers = [[[NSMutableSet alloc] init] autorelease];
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
	
	// For the top level DataModelController(actually its underlying NSManagedObjectContext), the
	// merge policy must be set to give priority to external changes. This is accounts for the scenario
	// where changes are made in the separate thread for mail synchronization, but need to be merged
	// back into this thread.
	self.appDmc = [AppHelper appDataModelController];
	self.sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	[self.appDmc.managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
	
		
	self.getBodyOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
	self.mailSyncProgressDelegates = [[[CompositeMailSyncProgressDelegate alloc] init] autorelease];
	self.mailDeleteProgressDelegates = [[[CompositeMailDeleteProgressDelegate alloc] init] autorelease];
	self.msgSyncAndDeleteOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
	
	self.countMessageFilterCountsQueue = [[[NSOperationQueue alloc] init] autorelease];


	NSString *msgViewTitle = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	if([AppHelper generatingLaunchScreen])
	{
		msgViewTitle = @" ";
	}
	
	EmailInfoTableViewController *msgListController = [[[EmailInfoTableViewController alloc] 
		initWithAppDataModelController:appDmc] autorelease];
	UINavigationController *msgListNavController = [[[UINavigationController alloc] 
			initWithRootViewController:msgListController] autorelease];
	msgListNavController.title = msgViewTitle;
	msgListController.title = msgViewTitle;
	msgListNavController.navigationBar.tintColor = [ColorHelper navBarTintColor];
		
	self.messageListNavController = msgListNavController;
	
	self.passcodeValidator = [[[PasscodeValidator alloc] initWithDelegate:self] autorelease];
	self.passcodeSetter = [[[PasscodeSetter alloc] initWithDelegate:self] autorelease];

	return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	 [self configStartingViewController];
}


////////////////////////////////////////////////////////////////
// The methods below support global, background operations for 
// message synchronization, updating message filter counts,
// and message deletion.
////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:SHARED_APP_VALS_CURRENT_EMAIL_ACCOUNT_KEY]) 
	{
		NSNumber *changeKind = (NSNumber*)[change objectForKey:NSKeyValueChangeKindKey];
		if([changeKind integerValue] == NSKeyValueChangeSetting)
		{
			EmailAccount *oldAcct = (EmailAccount*)[change objectForKey:NSKeyValueChangeOldKey];
			EmailAccount *newAcct = (EmailAccount*)[change objectForKey:NSKeyValueChangeNewKey];
			if(oldAcct != newAcct)
			{
				NSLog(@"Current email account changed: Synchronizing messages");
				[self syncWithServerInBackgroundThread];
				
				for(id<CurrentEmailAccountChangedListener> acctChangeListener 
					in self.accountChangeListers)
				{
					[acctChangeListener currentAcctChanged:newAcct];
				}
			}
		}
    }
}


-(void)updateMessageFilterCountsInBackground
{
	MessageFilterCountOperation *countMsgsOperation = 
		[[[MessageFilterCountOperation alloc] initWithMainThreadDmc:self.appDmc 
		andEmailAccount:self.sharedAppVals.currentEmailAcct] autorelease];
	[self.countMessageFilterCountsQueue addOperation:countMsgsOperation];
}

-(void)syncWithServerInBackgroundThread
{
	MailSyncConnectionContext *syncConnectionContext = [[[MailSyncConnectionContext alloc]
		initWithMainThreadDmc:self.appDmc
		andProgressDelegate:self.mailSyncProgressDelegates] autorelease];
		
	[self.msgSyncAndDeleteOperationQueue addOperation:[[[MailSyncOperation alloc]  
		initWithConnectionContext:syncConnectionContext andProgressDelegate:self.mailSyncProgressDelegates] autorelease]];
}


-(void)deleteMarkedMsgsInBackgroundThread
{

	MailSyncConnectionContext *syncConnectionContext = [[[MailSyncConnectionContext alloc]
		initWithMainThreadDmc:self.appDmc
		andProgressDelegate:self.mailDeleteProgressDelegates] autorelease];
		
	[self.msgSyncAndDeleteOperationQueue addOperation:[[[MailDeleteOperation alloc]  
		initWithConnectionContext:syncConnectionContext andProgressDelegate:self.mailDeleteProgressDelegates] autorelease]];

}

@end
