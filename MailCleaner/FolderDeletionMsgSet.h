//
//  FolderDeletionMsgSet.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/27/12.
//
//

#import <Foundation/Foundation.h>

@class EmailInfo;

@interface FolderDeletionMsgSet : NSObject {
	@private
		CTCoreFolder *srcFolder;
		NSMutableSet *msgsToDelete;
}

@property(nonatomic,retain) CTCoreFolder *srcFolder;
@property(nonatomic,retain) NSMutableSet *msgsToDelete;

-(id)initWithSrcFolder:(CTCoreFolder*)theSrcFolder;
-(void)addMsg:(EmailInfo*)msgToDelete;

@end
