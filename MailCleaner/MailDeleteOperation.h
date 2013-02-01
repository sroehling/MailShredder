//
//  MailDeleteOperation.h
//
//  Created by Steve Roehling on 8/10/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MailOperation.h"
#import "MailServerConnectionProgressDelegate.h"

@protocol MailDeleteProgressDelegate;
@class MailDeleteCompletionInfo;
@class EmailInfo;

@interface MailDeleteOperation : MailOperation
{
	@private
		id<MailDeleteProgressDelegate> deleteProgressDelegate;
}

@property(nonatomic,assign) id<MailDeleteProgressDelegate> deleteProgressDelegate;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
	andProgressDelegate:(id<MailDeleteProgressDelegate>)theDeleteProgressDelegate;

@end



@protocol MailDeleteProgressDelegate <NSObject,MailServerConnectionProgressDelegate>

@optional
	-(void)mailDeleteUpdateProgress:(CGFloat)percentProgress;
	-(void)mailDeleteComplete:(BOOL)completeStatus withCompletionInfo:(MailDeleteCompletionInfo*)mailDeleteCompletionInfo;
    -(void)mailDeleteMsgComplete:(EmailInfo*)deletedMsg;

@end
