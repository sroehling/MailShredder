//
//  TestMailSyncProgressDelegate.m
//  MailShredder
//
//  Created by Steve Roehling on 1/25/13.
//
//

#import "TestMailSyncProgressDelegate.h"
#import "DateHelper.h"

@implementation TestMailSyncProgressDelegate

@synthesize logMsgSyncCompletion;
@synthesize numMsgsSynced;

-(id)init
{
    self = [super init];
    if(self)
    {
        [self reset];
    }
    return self;
}

-(void)reset
{
    self.logMsgSyncCompletion = FALSE;
    self.numMsgsSynced = 0;
}

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

-(void)msgSyncComplete:(CTCoreMessage*)msg
{
    if(self.logMsgSyncCompletion)
    {
        
        DateHelper *dateHelper = [[[DateHelper alloc] init] autorelease];

		NSString *dateStr =  [dateHelper.longDateFormatter stringFromDate:msg.sentDateGMT];
 		NSString *senderDateStr = [dateHelper.longDateFormatter stringFromDate:msg.senderDate];
        
		NSLog(@"Msg Sync Complete: UID=%d sequence #  = %d sender date=%@, gmt date=%@, subj=%@, sender=%@",
              msg.uid, msg.sequenceNumber,
              senderDateStr,dateStr,msg.sender.email,msg.sender.email);
        
    }
    numMsgsSynced ++;
    
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
