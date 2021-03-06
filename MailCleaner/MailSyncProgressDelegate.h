//
//  MailSyncProgressDelegate.h
//
//  Created by Steve Roehling on 8/8/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MailServerConnectionProgressDelegate.h"

@protocol MailSyncProgressDelegate <NSObject,MailServerConnectionProgressDelegate>

@optional
	-(void)mailSyncUpdateProgress:(CGFloat)percentProgress;
	-(void)mailSyncComplete:(BOOL)successfulCompletion;
    -(void)msgSyncComplete:(CTCoreMessage*)msg;

@end
