//
//  TestMailDeleteProgressDelegate.h
//  MailShredder
//
//  Created by Steve Roehling on 1/28/13.
//
//

#import <Foundation/Foundation.h>

#import "MailDeleteOperation.h"

@interface TestMailDeleteProgressDelegate : NSObject <MailDeleteProgressDelegate> {
    @private
        BOOL logDeletedMsgs;
        NSUInteger numDeletedMsgs;
    
}

@property BOOL logDeletedMsgs;
@property NSUInteger numDeletedMsgs;

-(void)reset;

@end
