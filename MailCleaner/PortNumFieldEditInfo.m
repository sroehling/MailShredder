//
//  PortNumFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PortNumFieldEditInfo.h"
#import "ManagedObjectFieldInfo.h"
#import "EmailAccount.h"
#import "LocalizationHelper.h"
#import "NumberHelper.h"
#import "PortNumberValidator.h"

@implementation PortNumFieldEditInfo

@synthesize emailAcct;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct
{
    ManagedObjectFieldInfo *fieldInfo = [[ManagedObjectFieldInfo alloc] 
              initWithManagedObject:theEmailAcct andFieldKey:EMAIL_ACCOUNT_PORTNUM_KEY 
			  andFieldLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_PORTNUM_FIELD_LABEL")
			  andFieldPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_PORTNUM_PLACEHOLDER")];

	self = [super initWithFieldInfo:fieldInfo andNumberFormatter:[NumberHelper theHelper].decimalFormatter  
			andValidator:[[[PortNumberValidator alloc] init] autorelease]];
	if(self)
	{
		[theEmailAcct addObserver:self forKeyPath:EMAIL_ACCOUNT_USESSL_KEY 
			options:NSKeyValueObservingOptionNew context:NULL];
		self.emailAcct = theEmailAcct;
	}
	return self;
	
}

-(id)initWithFieldInfo:(FieldInfo *)theFieldInfo 
		andNumberFormatter:(NSNumberFormatter *)numFormatter andValidator:(NumberFieldValidator *)theValidator
{
	assert(0);
	return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if([self.fieldInfo fieldAccessEnabled])
	{
		if ([keyPath isEqual:EMAIL_ACCOUNT_USESSL_KEY]) {
			NSLog(@"Use SSL Field change: Updating default port number");
			NSNumber *newValue = (NSNumber*)[change objectForKey:NSKeyValueChangeNewKey];
			
			if([newValue boolValue]== TRUE)
			{
				[self.fieldInfo setFieldValue:[NSNumber numberWithInt:EMAIL_ACCOUNT_DEFAULT_PORT_SSL]];
			}
			else {
				[self.fieldInfo setFieldValue:[NSNumber numberWithInt:EMAIL_ACCOUNT_DEFAULT_PORT_NOSSL]];
			}
			[self refreshFieldValue];
		}
    }
}

-(void)dealloc
{
	[self.emailAcct removeObserver:self forKeyPath:EMAIL_ACCOUNT_USESSL_KEY];
	[emailAcct release];
	[super dealloc];
}

@end
