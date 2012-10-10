//
//  MailAddressHelper.h
//
//  Created by Steve Roehling on 6/27/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailAddressHelper : NSObject

+(NSString*)emailAddressDomainName:(NSString*)fullAddress;
+(NSString*)emailAddressUserName:(NSString*)fullAddress;

@end
