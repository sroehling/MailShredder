//
//  MailAddressHelper.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailAddressHelper : NSObject

+(NSString*)emailAddressDomainName:(NSString*)fullAddress;

@end
