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
#import "ConfirmAcctLoginSettingsEmailAcctFormInfoCreator.h"
#import "DeleteSettingsEmailAccountFormInfoCreator.h"
#import "KeychainFieldInfo.h"
#import "EmailFolder.h"


NSInteger const ADD_EMAIL_ACCOUNT_STEP_PROMPT_BASIC_INFO = 0;
NSInteger const ADD_EMAIL_ACCOUNT_STEP_PROMPT_IMAP = 1;
NSInteger const ADD_EMAIL_ACCOUNT_STEP_CONFIRM_ACCT_SETTINGS = 2;
NSInteger const ADD_EMAIL_ACCOUNT_STEP_MESSAGE_DELETE_SETTINGS = 3;

@implementation EmailAccountAdder

@synthesize currParentContext;
@synthesize acctSaveCompleteDelegate;
@synthesize emailAcctPresets;
@synthesize connectionTestQueue;
@synthesize connectionTestHUD;
@synthesize acctBeingAdded;
@synthesize currentAddViewController;

-(void)dealloc
{
	[currParentContext release];
	[emailAcctPresets release];
	[connectionTestQueue release];
	[acctBeingAdded release];
	[connectionTestHUD release];
	[currentAddViewController release];
	[super dealloc];
}

-(id)init
{
	self = [super init];
	if(self)
	{
		self.emailAcctPresets = [[[ImapAcctPresets alloc] init] autorelease];
		self.connectionTestQueue = [[[NSOperationQueue alloc] init] autorelease];
	}
	return self;
}

-(GenericFieldBasedTableAddViewController*)addViewControllerForNextStep:
	(EmailAccountFormInfoCreator*)emailAcctFormInfoCreator
	withinDataModelController:(DataModelController*)dmcForNewAcct
{

	GenericFieldBasedTableAddViewController *addViewController =  
		[[[GenericFieldBasedTableAddViewController alloc] 
			initWithFormInfoCreator:emailAcctFormInfoCreator 
			andNewObject:emailAcctFormInfoCreator.emailAccount
			andDataModelController:dmcForNewAcct] autorelease];

	addViewController.saveButtonTitle = 
		LOCALIZED_STR(@"EMAIL_ACCOUNT_EMAIL_ADDRESS_SAVE_BUTTON_TITLE");
	addViewController.addCompleteDelegate = self;
	addViewController.popControllerOnSave = FALSE;
	addViewController.saveWhenSaveButtonPressed = FALSE;
	addViewController.teardownFormFieldsWithSave = FALSE;
	
	self.currentAddViewController = addViewController;
	
	return addViewController;

}

-(GenericFieldBasedTableAddViewController*)addViewControllerForNewAccountAddr:
	(DataModelController*)dmcForNewAcct
{
	self.acctBeingAdded = [EmailAccount 
		defaultNewEmailAcctWithDataModelController:dmcForNewAcct];
	currentStep = ADD_EMAIL_ACCOUNT_STEP_PROMPT_BASIC_INFO;
	
	BasicEmailAccountFormInfoCreator *basicAcctFormInfoCreator = 
		[[[BasicEmailAccountFormInfoCreator alloc] initWithEmailAcct:self.acctBeingAdded] autorelease];
	
	GenericFieldBasedTableAddViewController *basicInfoAddView = 
		[self addViewControllerForNextStep:basicAcctFormInfoCreator
			withinDataModelController:dmcForNewAcct];
		
	return basicInfoAddView;

}

-(void)advanceToNextForm:(GenericFieldBasedTableAddViewController*)nextStepViewController
	withNextStepNumber:(NSInteger)nextStepNum
{
	if(self.currentAddViewController != nil)
	{
		// Instead of tearing down the form fields immediately when the save button is pressed, 
		// wait until we actually push the view controller for the next. This 
		// accounts for the scenario where a connection test must be performed before 
		// advancing to the next form.
		[self.currentAddViewController tearDownFormFields];
	}

	currentPopDepth ++;
	self.currentAddViewController = nextStepViewController;
	self.currentAddViewController.popDepth = currentPopDepth;

	currentStep = nextStepNum;
	
	[self.currParentContext.parentController.navigationController
		pushViewController:nextStepViewController animated:TRUE];

}


-(void)addObjectFromTableView:(FormContext*)parentContext
{
	// This is the first callback when the user presses the "+" button
	// to add a new view.
	NSLog(@"Adding email account");
		
	self.currParentContext = parentContext;	
	promptedForImapServer = FALSE;
	entryProgressBasicInfoComplete = FALSE;
	entryProgressServerInfoComplete = FALSE;
	currentPopDepth = 0;
		
	GenericFieldBasedTableAddViewController *basicInfoAddView = 
		[self addViewControllerForNewAccountAddr:parentContext.dataModelController];

	[self advanceToNextForm:basicInfoAddView withNextStepNumber:ADD_EMAIL_ACCOUNT_STEP_PROMPT_BASIC_INFO];
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
		newAcct.deleteHandlingDeleteMsg = [NSNumber numberWithBool:presetForDomain.immediatelyDeleteMsg];
		
		if(presetForDomain.fullEmailIsUserName)
		{
			newAcct.userName = newAcct.emailAddress;
		}
		else 
		{
			newAcct.userName = [MailAddressHelper
				emailAddressUserName:newAcct.emailAddress];

		}
		entryProgressServerInfoComplete = TRUE;
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
		newAcct.deleteHandlingDeleteMsg = [NSNumber numberWithBool:presetForImapServer.immediatelyDeleteMsg];
		if(presetForImapServer.fullEmailIsUserName)
		{
			newAcct.userName = newAcct.emailAddress;
		}
		else 
		{
			newAcct.userName = [MailAddressHelper 
				emailAddressUserName:newAcct.emailAddress];

		}
		entryProgressServerInfoComplete = TRUE;
	}
	else
	{
		// Always default the user name to the full email address
		// This can be changed if the user needs to.
		// With entryProgressServerInfoComplete not set to TRUE,
		// the form will transition to show the full account settings
		// before doing a connection test.
		newAcct.userName = newAcct.emailAddress;
	}
}

-(void)populateAcctWithDefaultSyncFolder:(EmailAccount*)newAcct andPreset:(ImapAcctPreset*)acctPreset
{
	for(NSString *defaultSyncFolderName in acctPreset.defaultSyncFolders)
	{
		for(EmailFolder *acctFolder in newAcct.foldersInAcct)
		{
			if([defaultSyncFolderName isEqualToString:acctFolder.folderName])
			{
				[newAcct addOnlySyncFoldersObject:acctFolder];
				if(acctPreset.matchFirstDefaultSyncFolder)
				{
					// If the matchFirstDefaultSyncFolder is TRUE,
					// only setup the 1st matching folder as a default synchronization folder.
					// Otherwise, match any matching folders.
					return;
				}
			}
		}
	}
}

-(void)populateAcctWithDefaultTrashFolder:(EmailAccount*)newAcct andPreset:(ImapAcctPreset*)acctPreset
{
	for(NSString *defaultTrashFolderName in acctPreset.defaultTrashFolders)
	{
		for(EmailFolder *acctFolder in newAcct.foldersInAcct)
		{
			if([defaultTrashFolderName isEqualToString:acctFolder.folderName])
			{
				newAcct.deleteHandlingMoveToFolder = acctFolder;
				return;
			}
		}
	}
}


-(void)populateAcctWithDefaultDeleteSettingsAfterFetchingFolders:(EmailAccount*)newAcct
{
	ImapAcctPreset *presetForImapServer = [self.emailAcctPresets 
		findPresetWithImapHostName:newAcct.imapServer];
	if(presetForImapServer != nil)
	{
		[self populateAcctWithDefaultSyncFolder:newAcct andPreset:presetForImapServer];
		[self populateAcctWithDefaultTrashFolder:newAcct andPreset:presetForImapServer];
	}

}

-(void)showFormForNextStep:(EmailAccountFormInfoCreator*)nextStepFormInfoCreator 
	andNextStepNumber:(NSInteger)nextStepNum
{
	GenericFieldBasedTableAddViewController *nextStepAddView = 
		[self addViewControllerForNextStep:nextStepFormInfoCreator
			withinDataModelController:self.currParentContext.dataModelController];

	[self advanceToNextForm:nextStepAddView withNextStepNumber:nextStepNum];

}

-(void)showImapServerForm:(EmailAccount*)newAcct
{
	IMAPServerEmailAccountFormInfoCreator *imapServerFormInfoCreator = 
		[[[IMAPServerEmailAccountFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];
		
	promptedForImapServer = TRUE;
		
	[self showFormForNextStep:imapServerFormInfoCreator 
		andNextStepNumber:ADD_EMAIL_ACCOUNT_STEP_PROMPT_IMAP];
}

-(void)showConfirmSettingsForm:(EmailAccount*)newAcct
{
	ConfirmAcctLoginSettingsEmailAcctFormInfoCreator *confirmAcctFormInfoCreator = 
		[[[ConfirmAcctLoginSettingsEmailAcctFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];

	[self showFormForNextStep:confirmAcctFormInfoCreator
		andNextStepNumber:ADD_EMAIL_ACCOUNT_STEP_CONFIRM_ACCT_SETTINGS];
}

-(void)showMessageDeletionSettingsForm:(EmailAccount*)newAcct
{
	DeleteSettingsEmailAccountFormInfoCreator *emailAcctFormInfoCreator = 
		[[[DeleteSettingsEmailAccountFormInfoCreator alloc] initWithEmailAcct:newAcct] autorelease];
	
	GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
		initWithFormInfoCreator:emailAcctFormInfoCreator andNewObject:newAcct
		andDataModelController:self.currParentContext.dataModelController] autorelease];
	addView.saveWhenSaveButtonPressed = TRUE;
	
	if(self.acctSaveCompleteDelegate != nil)
	{
		addView.addCompleteDelegate = self.acctSaveCompleteDelegate;
		addView.showCancelButton = FALSE;
	}
	
	[self advanceToNextForm:addView withNextStepNumber:ADD_EMAIL_ACCOUNT_STEP_MESSAGE_DELETE_SETTINGS];

}

-(void)showConnectionFailedAlert
{
	UIAlertView *syncFailedAlert = [[[UIAlertView alloc] initWithTitle:
			LOCALIZED_STR(@"EMAIL_ACCOUNT_CONNECTION_TEST_FAILURE_ALERT_TITLE")
		message:LOCALIZED_STR(@"EMAIL_ACCOUNT_CONNECTION_TEST_FAILURE_ALERT_MSG") delegate:self 
		cancelButtonTitle:LOCALIZED_STR(@"EMAIL_ACCOUNT_CONNECTION_TEST_FAILURE_ALERT_BUTTON_TITLE") 
		otherButtonTitles:nil] autorelease];
	[syncFailedAlert show];
}


-(void)doConnectionTest
{
	NSLog(@"Doing connection test");

	self.connectionTestHUD.labelText = 
		LOCALIZED_STR(@"EMAIL_ACCOUNT_CONNECTION_TEST_STATUS_TESTING_CONNECTION");
	[NSThread sleepForTimeInterval:0.75];

	CTCoreAccount *mailAcct = [[CTCoreAccount alloc] init];
	int connectionType = [self.acctBeingAdded.useSSL boolValue]?
		CONNECTION_TYPE_TLS:CONNECTION_TYPE_PLAIN;
	
	KeychainFieldInfo *passwordFieldInfo = [self.acctBeingAdded  passwordFieldInfo];
	NSString *password = (NSString*)[passwordFieldInfo getFieldValue];
	
	NSLog(@"Mail connection: server=%@, login=%@, pass=<hidden>",
		self.acctBeingAdded.imapServer,
		self.acctBeingAdded.userName);
		
	@try {
		BOOL connectionSucceeded = [mailAcct connectToServer:self.acctBeingAdded.imapServer 
			port:[self.acctBeingAdded.portNumber intValue]
			connectionType:connectionType
			authType:IMAP_AUTH_TYPE_PLAIN 
			login:self.acctBeingAdded.userName
			password:password];
		if(connectionSucceeded)
		{
			self.connectionTestHUD.labelText = 
				LOCALIZED_STR(@"EMAIL_ACCOUNT_CONNECTION_TEST_STATUS_CONNECTION_ESTABLISHED");
			[NSThread sleepForTimeInterval:0.5];
		
			self.connectionTestHUD.labelText = @"Retrieving Folder List";
			[NSThread sleepForTimeInterval:0.5];
			@autoreleasepool 
			{
				NSSet *allFoldersOnServer = [mailAcct allFolders];
				NSMutableDictionary *currFoldersByName = [self.acctBeingAdded foldersByName];
				for (NSString *folderName in allFoldersOnServer)
				{
					CTCoreFolder *currFolder = [mailAcct folderWithPath:folderName];
					NSLog(@"NewAcctConnectTestOperation: Getting folder: %@",currFolder.path);
					[EmailFolder findOrAddFolder:currFolder.path inExistingFolders:currFoldersByName 
						withDataModelController:self.currParentContext.dataModelController andFolderAcct:self.acctBeingAdded]; 
				}
			}

			self.connectionTestHUD.labelText = 
				LOCALIZED_STR(@"EMAIL_ACCOUNT_CONNECTION_TEST_STATUS_TEST_SUCCEEDED");
			[NSThread sleepForTimeInterval:0.5];
			
			[mailAcct disconnect];
			connectionTestSucceeded = TRUE;
		}
		else {
			connectionTestSucceeded = FALSE;
		}
	}
	@catch (NSException *exception) 
	{
		connectionTestSucceeded = FALSE;
	}
	@finally {
		[mailAcct release];
	}

	NSLog(@"Doing connection test");
}


-(void)startAcctConnectionTest
{
	connectionTestSucceeded = FALSE;
	self.connectionTestHUD = [[MBProgressHUD alloc] 
		initWithView:self.currParentContext.parentController.navigationController.view];
	[self.currParentContext.parentController.navigationController.view addSubview:self.connectionTestHUD];
	self.connectionTestHUD.mode = MBProgressHUDModeIndeterminate;
	self.connectionTestHUD.delegate = self;
	NSLog(@"Connection test started");
	
	[self.connectionTestHUD showWhileExecuting:@selector(doConnectionTest) onTarget:self withObject:nil animated:TRUE];
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
		entryProgressBasicInfoComplete = TRUE;
		[self populateAcctWithPresetsAfterBasicInfoEntered:newAcct];
		
		
		if(entryProgressServerInfoComplete)
		{
			// If after entering just the basic settings, the server
			// information is defaulted, then test the connection
			// and transition immediately to the message deletion settings.
			[self startAcctConnectionTest];

		}
		else {
			[self showImapServerForm:newAcct];
		}
	}
	else if(currentStep == ADD_EMAIL_ACCOUNT_STEP_PROMPT_IMAP)
	{
		[self populateAcctWithPresetsAfterIMAPServerEntered:newAcct];
		
		// If with the presets, the server information is complete,
		// then test the connection. Otherwise, transition to 
		// confirm the full settings.
		if(entryProgressServerInfoComplete)
		{
			[self startAcctConnectionTest];
		}
		else 
		{
			[self showConfirmSettingsForm:newAcct];
		}
	}
	else if(currentStep == ADD_EMAIL_ACCOUNT_STEP_CONFIRM_ACCT_SETTINGS)
	{
		[self startAcctConnectionTest];
	}
	else 
	{
		assert(0); // should not get here
	}
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	
	if(connectionTestSucceeded)
	{
		[self populateAcctWithDefaultDeleteSettingsAfterFetchingFolders:self.acctBeingAdded];
		[self showMessageDeletionSettingsForm:self.acctBeingAdded];
	}
	else {
	
		if(currentStep != ADD_EMAIL_ACCOUNT_STEP_CONFIRM_ACCT_SETTINGS)
		{
			// If the form is not already in the form to confirm the settings,
			// transition there to allow the user to review/edit the full information.
			[self showConfirmSettingsForm:self.acctBeingAdded];
		}
		[self showConnectionFailedAlert];
	}

}

@end
