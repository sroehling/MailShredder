//
//  EmailAddressFilterAddressAdder.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddressFilterAddressAdder.h"
#import "EmailAddressFilter.h"
#import "MultipleSelectionAddViewController.h"
#import "FormContext.h"
#import "EmailAddressSelectionTableConfigurator.h"
#import "MultiSelectionCoreDataTableViewController.h"
#import "EmailAddressFilterFormInfo.h"

@implementation EmailAddressFilterAddressAdder

@synthesize emailAddressFilterFormInfo;

-(id)initWithEmailAddressFilter:(EmailAddressFilterFormInfo*)theAddressFilterFormInfo
{
	self = [super init];
	if(self)
	{
		assert(theAddressFilterFormInfo != nil);
		self.emailAddressFilterFormInfo = theAddressFilterFormInfo;
	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}

-(void)addObjectFromTableView:(FormContext*)parentContext
{
	NSLog(@"Add email address to address filter");
	
	EmailAddressSelectionTableConfigurator *tableConfigurator =
		[[[EmailAddressSelectionTableConfigurator alloc]
			initWithDataModelController:parentContext.dataModelController
			andFilterFormInfo:self.emailAddressFilterFormInfo] autorelease];
		
	MultiSelectionCoreDataTableViewController *selectionViewController =
		[[[MultiSelectionCoreDataTableViewController alloc] initWithTableConfigurator:tableConfigurator andSelectionDoneListener:self] autorelease];
	
    [parentContext.parentController.navigationController 
		pushViewController:selectionViewController animated:YES];
}

-(void)multipleSelectionAddFinishedSelection:(NSSet *)selectedObjs
{
	NSLog(@"Finished selecting email addresses: %@",[selectedObjs description]);

	assert(selectedObjs != nil);
	[self.emailAddressFilterFormInfo.emailAddressFilter addSelectedAddresses:selectedObjs];
	
}

-(BOOL)supportsAddOutsideEditMode
{
	return FALSE;
}

-(void)dealloc
{
	[emailAddressFilterFormInfo release];
	[super dealloc];
}


@end
