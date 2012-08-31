//
//  RuleObjectAdder.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilterObjectAdder.h"
#import "TableViewObjectAdder.h"
#import "PopupButtonListView.h"
#import "ButtonListItemInfo.h"
#import "LocalizationHelper.h"
#import "FormContext.h"
#import "GenericFieldBasedTableAddViewController.h"
#import "AppHelper.h"
#import "DataModelController.h"
#import "SharedAppVals.h"
#import "AgeFilterNone.h"
#import "SavedMessageFilterFormInfoCreator.h"
#import "EmailAddressFilter.h"
#import "MessageFilter.h"
#import "AppDelegate.h"

@implementation MessageFilterObjectAdder 

@synthesize mainDmc;
@synthesize addFilterDmc;

-(id)init
{
	self = [super init];
	if(self)
	{
		self.mainDmc = [AppHelper theAppDelegate].appDmc;
	}
	return self;
}

-(void)teardownNewFilterDmc
{
	if(self.addFilterDmc != nil)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self 
			name:NSManagedObjectContextDidSaveNotification 
			object:self.addFilterDmc.managedObjectContext];
		self.addFilterDmc = nil;
	}
}

-(void)setupNewFilterDmc
{
	[self teardownNewFilterDmc];
	self.addFilterDmc = [[[DataModelController alloc] 
			initWithPersistentStoreCoord:self.mainDmc.persistentStoreCoordinator] autorelease];
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(newFilterSavedDidSaveNotificationHandler:)
		name:NSManagedObjectContextDidSaveNotification 
		object:self.addFilterDmc.managedObjectContext];	
}

-(void)addObjectFromTableView:(FormContext*)parentContext
{
	NSLog(@"Adding rule");
	
	[parentContext.dataModelController saveContextAndIgnoreErrors];
	
	[self setupNewFilterDmc];
	
	MessageFilter *newFilter = [MessageFilter defaultMessageFilter:self.addFilterDmc];
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:self.addFilterDmc];
	
	self.mainDmc = parentContext.dataModelController;

	newFilter.emailAcctSavedFilter = sharedVals.currentEmailAcct;

	SavedMessageFilterFormInfoCreator *savedMessageFilterFormCreator = 
		[[[SavedMessageFilterFormInfoCreator alloc] initWithMessageFilter:newFilter] autorelease];
	
	GenericFieldBasedTableAddViewController *addView =  
		[[[GenericFieldBasedTableAddViewController alloc] 
		initWithFormInfoCreator:savedMessageFilterFormCreator andNewObject:newFilter
		andDataModelController:self.addFilterDmc] autorelease];
	addView.popDepth = 1;
	addView.saveWhenSaveButtonPressed = TRUE;

	[parentContext.parentController.navigationController pushViewController:addView animated:TRUE];

}

-(BOOL)supportsAddOutsideEditMode
{
	return FALSE;
}

- (void)newFilterSavedDidSaveNotificationHandler:(NSNotification *)notification
{
     [self.mainDmc.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];	
}

-(void)dealloc
{
	[self teardownNewFilterDmc];
	
	[mainDmc release];
	[addFilterDmc release];
	[super dealloc];

}

@end
