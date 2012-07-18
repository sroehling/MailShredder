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


-(void)dealloc
{
	[emailAcct release];
	[super dealloc];
}

@end
