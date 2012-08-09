//
//  MailSyncController.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MailSyncProgressDelegate.h"

@class DataModelController;
@class EmailAccount;

@interface MailClientServerSyncController : NSObject
{
	@private
		DataModelController *mainThreadDmc;
		id<MailSyncProgressDelegate> progressDelegate;
}

@property(nonatomic,retain) DataModelController *mainThreadDmc;
@property(nonatomic,assign) id<MailSyncProgressDelegate> progressDelegate;

-(id)initWithMainThreadDataModelController:(DataModelController*)theMainThreadDmc
	andProgressDelegate:(id<MailSyncProgressDelegate>)theProgressDelegate;

-(void)syncWithServerInBackgroundThread;
-(void)deleteMarkedMsgsInBackgroundThread;

@end
