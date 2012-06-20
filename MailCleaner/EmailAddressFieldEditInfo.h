//
//  EmailAddressFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StaticFieldEditInfo.h"

@class EmailAddress;
@class EmailAddressFilter;

@interface EmailAddressFieldEditInfo : StaticFieldEditInfo
{
	@private
		EmailAddress* emailAddr;
		EmailAddressFilter *parentFilter; // optional
		
		
}

@property(nonatomic,retain) EmailAddress *emailAddr;
@property(nonatomic,retain) EmailAddressFilter *parentFilter;

-(id)initWithEmailAddress:(EmailAddress*)theEmailAddr;

@end
