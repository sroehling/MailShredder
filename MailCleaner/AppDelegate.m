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
#import "TrashMsgListViewController.h"
#import "GenericFieldBasedTableEditViewController.h"
#import "SharedAppVals.h"
#import "RulesFormInfoCreator.h"
#import "MailClientServerSyncController.h"
#import "MoreFormInfoCreator.h"
#import "ColorHelper.h"

#import "RuleSelectionListFormInfoCreator.h"

#import "EmailAccount.h"
#import "EmailAccountFormInfoCreator.h"
#import "GenericFieldBasedTableAddViewController.h"


@implementation AppDelegate

@synthesize appDmc;
@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize mailSyncController;

- (void)dealloc
{
	[_window release];
	[_tabBarController release];
	[appDmc release];
	[mailSyncController release];
    [super dealloc];
}

-(void)populateDatabaseWithDummyEmails
{

	NSString   *path = [[NSBundle mainBundle] pathForResource: @"dummyEmails" ofType: @"txt"];
	NSString *dummyEmailData = [NSString stringWithContentsOfFile:path 
			encoding:NSUTF8StringEncoding error:nil];
	NSArray *lines = [dummyEmailData componentsSeparatedByString:@"\n"];
	
	if(![self.appDmc entitiesExistForEntityName:EMAIL_INFO_ENTITY_NAME])
	{
		NSInteger msgNum =0;
		for(NSString *line in lines)
		{
			NSLog(@"email: %@",line);
			NSArray *fields = [line componentsSeparatedByString:@"\t"];
			NSLog(@"Loading dummy email info: D:%@ F:%@ S:%@",[fields objectAtIndex:0],
				[fields objectAtIndex:1],[fields objectAtIndex:2]);
				
			EmailInfo *newEmailInfo = (EmailInfo*) [self.appDmc insertObject:EMAIL_INFO_ENTITY_NAME];
			newEmailInfo.sendDate = [DateHelper dateFromStr:[fields objectAtIndex:0]];
			newEmailInfo.from = [fields objectAtIndex:1];
			newEmailInfo.subject = [fields objectAtIndex:2];
			newEmailInfo.messageId = [NSString stringWithFormat:@"%04d",msgNum];
			msgNum++;
		}
		
		[self.appDmc saveContext];
	}
	
	NSSet *emailInfos = [self.appDmc 
			fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME];
	for(EmailInfo *emailInfo in emailInfos)
	{
		NSLog(@"EmailInfo: D:%@ F:%@ S:%@",[DateHelper stringFromDate:emailInfo.sendDate],
			emailInfo.from,emailInfo.subject);
	}

}

-(void)promptForEmailAcctInfoForDataModelController
{

	EmailAccount *newAcct = [EmailAccount defaultNewEmailAcctWithDataModelController:self.appDmc];	
	
	EmailAccountFormInfoCreator *emailAcctFormInfoCreator = 
		[[[EmailAccountFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];
	
    GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
        initWithFormInfoCreator:emailAcctFormInfoCreator andNewObject:newAcct
		andDataModelController:appDmc] autorelease];
	addView.popDepth = 0;
	addView.showCancelButton = FALSE;
	addView.addCompleteDelegate = self;

	UINavigationController *emailAcctNavController = [[[UINavigationController alloc] 
			initWithRootViewController:addView] autorelease];
	emailAcctNavController.title = LOCALIZED_STR(@"EMAIL_ACCOUNT_VIEW_TITLE");
	emailAcctNavController.navigationBar.tintColor = [ColorHelper navBarTintColor];;	
		
	self.window.rootViewController = emailAcctNavController;
	
    [self.window makeKeyAndVisible];

}

-(void)finishStartupWithDefinedEmailAcctSettings
{
	self.window.rootViewController = self.tabBarController;
	
    [self.window makeKeyAndVisible];
	
	[self.mailSyncController syncWithServerInBackgroundThread];
	
}

-(void)genericAddViewSaveCompleteForObject:(NSManagedObject*)addedObject
{

	assert([addedObject isKindOfClass:[EmailAccount class]]);
	
	SharedAppVals *sharedAppVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	
	// The first account becomes the current email account
	sharedAppVals.currentEmailAcct = (EmailAccount*)addedObject;
	
	[self.appDmc saveContext];
	
	[self finishStartupWithDefinedEmailAcctSettings];

}

-(void)assignFirstEmailAccountToCurrentIfNotSelected
{
	// If the currentEmailAcct isn't set when the first EmailAccount is created, go 
	// ahead and set it here.
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	if(sharedVals.currentEmailAcct == nil)
	{
		NSArray *emailAccounts = [[self.appDmc fetchObjectsForEntityName:EMAIL_ACCOUNT_ENTITY_NAME] allObjects];
		EmailAccount *firstAcct = [emailAccounts objectAtIndex:0];
		assert(firstAcct != nil);
		sharedVals.currentEmailAcct = firstAcct;
		
		[self.appDmc saveContext];
	}
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

//	[self populateDatabaseWithDummyEmails];
	
	[SharedAppVals initFromDatabase];


    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
	
	
	// For the top level DataModelController(actually its underlying NSManagedObjectContext), the
	// merge policy must be set to give priority to external changes. This is accounts for the scenario
	// where changes are made in the separate thread for mail synchronization, but need to be merged
	// back into this thread.
	self.appDmc = [AppHelper appDataModelController];
	[self.appDmc.managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
	
	
	self.mailSyncController = [[[MailClientServerSyncController alloc] 
		initWithMainThreadDataModelController:self.appDmc] autorelease];
	
	
	UIColor *navBarControllerColor = [ColorHelper navBarTintColor];
	
	EmailInfoTableViewController *msgListController = [[[EmailInfoTableViewController alloc] 
		initWithAppDataModelController:appDmc] autorelease];
	UINavigationController *msgListNavController = [[[UINavigationController alloc] 
			initWithRootViewController:msgListController] autorelease];
	msgListNavController.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	msgListController.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
//	msgListNavController.tabBarItem.image = [UIImage imageNamed:@"piggy.png"];
	msgListNavController.navigationBar.tintColor = navBarControllerColor;


	RuleSelectionListFormInfoCreator *ruleSelectionFormInfoCreator = 
		[[[RuleSelectionListFormInfoCreator alloc] init] autorelease];
	UIViewController *trashedRuleSelectionController =
		[[[GenericFieldBasedTableViewController alloc] initWithFormInfoCreator:ruleSelectionFormInfoCreator 
		andDataModelController:self.appDmc] autorelease];
	UINavigationController *trashedRuleSelectionNavController = [[[UINavigationController alloc] 
			initWithRootViewController:trashedRuleSelectionController] autorelease];
	trashedRuleSelectionNavController.title = LOCALIZED_STR(@"TRASH_RULE_LIST_VIEW_TITLE");
	trashedRuleSelectionNavController.navigationBar.tintColor = navBarControllerColor;	

	RulesFormInfoCreator *rulesFormInfoCreator = [[[RulesFormInfoCreator alloc] init] autorelease];
	UIViewController *rulesController = [[[GenericFieldBasedTableEditViewController alloc]
		initWithFormInfoCreator:rulesFormInfoCreator 
		andDataModelController:appDmc] autorelease];
	UINavigationController *rulesNavController = [[[UINavigationController alloc] 
			initWithRootViewController:rulesController] autorelease];
	rulesNavController.title = LOCALIZED_STR(@"RULES_VIEW_TITLE");
	rulesNavController.title = LOCALIZED_STR(@"RULES_VIEW_TITLE");
	rulesNavController.navigationBar.tintColor = navBarControllerColor;	
	
	MoreFormInfoCreator *moreFormInfoCreator = 
		[[[MoreFormInfoCreator alloc] init] autorelease];
	UIViewController *moreViewController = [[[GenericFieldBasedTableViewController alloc]
		initWithFormInfoCreator:moreFormInfoCreator andDataModelController:appDmc] autorelease];
	UINavigationController *moreNavController = [[[UINavigationController alloc] initWithRootViewController:moreViewController] autorelease];
	moreNavController.title = LOCALIZED_STR(@"MORE_VIEW_TITLE");
	moreNavController.tabBarItem = [[[UITabBarItem alloc] 
		initWithTabBarSystemItem:UITabBarSystemItemMore tag:0] autorelease];
	moreNavController.navigationBar.tintColor = navBarControllerColor;	

	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	self.tabBarController.viewControllers = 
		[NSArray arrayWithObjects:
			msgListNavController, 
			trashedRuleSelectionNavController,
			rulesNavController,
			moreNavController,
			nil];

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
