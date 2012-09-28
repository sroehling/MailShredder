//
//  FolderDeletionMsgs.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/27/12.
//
//

#import <Foundation/Foundation.h>

@class CTCoreAccount;

@interface FolderDeletionMsgs : NSObject {
	@private
		NSMutableDictionary *deletionMsgsByFolderName;
}

@property(nonatomic,retain) NSMutableDictionary *deletionMsgsByFolderName;

-(id)initWithMsgsToDelete:(NSArray*)msgsMarkedForDeletion
	andMailAcct:(CTCoreAccount*)mailAcct;
-(NSArray*)folderDeletionMsgSets;

@end
