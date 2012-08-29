//
//  FolderSyncContext.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MailSyncConnectionContext;
@class EmailFolder;

@interface FolderSyncContext : NSObject
{
	@private
		MailSyncConnectionContext *connectionContext;
		NSMutableDictionary *currFolderByFolderName;
		NSMutableDictionary *foldersNoLongerOnServer;
		NSDictionary *syncFoldersByName;
}

@property(nonatomic,retain) MailSyncConnectionContext *connectionContext;
@property(nonatomic,retain) NSMutableDictionary *currFolderByFolderName;
@property(nonatomic,retain) NSMutableDictionary *foldersNoLongerOnServer;
@property(nonatomic,retain) NSDictionary *syncFoldersByName;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext;

-(EmailFolder*)findOrCreateLocalEmailFolderForServerFolderWithName:(NSString*)folderName;
-(void)deleteMsgsForFoldersNoLongerOnServer;
-(NSUInteger)totalServerMsgCountInAllFolders;
-(BOOL)folderIsSynchronized:(NSString*)folderName;

@end
