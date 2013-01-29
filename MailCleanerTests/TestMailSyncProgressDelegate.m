//
//  TestMailSyncProgressDelegate.m
//  MailShredder
//
//  Created by Steve Roehling on 1/25/13.
//
//

#import "TestMailSyncProgressDelegate.h"

@implementation TestMailSyncProgressDelegate

-(void)mailServerConnectionStarted
{
    NSLog(@"SYNC: Test Mail Server Connection Started Started");
}

-(void)mailServerConnectionEstablished
{
    NSLog(@"SYNC: Test Mail Server Connection Started Established");
}

-(void)mailServerConnectionFailed
{
    NSLog(@"SYNC: Test Mail Server Connection Failed");

}

-(void)mailSyncUpdateProgress:(CGFloat)percentProgress
{
}

-(void)mailServerConnectionTeardownStarted
{
}

-(void)mailServerConnectionTeardownFinished
{
    NSLog(@"SYNC: Connection teardown finished");
}

-(void)mailSyncComplete:(BOOL)successfulCompletion
{
    NSLog(@"SYNC: Test Mail Server Connection Sync Complete");

}


@end
