//
//  FilterNameFieldValidator.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TextFieldValidator.h"

@class EmailAccount;
@class MessageFilter;

@interface FilterNameFieldValidator : TextFieldValidator
{
	@private
		EmailAccount *emailAcct;
		MessageFilter *messageFilter;
}

@property(nonatomic,retain) EmailAccount *emailAcct;
@property(nonatomic,retain) MessageFilter *messageFilter;


-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct
	andMessageFilter:(MessageFilter*)theMessageFilter;

@end
