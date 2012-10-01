//
//  EmailAddressFilterFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormInfoCreator.h"

@class EmailAddressFilterFormInfo;

@interface EmailAddressFilterFormInfoCreator: NSObject <FormInfoCreator> {
	@private
		EmailAddressFilterFormInfo *emailAddressFilterFormInfo;
    
}

@property(nonatomic,retain) EmailAddressFilterFormInfo *emailAddressFilterFormInfo;

-(id)initWithEmailAddressFilter:(EmailAddressFilterFormInfo*)theEmailAddrFilterFormInfo;

@end
