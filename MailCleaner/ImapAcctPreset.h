//
//  EmailAcctPreset.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImapAcctPreset : NSObject
{
	@private
		NSString *domainName;
		NSString *imapServer;
		BOOL useSSL;
		NSUInteger portNum;
		BOOL fullEmailIsUserName;
}

@property(nonatomic,retain) NSString *domainName;
@property(nonatomic,retain) NSString *imapServer;
@property BOOL useSSL;
@property NSUInteger portNum;
@property BOOL fullEmailIsUserName;

+(NSDictionary*)presetsByDomainName;

@end
