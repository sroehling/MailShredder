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

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (void)dealloc
{
	[_window release];
	[_tabBarController release];
    [super dealloc];
}

-(void)populateDatabaseWithDummyEmails
{

	NSString   *path = [[NSBundle mainBundle] pathForResource: @"dummyEmails" ofType: @"txt"];
	NSString *dummyEmailData = [NSString stringWithContentsOfFile:path 
			encoding:NSUTF8StringEncoding error:nil];
	NSArray *lines = [dummyEmailData componentsSeparatedByString:@"\n"];
	
	DataModelController *emailInfoDmc = [AppHelper emailInfoDataModelController];
	
	
	if(![emailInfoDmc entitiesExistForEntityName:EMAIL_INFO_ENTITY_NAME])
	{
		for(NSString *line in lines)
		{
			NSLog(@"email: %@",line);
			NSArray *fields = [line componentsSeparatedByString:@"\t"];
			NSLog(@"Loading dummy email info: D:%@ F:%@ S:%@",[fields objectAtIndex:0],
				[fields objectAtIndex:1],[fields objectAtIndex:2]);
				
			EmailInfo *newEmailInfo = (EmailInfo*) [emailInfoDmc insertObject:EMAIL_INFO_ENTITY_NAME];
			newEmailInfo.sendDate = [DateHelper dateFromStr:[fields objectAtIndex:0]];
			newEmailInfo.from = [fields objectAtIndex:1];
			newEmailInfo.subject = [fields objectAtIndex:2];
		}
		
		[emailInfoDmc saveContext];
	}
	
	NSSet *emailInfos = [emailInfoDmc 
			fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME];
	for(EmailInfo *emailInfo in emailInfos)
	{
		NSLog(@"EmailInfo: D:%@ F:%@ S:%@",[DateHelper stringFromDate:emailInfo.sendDate],
			emailInfo.from,emailInfo.subject);
	}

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{


	[self populateDatabaseWithDummyEmails];
	[SharedAppVals initFromDatabase];


    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
	
	
	DataModelController *emailInfoDmc = [AppHelper emailInfoDataModelController];
	DataModelController *appDmc = [AppHelper appDataModelController];

	
	EmailInfoTableViewController *msgListController = [[[EmailInfoTableViewController alloc] 
		initWithEmailInfoDataModelController:emailInfoDmc andAppDataModelController:appDmc] autorelease];
	UINavigationController *msgListNavController = [[[UINavigationController alloc] 
			initWithRootViewController:msgListController] autorelease];
	msgListNavController.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
	msgListController.title = LOCALIZED_STR(@"MESSAGES_VIEW_TITLE");
//	msgListNavController.tabBarItem.image = [UIImage imageNamed:@"piggy.png"];
//	msgListNavController.navigationBar.tintColor = navBarControllerColor;


	TrashMsgListViewController *trashedMsgsController = [[[TrashMsgListViewController alloc]  
		initWithEmailInfoDataModelController:emailInfoDmc andAppDataModelController:appDmc] autorelease];
	UINavigationController *trashedMsgsNavController = [[[UINavigationController alloc] 
			initWithRootViewController:trashedMsgsController] autorelease];
	trashedMsgsController.title = LOCALIZED_STR(@"TRASH_VIEW_TITLE");
	trashedMsgsNavController.title = LOCALIZED_STR(@"TRASH_VIEW_TITLE");
	
	
	RulesFormInfoCreator *rulesFormInfoCreator = [[[RulesFormInfoCreator alloc] init] autorelease];
	UIViewController *rulesController = [[[GenericFieldBasedTableEditViewController alloc]
		initWithFormInfoCreator:rulesFormInfoCreator 
		andDataModelController:appDmc] autorelease];
	UINavigationController *rulesNavController = [[[UINavigationController alloc] 
			initWithRootViewController:rulesController] autorelease];
	rulesNavController.title = LOCALIZED_STR(@"RULES_VIEW_TITLE");
	rulesNavController.title = LOCALIZED_STR(@"RULES_VIEW_TITLE");

	
	
	self.tabBarController = [[[UITabBarController alloc] init] autorelease];
	self.tabBarController.viewControllers = 
		[NSArray arrayWithObjects:
			msgListNavController, 
			trashedMsgsNavController,
			rulesNavController,
			nil];
	self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
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

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
