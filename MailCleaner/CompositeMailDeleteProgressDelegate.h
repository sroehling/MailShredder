//
//  CompositeMailDeleteProgressDelegate.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MailDeleteOperation.h"

@interface CompositeMailDeleteProgressDelegate : NSObject <MailDeleteProgressDelegate> {
	@private
		NSMutableArray *subDelegates;
}

@property(nonatomic,retain) NSMutableArray *subDelegates;

-(void)addSubDelegate:(id<MailDeleteProgressDelegate>)subDelegate;
-(void)removeSubDelegate:(id<MailDeleteProgressDelegate>)subDelegate;


@end
