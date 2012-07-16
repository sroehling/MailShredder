//
//  PortNumFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NumberFieldEditInfo.h"

@class EmailAccount;

@interface PortNumFieldEditInfo : NumberFieldEditInfo
{
	@private
		EmailAccount *emailAcct;
}


-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct;

@property(nonatomic,retain) EmailAccount *emailAcct;

@end
