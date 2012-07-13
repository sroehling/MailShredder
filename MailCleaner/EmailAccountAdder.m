//
//  EmailAccountAdder.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAccountAdder.h"
#import "EmailAccountFormInfoCreator.h"
#import "GenericFieldBasedTableAddViewController.h"
#import "FormContext.h"
#import "EmailAccount.h"
#import "DataModelController.h"

@implementation EmailAccountAdder

-(void)addObjectFromTableView:(FormContext*)parentContext
{

	NSLog(@"Adding email account");
		
	EmailAccount *newAcct = [parentContext.dataModelController insertObject:EMAIL_ACCOUNT_ENTITY_NAME];
	newAcct.portNumber = [NSNumber numberWithInt:143];
	newAcct.useSSL = [NSNumber numberWithBool:FALSE];
	
	EmailAccountFormInfoCreator *emailAcctFormInfoCreator = 
		[[[EmailAccountFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];
	
    GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
        initWithFormInfoCreator:emailAcctFormInfoCreator andNewObject:newAcct
		andDataModelController:parentContext.dataModelController] autorelease];
	addView.popDepth = 1;

	[parentContext.parentController.navigationController
		pushViewController:addView animated:TRUE];
	
}

-(BOOL)supportsAddOutsideEditMode
{
	return FALSE;
}

@end
