//
//  EmailAddressFilterFormInfo.m
//
//  Created by Steve Roehling on 9/29/12.
//
//

#import "EmailAddressFilterFormInfo.h"

@implementation EmailAddressFilterFormInfo

@synthesize selectFromRecipients;
@synthesize selectFromSenders;
@synthesize emailAddressFilter;

-(id)initWithEmailAddressFilter:(EmailAddressFilter *)theEmailAddrFilter
{
	self = [super init];
	if(self)
	{
		assert(theEmailAddrFilter != nil);
		self.emailAddressFilter = theEmailAddrFilter;
		self.selectFromRecipients = TRUE;
		self.selectFromSenders = TRUE;
	}
	return self;
}

-(void)dealloc
{
	[emailAddressFilter release];
	[super dealloc];
}

@end
