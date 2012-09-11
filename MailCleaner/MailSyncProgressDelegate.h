//
//  MailSyncProgressDelegate.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MailServerConnectionProgressDelegate.h"

@protocol MailSyncProgressDelegate <NSObject,MailServerConnectionProgressDelegate>

-(void)mailSyncUpdateProgress:(CGFloat)percentProgress;
-(void)mailSyncComplete:(BOOL)successfulCompletion;

@end
