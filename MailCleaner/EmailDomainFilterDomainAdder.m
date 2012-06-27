//
//  EmailDomainFilterDomainAdder.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailDomainFilterDomainAdder.h"
#import "EmailDomainFilter.h"
#import "EmailDomainSelectionFormInfoCreator.h"
#import "FormContext.h"

@implementation EmailDomainFilterDomainAdder

@synthesize emailDomainFilter;

-(id)initWithEmailDomainFilter:(EmailDomainFilter*)theDomainFilter
{
	self = [super init];
	if(self)
	{
		assert(theDomainFilter != nil);
		self.emailDomainFilter = theDomainFilter;
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
	NSLog(@"Add email domain to domain filter");
	
	EmailDomainSelectionFormInfoCreator *emailDomainFormInfoCreator = 
		[[[EmailDomainSelectionFormInfoCreator alloc] 
		initWithEmailDomainFilter:self.emailDomainFilter] autorelease];
		
	MultipleSelectionAddViewController *senderAddressSelectionController = 
		[[[MultipleSelectionAddViewController alloc] 
			initWithFormInfoCreator:emailDomainFormInfoCreator 
			andDataModelController:parentContext.dataModelController 
			andSelectionDoneListener:self] autorelease];
	
    [parentContext.parentController.navigationController 
		pushViewController:senderAddressSelectionController animated:YES];
}

-(void)multipleSelectionAddFinishedSelection:(NSSet *)selectedObjs
{
	NSLog(@"Finished selecting email domain: %@",[selectedObjs description]);

	assert(selectedObjs != nil);
	[self.emailDomainFilter addSelectedDomains:selectedObjs];
	
}

-(BOOL)supportsAddOutsideEditMode
{
	return FALSE;
}

-(void)dealloc
{
	[emailDomainFilter release];
	[super dealloc];
}



@end
