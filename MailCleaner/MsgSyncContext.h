//
//  MsgSyncContext.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MailSyncConnectionContext;
@class EmailFolder;
@class PercentProgressCounter;

@interface MsgSyncContext : NSObject
{
	@private

		// The following properties are used throughout
		// a synchronization session.
		MailSyncConnectionContext *connectionContext;
		
		NSMutableDictionary *currEmailAddressByAddress;
		NSMutableDictionary *currDomainByDomainName;
		
		// The following properties are used for the
		// synchronization of a single folder.
		NSMutableDictionary *existingEmailInfoByUID;
		EmailFolder *currFolder;
		
		NSUInteger newLocalMsgsCreated;
		PercentProgressCounter *syncProgressCounter;

}


@property(nonatomic,retain) MailSyncConnectionContext *connectionContext;
@property(nonatomic,retain) NSMutableDictionary *currEmailAddressByAddress;
@property(nonatomic,retain) NSMutableDictionary *currDomainByDomainName;

@property(nonatomic,retain) NSMutableDictionary *existingEmailInfoByUID;
@property(nonatomic,retain) EmailFolder *currFolder;

@property(nonatomic,retain) PercentProgressCounter *syncProgressCounter;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
	andTotalExpectedMsgs:(NSUInteger)totalMsgs;

-(void)startMsgSyncForFolder:(EmailFolder*)emailFolder;
-(void)syncOneMsg:(CTCoreMessage*)msg;
-(void)finishFolderSync;

@end
