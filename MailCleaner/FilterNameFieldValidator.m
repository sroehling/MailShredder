//
//  FilterNameFieldValidator.m
//
//  Created by Steve Roehling on 9/4/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "FilterNameFieldValidator.h"
#import "EmailAccount.h"
#import "LocalizationHelper.h"
#import "MessageFilter.h"
#import "CoreDataHelper.h"

@implementation FilterNameFieldValidator

@synthesize emailAcct;
@synthesize messageFilter;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct
	andMessageFilter:(MessageFilter*)theMessageFilter;
{
	self = [super initWithValidationMsg:LOCALIZED_STR(@"MESSAGE_FILTER_NAME_VALIDATION_MSG")];
	if(self)
	{
		assert(theEmailAcct != nil);
		assert(theMessageFilter != nil);
	
		self.emailAcct = theEmailAcct;
		self.messageFilter = theMessageFilter;
	}
	return self;
}

-(id)initWithValidationMsg:(NSString *)validationMsg
{
	assert(0);
	return nil;
}

-(void)dealloc
{
	[emailAcct release];
	[messageFilter release];
	[super dealloc];
}

-(BOOL)validateText:(NSString *)theText
{
	if(theText.length == 0)
	{
		return FALSE;
	}


	NSMutableDictionary *filtersByName = [[[NSMutableDictionary alloc] init] autorelease];
	for(MessageFilter *savedFilter in self.emailAcct.savedMsgListFilters)
	{
		if(![CoreDataHelper sameCoreDataObjects:savedFilter comparedTo:self.messageFilter])
		{
			[filtersByName setObject:savedFilter forKey:savedFilter.filterName];
		}
	}
	
	MessageFilter *existingFilter = [filtersByName objectForKey:theText];
	if(existingFilter != nil)
	{
		// If there's an existing filter with the same name, only validate if 
		// it's the same one as the one being edited.
		if([CoreDataHelper sameCoreDataObjects:existingFilter comparedTo:self.messageFilter])
		{
			return TRUE;
		}
		else 
		{
			return FALSE;
		}
	}
	else 
	{
		return TRUE;
	}
}


@end