//
//  MailSyncConnectionContext.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataModelController;
@class CTCoreAccount;
@class EmailAccount;

#import "MailServerConnectionProgressDelegate.h"

@interface MailSyncConnectionContext : NSObject
{
	@private
		DataModelController *syncDmc;
		DataModelController *mainThreadDmc;
		CTCoreAccount *mailAcct;
		EmailAccount *emailAcctInfo;
		id<MailServerConnectionProgressDelegate> progressDelegate;

}

@property(nonatomic,retain) DataModelController *syncDmc;
@property(nonatomic,retain) DataModelController *mainThreadDmc;
@property(nonatomic,retain) CTCoreAccount *mailAcct;
@property(nonatomic,retain) EmailAccount *emailAcctInfo;
@property(nonatomic,assign) id<MailServerConnectionProgressDelegate> progressDelegate;

-(void)connect;
-(void)disconnect;

-(id)initWithMainThreadDmc:(DataModelController*)theMainThreadDmc
	andProgressDelegate:(id<MailServerConnectionProgressDelegate>)theProgressDelegate;
	
-(EmailAccount*)acctInSyncObjectContext;	
	
-(BOOL)establishConnection;
-(void)teardownConnection;
-(void)saveLocalChanges;

@end
