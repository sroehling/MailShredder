//
//  GetMessageBodyOperation.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EmailInfo;
@class MailSyncConnectionContext;

@protocol GetMessageBodyDelegate;

@interface GetMessageBodyOperation : NSOperation
{
	@private
		MailSyncConnectionContext *connectionContext;
		EmailInfo *emailInfo;
		id<GetMessageBodyDelegate> getMsgBodyDelegate;
}

-(id)initWithEmailInfo:(EmailInfo*)theEmailInfo 
	andConnectionContext:(MailSyncConnectionContext*)theConnectionContext
	andGetMsgBodyDelegate:(id<GetMessageBodyDelegate>) msgBodyDelegate;

@property(nonatomic,retain) MailSyncConnectionContext *connectionContext;
@property(nonatomic,retain) EmailInfo *emailInfo;
@property(nonatomic,assign) id<GetMessageBodyDelegate> getMsgBodyDelegate;

@end

@protocol GetMessageBodyDelegate <NSObject>

-(void)msgBodyRetrievalComplete:(NSString*)msgBody;
-(void)msgBodyRetrievalFailed;

@end
