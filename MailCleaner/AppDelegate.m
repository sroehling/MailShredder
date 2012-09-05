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
#import "MailClientServerSyncController.h"
#import "MoreFormInfoCreator.h"
#import "ColorHelper.h"

#import "CompositeMailSyncProgressDelegate.h"

#import "EmailAccount.h"
#import "EmailAccountFormInfoCreator.h"
#import "GenericFieldBasedTableAddViewController.h"
#import "EmailAccountAdder.h"
#import "FormContext.h"
#import "MessageFilterCountOperation.h"

@implementation AppDelegate

@synthesize appDmc;
@synthesize window = _window;
@synthesize mailSyncController;
@synthesize mailSyncProgressDelegates;
@synthesize sharedAppVals;
@synthesize emailAccountAdder;
@synthesize getBodyOperationQueue;
@synthesize accountChangeListers;
@synthesize messageListNavController;
@synthesize countMessageFilterCountsQueue;

- (void)dealloc
{
	[_window release];
	[messageListNavController release];
	[appDmc release];
	[mailSyncController release];
	[mailSyncProgressDelegates release];
	[sharedAppVals release];
	[emailAccountAdder release];
	[getBodyOperationQueue release];
	[accountChangeListers release];
	[countMessageFilterCountsQueue release];
    [super dealloc];
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
				[self.mailSyncController syncWithServerInBackgroundThread];
				
				for(id<CurrentEmailAccountChangedListener> acctChangeListener 
					in self.accountChangeListers)
				{
					[acctChangeListener currentAcctChanged:newAcct];
				}
			}
		}


    }
}

-(void)finishStartupWithDefinedEmailAcctSettings
{
	self.window.rootViewController = self.messageListNavController;
	
    [self.window makeKeyAndVisible];
	
	[self.mailSyncController syncWithServerInBackgroundThread];
	
	// If the currently selected email account changes, then update re-sync the email
	// messages.
	[self.sharedAppVals addObserver:self forKeyPath:SHARED_APP_VALS_CURRENT_EMAIL_ACCOUNT_KEY 
			options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
	
}

-(void)genericAddViewSaveCompleteForObject:(NSManagedObject*)addedObject
{

	assert([addedObject isKindOfClass:[EmailAccount class]]);
		
	// The first account becomes the current email account
	self.sharedAppVals.currentEmailAcct = (EmailAccount*)addedObject;
	
	[self.appDmc saveContext];
	
	[self finishStartupWithDefinedEmailAcctSettings];

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
	
	
	self.mailSyncProgressDelegates = [[[CompositeMailSyncProgressDelegate alloc] init] autorelease];
	self.mailSyncController = [[[MailClientServerSyncController alloc] 
		initWithMainThreadDataModelController:self.appDmc
		andProgressDelegate:self.mailSyncProgressDelegates] autorelease];
		
	self.getBodyOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
	self.countMessageFilterCountsQueue = [[[NSOperationQueue alloc] init] autorelease];

	
	EmailInfoTableViewController *msgListController = [[[EmailInfoTableViewController alloc] 
		initWithAppDataModelController:appDmc] autorelease];
	UINavigationController *msgListNavController = [[[UINavigationController alloc] 
			initWithRootViewController:msgListController] autorelease];
	msgListNavController.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	msgListController.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	msgListNavController.navigationBar.tintColor = [ColorHelper navBarTintColor];
		
	self.messageListNavController = msgListNavController;	
		
	if(![appDmc entitiesExistForEntityName:EMAIL_ACCOUNT_ENTITY_NAME])
	{
		[self promptForEmailAcctInfoForDataModelController];
	}
	else 
	{
		[self assignFirstEmailAccountToCurrentIfNotSelected];
		
		[self finishStartupWithDefinedEmailAcctSettings];

	}
	
	return YES;
}

-(void)updateMessageFilterCountsInBackground
{
	MessageFilterCountOperation *countMsgsOperation = 
		[[[MessageFilterCountOperation alloc] initWithMainThreadDmc:self.appDmc 
		andEmailAccount:self.sharedAppVals.currentEmailAcct] autorelease];
	[self.countMessageFilterCountsQueue addOperation:countMsgsOperation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
