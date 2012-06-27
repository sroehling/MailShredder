//
//  EmailDomainSelectionFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormInfoCreator.h"

@class EmailDomainFilter;


@interface EmailDomainSelectionFormInfoCreator : NSObject  <FormInfoCreator> {
	@private
		EmailDomainFilter *emailDomainFilter;
}

@property(nonatomic,retain) EmailDomainFilter *emailDomainFilter;

-(id)initWithEmailDomainFilter:(EmailDomainFilter*)theEmailDomainFilter;

@end
