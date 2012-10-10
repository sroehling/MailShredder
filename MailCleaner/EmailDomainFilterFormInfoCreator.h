//
//  EmailDomainFilterFormInfoCreator.h
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormInfoCreator.h"

@class EmailDomainFilter;

@interface EmailDomainFilterFormInfoCreator : NSObject <FormInfoCreator> {
	@private
		EmailDomainFilter *emailDomainFilter;
    
}

@property(nonatomic,retain) EmailDomainFilter *emailDomainFilter;

-(id)initWithEmailDomainFilter:(EmailDomainFilter*)theEmailDomainFilter;

@end
