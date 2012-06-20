//
//  MailSyncController.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataModelController;

@interface MailClientServerSyncController : NSObject
{
	@private
		CTCoreAccount *mailAcct;
		DataModelController *emailInfoDmc;
		DataModelController *appDataDmc;
}

@property(nonatomic,retain) CTCoreAccount *mailAcct;
@property(nonatomic,retain) DataModelController *emailInfoDmc;
@property(nonatomic,retain) DataModelController *appDataDmc;

-(id)initWithDataModelController:(DataModelController*)theDmcForEmailInfo
	andAppDataDmc:(DataModelController*)theAppDataDmc;

-(void)syncWithServer;
-(void)deleteMarkedMsgs;

@end
