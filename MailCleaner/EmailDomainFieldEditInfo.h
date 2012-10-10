//
//  EmailDomainFieldEditInfo.h
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StaticFieldEditInfo.h"

@class EmailDomain;
@class EmailDomainFilter;

@interface EmailDomainFieldEditInfo : NSObject <FieldEditInfo>
{
	@private
		EmailDomain* emailDomain;
		EmailDomainFilter *parentFilter; // optional
}

@property(nonatomic,retain) EmailDomain* emailDomain;
@property(nonatomic,retain) EmailDomainFilter *parentFilter;

-(id)initWithEmailDomain:(EmailDomain*)theEmailDomain;

@end
