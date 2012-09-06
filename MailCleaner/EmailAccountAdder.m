//
//  EmailAccountAdder.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAccountAdder.h"
#import "EmailAccountFormInfoCreator.h"
#import "EmailAddrFormInfoCreator.h"
#import "GenericFieldBasedTableAddViewController.h"
#import "FormContext.h"
#import "EmailAccount.h"
#import "LocalizationHelper.h"
#import "DataModelController.h"
#import "MailAddressHelper.h"
#import "ImapAcctPreset.h"
#import "ImapAcctPresets.h"
#import "FullEmailAccountFormInfoCreator.h"

@implementation EmailAccountAdder

@synthesize currParentContext;
@synthesize acctSaveCompleteDelegate;


-(GenericFieldBasedTableAddViewController*)addViewControllerForNewAccountAddr:
	(DataModelController*)dmcForNewAcct
{
	EmailAccount *newAcct = [EmailAccount 
		defaultNewEmailAcctWithDataModelController:dmcForNewAcct];
	
	EmailAddrFormInfoCreator *emailAddrFormInfoCreator = 
		[[[EmailAddrFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];
	
	GenericFieldBasedTableAddViewController *emailAddressAddView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
        initWithFormInfoCreator:emailAddrFormInfoCreator andNewObject:newAcct
		andDataModelController:dmcForNewAcct] autorelease];
	emailAddressAddView.saveButtonTitle	= LOCALIZED_STR(@"EMAIL_ACCOUNT_EMAIL_ADDRESS_SAVE_BUTTON_TITLE");
	emailAddressAddView.addCompleteDelegate = self;
	emailAddressAddView.popDepth = 1;
	emailAddressAddView.popControllerOnSave = FALSE;
	emailAddressAddView.saveWhenSaveButtonPressed = FALSE;
	
	return emailAddressAddView;

}

-(void)addObjectFromTableView:(FormContext*)parentContext
{

	NSLog(@"Adding email account");
		
	self.currParentContext = parentContext;	
	
	GenericFieldBasedTableAddViewController *emailAddressAddView = 
		[self addViewControllerForNewAccountAddr:parentContext.dataModelController];
	
	[self.currParentContext.parentController.navigationController
		pushViewController:emailAddressAddView animated:TRUE];

	
}

-(BOOL)supportsAddOutsideEditMode
{
	return FALSE;
}

-(void)populateAcctWithPresets:(EmailAccount*)newAcct
{

	ImapAcctPresets *emailAcctPresets = [[[ImapAcctPresets alloc] init] autorelease];
	NSString *newAcctDomain = [MailAddressHelper emailAddressDomainName:newAcct.emailAddress];
	ImapAcctPreset *presetForDomain = [emailAcctPresets findPresetWithDomainName:newAcctDomain];
	if(presetForDomain != nil)
	{
		newAcct.portNumber = [NSNumber numberWithInt:presetForDomain.portNum];
		newAcct.useSSL = [NSNumber numberWithBool:presetForDomain.useSSL];
		newAcct.imapServer = presetForDomain.imapServer;
		
		if(presetForDomain.fullEmailIsUserName)
		{
			newAcct.userName = newAcct.emailAddress;
		}
		else 
		{
			newAcct.userName = [MailAddressHelper emailAddressUserName:newAcct.emailAddress];

		}
	} 
}


-(void)genericAddViewSaveCompleteForObject:(NSManagedObject*)addedObject
{

	assert([addedObject isKindOfClass:[EmailAccount class]]);
	EmailAccount *newAcct = (EmailAccount*)addedObject;
	
	[self populateAcctWithPresets:newAcct];
	
	assert(self.currParentContext != nil);

	FullEmailAccountFormInfoCreator *emailAcctFormInfoCreator = 
		[[[FullEmailAccountFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];
	
    GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
        initWithFormInfoCreator:emailAcctFormInfoCreator andNewObject:newAcct
		andDataModelController:self.currParentContext.dataModelController] autorelease];
		
	if(self.acctSaveCompleteDelegate != nil)
	{
		addView.addCompleteDelegate = self.acctSaveCompleteDelegate;
		addView.popDepth = 0;
		addView.showCancelButton = FALSE;
	}
	else
	{
		addView.popDepth = 2;
	}

	[self.currParentContext.parentController.navigationController
		pushViewController:addView animated:TRUE];

}

-(void)dealloc
{
	[currParentContext release];
	[super dealloc];
}

@end
