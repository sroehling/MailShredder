//
//  EmailAccountAdder.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAccountAdder.h"
#import "EmailAccountFormInfoCreator.h"
#import "BasicEmailAccountFormInfoCreator.h"
#import "GenericFieldBasedTableAddViewController.h"
#import "FormContext.h"
#import "EmailAccount.h"
#import "LocalizationHelper.h"
#import "DataModelController.h"
#import "MailAddressHelper.h"
#import "ImapAcctPreset.h"
#import "ImapAcctPresets.h"
#import "FullEmailAccountFormInfoCreator.h"
#import "IMAPServerEmailAccountFormInfoCreator.h"


NSInteger const ADD_EMAIL_ACCOUNT_STEP_PROMPT_BASIC_INFO = 0;
NSInteger const ADD_EMAIL_ACCOUNT_STEP_PROMPT_IMAP = 1;
NSInteger const ADD_EMAIL_ACCOUNT_STEP_CONFIRM_FULL_SETTINGS = 2;

@implementation EmailAccountAdder

@synthesize currParentContext;
@synthesize acctSaveCompleteDelegate;
@synthesize emailAcctPresets;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.emailAcctPresets = [[[ImapAcctPresets alloc] init] autorelease];
	}
	return self;
}

-(GenericFieldBasedTableAddViewController*)addViewControllerForNextStep:
	(EmailAccountFormInfoCreator*)emailAcctFormInfoCreator
	withinDataModelController:(DataModelController*)dmcForNewAcct
	andPopDepth:(NSInteger)popDepth
{

	GenericFieldBasedTableAddViewController *addViewController =  
		[[[GenericFieldBasedTableAddViewController alloc] 
			initWithFormInfoCreator:emailAcctFormInfoCreator 
			andNewObject:emailAcctFormInfoCreator.emailAccount
			andDataModelController:dmcForNewAcct] autorelease];

	addViewController.saveButtonTitle = 
		LOCALIZED_STR(@"EMAIL_ACCOUNT_EMAIL_ADDRESS_SAVE_BUTTON_TITLE");
	addViewController.addCompleteDelegate = self;
	addViewController.popDepth = popDepth;
	addViewController.popControllerOnSave = FALSE;
	addViewController.saveWhenSaveButtonPressed = FALSE;
	
	return addViewController;

}

-(GenericFieldBasedTableAddViewController*)addViewControllerForNewAccountAddr:
	(DataModelController*)dmcForNewAcct
{
	EmailAccount *newAcct = [EmailAccount 
		defaultNewEmailAcctWithDataModelController:dmcForNewAcct];
	currentStep = ADD_EMAIL_ACCOUNT_STEP_PROMPT_BASIC_INFO;
	
	BasicEmailAccountFormInfoCreator *basicAcctFormInfoCreator = 
		[[[BasicEmailAccountFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];
	
	GenericFieldBasedTableAddViewController *basicInfoAddView = 
		[self addViewControllerForNextStep:basicAcctFormInfoCreator
			withinDataModelController:dmcForNewAcct andPopDepth:1];
		
	return basicInfoAddView;

}


-(void)addObjectFromTableView:(FormContext*)parentContext
{

	// This is the first callback when the user presses the "+" button
	// to add a new view.
	NSLog(@"Adding email account");
		
	self.currParentContext = parentContext;	
		
	GenericFieldBasedTableAddViewController *basicInfoAddView = 
		[self addViewControllerForNewAccountAddr:parentContext.dataModelController];
	
	[self.currParentContext.parentController.navigationController
		pushViewController:basicInfoAddView animated:TRUE];

}

-(BOOL)supportsAddOutsideEditMode
{
	return FALSE;
}

-(void)populateAcctWithPresetsAfterBasicInfoEntered:(EmailAccount*)newAcct
{

	NSString *newAcctDomain = [MailAddressHelper emailAddressDomainName:newAcct.emailAddress];
	ImapAcctPreset *presetForDomain = [self.emailAcctPresets 
		findPresetWithDomainName:newAcctDomain];
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
			newAcct.userName = [MailAddressHelper
				emailAddressUserName:newAcct.emailAddress];

		}
	}
}

-(void)populateAcctWithPresetsAfterIMAPServerEntered:(EmailAccount*)newAcct
{
	ImapAcctPreset *presetForImapServer = [self.emailAcctPresets 
		findPresetWithImapHostName:newAcct.imapServer];
	if(presetForImapServer != nil)
	{
		newAcct.portNumber = [NSNumber numberWithInt:presetForImapServer.portNum];
		newAcct.useSSL = [NSNumber numberWithBool:presetForImapServer.useSSL];
		if(presetForImapServer.fullEmailIsUserName)
		{
			newAcct.userName = newAcct.emailAddress;
		}
		else 
		{
			newAcct.userName = [MailAddressHelper 
				emailAddressUserName:newAcct.emailAddress];

		}
	}
}

-(void)showImapServerForm:(EmailAccount*)newAcct
{
	IMAPServerEmailAccountFormInfoCreator *imapServerFormInfoCreator = 
		[[[IMAPServerEmailAccountFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];
	GenericFieldBasedTableAddViewController *imapServerAddView = 
		[self addViewControllerForNextStep:imapServerFormInfoCreator
			withinDataModelController:self.currParentContext.dataModelController andPopDepth:2];

	currentStep = ADD_EMAIL_ACCOUNT_STEP_PROMPT_IMAP;
	
	[self.currParentContext.parentController.navigationController
		pushViewController:imapServerAddView animated:TRUE];
}

-(void)showFullEmailAccountForm:(EmailAccount*)newAcct withPopDepth:(NSInteger)popDepth
{
	FullEmailAccountFormInfoCreator *emailAcctFormInfoCreator = 
		[[[FullEmailAccountFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];
	
	GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
		initWithFormInfoCreator:emailAcctFormInfoCreator andNewObject:newAcct
		andDataModelController:self.currParentContext.dataModelController] autorelease];
	addView.saveWhenSaveButtonPressed = TRUE;
	
	if(self.acctSaveCompleteDelegate != nil)
	{
		addView.addCompleteDelegate = self.acctSaveCompleteDelegate;
		addView.popDepth = 0;
		addView.showCancelButton = FALSE;
	}
	else
	{
		addView.popDepth = popDepth;
	}

	currentStep = ADD_EMAIL_ACCOUNT_STEP_CONFIRM_FULL_SETTINGS;

	[self.currParentContext.parentController.navigationController
		pushViewController:addView animated:TRUE];
}


-(void)genericAddViewSaveCompleteForObject:(NSManagedObject*)addedObject
{
	// This callback is invoked when the Next button is invoked on the first
	// "basic info" or IMAP server form
	assert(self.currParentContext != nil);
	assert([addedObject isKindOfClass:[EmailAccount class]]);
	EmailAccount *newAcct = (EmailAccount*)addedObject;
	
	if(currentStep == ADD_EMAIL_ACCOUNT_STEP_PROMPT_BASIC_INFO)
	{
		[self populateAcctWithPresetsAfterBasicInfoEntered:newAcct];
		if(newAcct.imapServer != nil)
		{
			[self showFullEmailAccountForm:newAcct withPopDepth:2];
		}
		else {
			[self showImapServerForm:newAcct];
		}
	}
	else if(currentStep == ADD_EMAIL_ACCOUNT_STEP_PROMPT_IMAP)
	{
		[self populateAcctWithPresetsAfterIMAPServerEntered:newAcct];
		[self showFullEmailAccountForm:newAcct withPopDepth:3];
	}
	else 
	{
		assert(0); // should not get here
	}
}

-(void)dealloc
{
	[currParentContext release];
	[emailAcctPresets release];
	[super dealloc];
}

@end
