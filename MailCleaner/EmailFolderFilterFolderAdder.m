//
//  EmailFolderFilterFolderAdder.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailFolderFilterFolderAdder.h"
#import "FormContext.h"
#import "EmailFolderSelectionFormInfoCreator.h"
#import "EmailFolderFilter.h"

@implementation EmailFolderFilterFolderAdder

@synthesize emailFolderFilter;

-(id)initWithEmailFolderFilter:(EmailFolderFilter*)theFolderFilter
{
	self = [super init];
	if(self)
	{
		assert(theFolderFilter != nil);
		self.emailFolderFilter = theFolderFilter;
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
	
	EmailFolderSelectionFormInfoCreator *emailFolderFormInfoCreator = 
		[[[EmailFolderSelectionFormInfoCreator alloc] 
		initWithEmailFolderFilter:self.emailFolderFilter] autorelease];
		
	MultipleSelectionAddViewController *senderAddressSelectionController = 
		[[[MultipleSelectionAddViewController alloc] 
			initWithFormInfoCreator:emailFolderFormInfoCreator 
			andDataModelController:parentContext.dataModelController 
			andSelectionDoneListener:self] autorelease];
	
    [parentContext.parentController.navigationController 
		pushViewController:senderAddressSelectionController animated:YES];
}

-(void)multipleSelectionAddFinishedSelection:(NSSet *)selectedObjs
{
	NSLog(@"Finished selecting email domain: %@",[selectedObjs description]);

	assert(selectedObjs != nil);
	[self.emailFolderFilter addSelectedFolders:selectedObjs];
	
}

-(BOOL)supportsAddOutsideEditMode
{
	return FALSE;
}

-(void)dealloc
{
	[emailFolderFilter release];
	[super dealloc];
}



@end
