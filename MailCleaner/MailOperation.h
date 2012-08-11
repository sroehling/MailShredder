//
//  MailOperation.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/10/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MailSyncConnectionContext;

@interface MailOperation : NSOperation
{
	@private
		MailSyncConnectionContext *connectionContext;
		
}

@property(nonatomic,retain) MailSyncConnectionContext *connectionContext;

-(id)initWithConnectionContext:(MailSyncConnectionContext*)theConnectionContext;

@end