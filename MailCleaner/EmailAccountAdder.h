//
//  EmailAccountAdder.h
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TableViewObjectAdder.h"
#import "GenericFieldBasedTableAddViewController.h"
//#import "NewAcctConnectionTestProgressDelegate.h"
#import "MBProgressHUD.h"

@class FormContext;
@class ImapAcctPresets;
@class EmailAccount;

@interface EmailAccountAdder : NSObject <TableViewObjectAdder,
		GenericTableAddViewSaveCompleteDelegate,MBProgressHUDDelegate>
{
	@private
		UINavigationController *currentNavController;
		
		// EmailAccounts are created in their own NSManagedObjectContext
		// (wrapped by dmcForNewAcct).
		DataModelController *dmcForNewAcct;
		
		ImapAcctPresets *emailAcctPresets;
		id<GenericTableAddViewSaveCompleteDelegate> acctSaveCompleteDelegate;
		GenericFieldBasedTableAddViewController *currentAddViewController;
		
		BOOL promptedForImapServer;
		BOOL entryProgressBasicInfoComplete; // account name, email address, password
		BOOL entryProgressServerInfoComplete; // SSL, port number, user name
		NSInteger currentStep;
		NSInteger currentPopDepth;
		
		NSOperationQueue *connectionTestQueue;
		MBProgressHUD *connectionTestHUD;
		BOOL connectionTestSucceeded;
		
		EmailAccount *acctBeingAdded;
}

@property(nonatomic,retain) FormContext *currParentContext;
@property(nonatomic,retain) UINavigationController *currentNavController;

@property(nonatomic,retain) DataModelController *dmcForNewAcct;


@property(nonatomic,retain) ImapAcctPresets *emailAcctPresets;
@property(nonatomic, assign) id<GenericTableAddViewSaveCompleteDelegate> acctSaveCompleteDelegate; // optional
@property(nonatomic,retain) GenericFieldBasedTableAddViewController *currentAddViewController;

@property(nonatomic,retain) NSOperationQueue *connectionTestQueue;
@property(nonatomic,retain) MBProgressHUD *connectionTestHUD;
@property(nonatomic,retain) EmailAccount *acctBeingAdded;

-(void)promptForNewAccountInfo:(UINavigationController*)navController;

@end
