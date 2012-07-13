//
//  EmailAccountFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormInfoCreator.h"

@class EmailAccount;

@interface EmailAccountFormInfoCreator : NSObject <FormInfoCreator>
{
	@private
		EmailAccount *emailAccount;
}

@property(nonatomic,retain) EmailAccount *emailAccount;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct;

@end
