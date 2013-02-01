//
//  TestMailSyncProgressDelegate.h
//  MailShredder
//
//  Created by Steve Roehling on 1/25/13.
//
//

#import <Foundation/Foundation.h>

#import "MailSyncProgressDelegate.h"

@interface TestMailSyncProgressDelegate : NSObject <MailSyncProgressDelegate>
{
    @private
        BOOL logMsgSyncCompletion;
        NSUInteger numMsgsSynced;
}

@property BOOL logMsgSyncCompletion;
@property NSUInteger numMsgsSynced;

-(void)reset;

@end
