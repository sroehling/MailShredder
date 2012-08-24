//
//  EmailAcctFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAcctFieldEditInfo.h"
#import "EmailAccount.h"
#import "EmailAccountFormInfoCreator.h"
#import "DataModelController.h"
#import "SharedAppVals.h"
#import "LocalizationHelper.h"

@implementation EmailAcctFieldEditInfo

@synthesize emailAcct;
@synthesize appDmc;

@class EmailAccount;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct andAppDmc:(DataModelController*)theAppDmc
{
	EmailAccountFormInfoCreator *emailAcctFormInfoCreator = [[[EmailAccountFormInfoCreator alloc] 
			initWithEmailAcct:theEmailAcct] autorelease];

	self = [super initWithCaption:theEmailAcct.acctName andSubtitle:theEmailAcct.emailAddress 
		andContentDescription:@"" andSubFormInfoCreator:emailAcctFormInfoCreator];
	if(self)
	{
	
		assert(theAppDmc != nil);
		assert(theEmailAcct != nil);
	
		self.emailAcct = theEmailAcct;
		self.appDmc = theAppDmc;
	}
	return self;
}

- (NSManagedObject*) managedObject
{
    return self.emailAcct;
}

- (BOOL)isSelected
{
	assert(self.emailAcct != nil);
	return self.emailAcct.isSelectedForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	assert(self.emailAcct != nil);
	self.emailAcct.isSelectedForSelectableObjectTableView = isSelected;
}

-(BOOL)supportsDelete
{
	NSArray *emailAccounts = [[self.appDmc fetchObjectsForEntityName:EMAIL_ACCOUNT_ENTITY_NAME] allObjects];
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.appDmc];
	if(([emailAccounts count] > 1) && (sharedVals.currentEmailAcct != self.emailAcct))
	{
		return TRUE;
	}
	else 
	{
		return FALSE;
	}
}

-(void)deleteObject:(DataModelController *)dataModelController
{
	NSLog(@"Deleting acct: %@",self.emailAcct.acctName);
	[self.appDmc deleteObject:self.emailAcct];
	[self.appDmc saveContext];
}

-(void)deleteWithConfirmation:(DataModelController *)dataModelController 
	andConfirmationDelegate:(id<FieldEditInfoDeleteConfirmationDelegate>)theDeleteConfirmationDelegate
{
	assert(theDeleteConfirmationDelegate != nil);
	deleteConfirmationDelegate = theDeleteConfirmationDelegate;
	
	UIAlertView *confirmDeleteAcctAlert = [[[UIAlertView alloc] initWithTitle:
			LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_ALERT_TITLE")
		message:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_ALERT_BODY") delegate:self 
		cancelButtonTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_ALERT_CANCEL_BUTTON_TITLE") 
		otherButtonTitles:nil] autorelease];
	[confirmDeleteAcctAlert addButtonWithTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_DELETE_ALERT_DELETE_BUTTON_TITLE")];
	[confirmDeleteAcctAlert show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"Alert view dismissed: buton index = %d",buttonIndex);
	if(alertView.cancelButtonIndex != buttonIndex)
	{
		[deleteConfirmationDelegate deleteConfirmed:self];
	}
}



-(void)dealloc
{
	[emailAcct release];
	[super dealloc];
}

@end
