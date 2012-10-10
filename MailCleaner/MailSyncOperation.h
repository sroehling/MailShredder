//
//  MailSyncOperation.h
//
//  Created by Steve Roehling on 8/10/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MailOperation.h"
#import "MailSyncProgressDelegate.h"

@class MailSyncConnectionContext;

@interface MailSyncOperation : MailOperation
{
	@private
		id<MailSyncProgressDelegate> syncProgressDelegate;
}

@property(nonatomic,assign) id<MailSyncProgressDelegate> syncProgressDelegate;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
	andProgressDelegate:(id<MailSyncProgressDelegate>)theProgressDelegate;

@end
