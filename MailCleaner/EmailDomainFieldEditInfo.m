//
//  EmailDomainFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailDomainFieldEditInfo.h"
#import "EmailDomain.h"
#import "DataModelController.h"
#import "EmailDomainFilter.h"

@implementation EmailDomainFieldEditInfo

@synthesize emailDomain;
@synthesize parentFilter;

-(id)initWithEmailDomain:(EmailDomain*)theEmailDomain
{
	self = [super initWithManagedObj:theEmailDomain 
		andCaption:theEmailDomain.domainName andContent:@""];
	if(self)
	{
		self.emailDomain = theEmailDomain;
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
	[emailDomain release];
	[parentFilter release];
	[super dealloc];
}  


- (BOOL)isSelected
{
	return self.emailDomain.isSelectedForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	self.emailDomain.isSelectedForSelectableObjectTableView = isSelected;
}


-(BOOL)supportsDelete
{
	return (self.parentFilter != nil)?TRUE:FALSE;
}


-(void)deleteObject:(DataModelController*)dataModelController
{
	assert([self supportsDelete]);
	[self.parentFilter removeSelectedDomainsObject:self.emailDomain];
}

@end
