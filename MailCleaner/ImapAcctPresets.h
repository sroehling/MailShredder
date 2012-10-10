//
//  ImapAcctPresets.h
//
//  Created by Steve Roehling on 9/6/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImapAcctPreset;

@interface ImapAcctPresets : NSObject
{
	@private
		NSMutableDictionary *presetsByDomainName;
		NSMutableDictionary *presetsByIMAPHostName;
}

@property(nonatomic,retain) NSMutableDictionary *presetsByDomainName;
@property(nonatomic,retain) NSMutableDictionary *presetsByIMAPHostName;

-(ImapAcctPreset*)findPresetWithDomainName:(NSString*)domainName;
-(ImapAcctPreset*)findPresetWithImapHostName:(NSString*)imapHostName;

@end
