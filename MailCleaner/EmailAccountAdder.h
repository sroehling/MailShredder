//
//  EmailAccountAdder.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
		FormContext *currParentContext;
		ImapAcctPresets *emailAcctPresets;
		id<GenericTableAddViewSaveCompleteDelegate> acctSaveCompleteDelegate;
		GenericFieldBasedTableAddViewController *currentAddViewController;
		
		BOOL promptedForImapServer;
		NSInteger currentStep;
		
		NSOperationQueue *connectionTestQueue;
		MBProgressHUD *connectionTestHUD;
		BOOL connectionTestSucceeded;
		
		EmailAccount *acctBeingAdded;
}

@property(nonatomic,retain) FormContext *currParentContext;
@property(nonatomic,retain) ImapAcctPresets *emailAcctPresets;
@property(nonatomic, assign) id<GenericTableAddViewSaveCompleteDelegate> acctSaveCompleteDelegate; // optional
@property(nonatomic,retain) GenericFieldBasedTableAddViewController *currentAddViewController;

@property(nonatomic,retain) NSOperationQueue *connectionTestQueue;
@property(nonatomic,retain) MBProgressHUD *connectionTestHUD;
@property(nonatomic,retain) EmailAccount *acctBeingAdded;


-(GenericFieldBasedTableAddViewController*)addViewControllerForNewAccountAddr:
	(DataModelController*)dmcForNewAcct;

@end
