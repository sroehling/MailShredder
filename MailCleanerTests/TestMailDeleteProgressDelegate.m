//
//  TestMailDeleteProgressDelegate.m
//  MailShredder
//
//  Created by Steve Roehling on 1/28/13.
//
//

#import "TestMailDeleteProgressDelegate.h"
#import "EmailInfo.h"
#import "DateHelper.h"
#import "EmailAddress.h"

@implementation TestMailDeleteProgressDelegate

@synthesize logDeletedMsgs;
@synthesize numDeletedMsgs;

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
    self.logDeletedMsgs = FALSE;
    self.numDeletedMsgs = 0;
 
}

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

-(void)mailDeleteMsgComplete:(EmailInfo *)deletedMsg
{
    if(self.logDeletedMsgs)
    {
		NSString *dateStr =  [[DateHelper theHelper].longDateFormatter stringFromDate:deletedMsg.sendDate];
       
		NSLog(@"Msg Sync Complete: UID=%d subj=%@, date=%@, sender=%@",
              [deletedMsg.uid integerValue], deletedMsg.subject,dateStr,
              deletedMsg.senderAddress.address);
        
    }
    self.numDeletedMsgs ++;
    
}


@end
