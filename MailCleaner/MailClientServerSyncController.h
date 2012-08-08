//
//  MailSyncController.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataModelController;
@class EmailAccount;

@interface MailClientServerSyncController : NSObject
{
	@private
		DataModelController *mainThreadDmc;
}

@property(nonatomic,retain) DataModelController *mainThreadDmc;

-(id)initWithMainThreadDataModelController:(DataModelController*)theMainThreadDmc;

-(void)syncWithServerInBackgroundThread;
-(void)deleteMarkedMsgsInBackgroundThread;

@end
