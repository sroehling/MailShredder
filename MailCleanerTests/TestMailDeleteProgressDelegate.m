//
//  TestMailDeleteProgressDelegate.m
//  MailShredder
//
//  Created by Steve Roehling on 1/28/13.
//
//

#import "TestMailDeleteProgressDelegate.h"

@implementation TestMailDeleteProgressDelegate

-(void)mailServerConnectionStarted
{
    NSLog(@"DELETE: Test Mail Server Connection Started Started");
}

-(void)mailServerConnectionEstablished
{
    NSLog(@"DELETE: Test Mail Server Connection Started Established");
}

-(void)mailServerConnectionFailed
{
    NSLog(@"DELETE: Test Mail Server Connection Failed");
    
}


-(void)mailServerConnectionTeardownStarted
{
}

-(void)mailServerConnectionTeardownFinished
{
    NSLog(@"DELETE: Test Mail Server Connection Teardown Finished");
}

-(void)mailDeleteComplete:(BOOL)completeStatus withCompletionInfo:(MailDeleteCompletionInfo *)mailDeleteCompletionInfo
{
}

-(void)mailDeleteUpdateProgress:(CGFloat)percentProgress
{
}



@end
