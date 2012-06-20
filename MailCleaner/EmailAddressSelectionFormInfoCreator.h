//
//  EmailAddressSelectionFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormInfoCreator.h"

@class EmailAddressFilter;

@interface EmailAddressSelectionFormInfoCreator : NSObject <FormInfoCreator> {
	@private
		EmailAddressFilter *emailAddressFilter;
    
}

@property(nonatomic,retain) EmailAddressFilter *emailAddressFilter;

-(id)initWithEmailAddressFilter:(EmailAddressFilter*)theEmailAddrFilter;

@end