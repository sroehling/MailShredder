//
//  EmailAddrFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormInfoCreator.h"

@class EmailAccount;

@interface EmailAddrFormInfoCreator : NSObject <FormInfoCreator>
{
	@private
		EmailAccount *emailAccount;
}

@property(nonatomic,retain) EmailAccount *emailAccount;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct;

@end
