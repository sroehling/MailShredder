//
//  CompositeMailSyncProgressDelegate.h
//
//  Created by Steve Roehling on 8/8/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MailSyncProgressDelegate.h"

@interface CompositeMailSyncProgressDelegate : NSObject <MailSyncProgressDelegate> {
	@private
		NSMutableArray *subDelegates;
}

@property(nonatomic,retain) NSMutableArray *subDelegates;

-(void)addSubDelegate:(id<MailSyncProgressDelegate>)subDelegate;
-(void)removeSubDelegate:(id<MailSyncProgressDelegate>)subDelegate;

@end
