//
//  MailSyncProgressDelegate.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MailSyncProgressDelegate <NSObject>

-(void)mailSyncConnectionStarted;
-(void)mailSyncConnectionEstablished;

-(void)mailSyncUpdateProgress:(CGFloat)percentProgress;

-(void)mailSyncConnectionTeardownStarted;
-(void)mailSyncConnectionTeardownFinished;

@end
