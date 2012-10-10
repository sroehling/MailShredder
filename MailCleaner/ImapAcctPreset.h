//
//  EmailAcctPreset.h
//
//  Created by Steve Roehling on 8/20/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
		
		NSMutableArray *defaultSyncFolders;
		BOOL matchFirstDefaultSyncFolder;
		
		NSMutableArray *defaultTrashFolders;
		BOOL immediatelyDeleteMsg;
}

@property(nonatomic,retain) NSString *domainName;
@property(nonatomic,retain) NSString *imapServer;
@property(nonatomic,retain) NSMutableArray *defaultSyncFolders;
@property(nonatomic,retain) NSMutableArray *defaultTrashFolders;
@property BOOL useSSL;
@property NSUInteger portNum;
@property BOOL fullEmailIsUserName;
@property BOOL immediatelyDeleteMsg;
@property BOOL matchFirstDefaultSyncFolder;

@end
