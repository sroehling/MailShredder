//
//  MailServerConnectionProgressDelegate.h
//
//  Created by Steve Roehling on 9/11/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MailServerConnectionProgressDelegate <NSObject>

@optional
	-(void)mailServerConnectionStarted;
	-(void)mailServerConnectionEstablished;
	-(void)mailServerConnectionFailed;
	-(void)mailServerConnectionTeardownStarted;
	-(void)mailServerConnectionTeardownFinished;


@end
