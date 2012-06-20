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
#import "EmailAddressSelectionFormInfoCreator.h"
#import "FormContext.h"

@implementation EmailAddressFilterAddressAdder

@synthesize emailAddressFilter;

-(id)initWithEmailAddressFilter:(EmailAddressFilter*)theAddressFilter
{
	self = [super init];
	if(self)
	{
		assert(theAddressFilter != nil);
		self.emailAddressFilter = theAddressFilter;
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
	
	EmailAddressSelectionFormInfoCreator *emailAddressFormInfoCreator = 
		[[[EmailAddressSelectionFormInfoCreator alloc] 
		initWithEmailAddressFilter:self.emailAddressFilter] autorelease];
		
	MultipleSelectionAddViewController *senderAddressSelectionController = 
		[[[MultipleSelectionAddViewController alloc] 
			initWithFormInfoCreator:emailAddressFormInfoCreator andDataModelController:parentContext.dataModelController 
			andSelectionDoneListener:self] autorelease];
	
    [parentContext.parentController.navigationController 
		pushViewController:senderAddressSelectionController animated:YES];
}

-(void)multipleSelectionAddFinishedSelection:(NSSet *)selectedObjs
{
	NSLog(@"Finished selecting email addresses: %@",[selectedObjs description]);

	assert(selectedObjs != nil);
	[self.emailAddressFilter addSelectedAddresses:selectedObjs];
	
}

-(BOOL)supportsAddOutsideEditMode
{
	return FALSE;
}

-(void)dealloc
{
	[emailAddressFilter release];
	[super dealloc];
}


@end
