//
//  FolderDeletionMsgSet.h
//
//  Created by Steve Roehling on 9/27/12.
//
//

#import <Foundation/Foundation.h>

@class EmailInfo;

@interface FolderDeletionMsgSet : NSObject {
	@private
		CTCoreFolder *srcFolder;
		NSMutableArray *msgsToDeleteBatches;
}

@property(nonatomic,retain) CTCoreFolder *srcFolder;
@property(nonatomic,retain) NSMutableArray *msgsToDeleteBatches;

-(id)initWithSrcFolder:(CTCoreFolder*)theSrcFolder;
-(void)addMsg:(EmailInfo*)msgToDelete;

@end
