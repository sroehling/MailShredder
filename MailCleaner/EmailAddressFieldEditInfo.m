//
//  EmailAddressFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddressFieldEditInfo.h"
#import "EmailAddress.h"
#import "EmailAddressFilter.h"

@implementation EmailAddressFieldEditInfo

@synthesize emailAddr;
@synthesize parentFilter;

-(id)initWithEmailAddress:(EmailAddress*)theEmailAddr
{
	self = [super initWithManagedObj:theEmailAddr 
		andCaption:theEmailAddr.address andContent:@""];
	if(self)
	{
		self.emailAddr = theEmailAddr;
	}
	return self;
}

-(id)initWithManagedObj:(NSManagedObject *)theFieldObj andCaption:(NSString *)theCaption 
	andContent:(NSString *)theContent
{
	assert(0);
	return nil;
}


-(void)dealloc
{
	[emailAddr release];
	[parentFilter release];
	[super dealloc];
}  


- (BOOL)isSelected
{
	return self.emailAddr.isSelectedForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	self.emailAddr.isSelectedForSelectableObjectTableView = isSelected;
}


-(BOOL)supportsDelete
{
	return (self.parentFilter != nil)?TRUE:FALSE;
}


-(void)deleteObject:(DataModelController*)dataModelController
{
	assert([self supportsDelete]);
	[self.parentFilter removeSelectedAddressesObject:self.emailAddr];
}



@end
