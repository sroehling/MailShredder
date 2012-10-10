//
//  MailSyncConnectionContext.h
//
//  Created by Steve Roehling on 8/7/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
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
		
		BOOL contextIsSetup;

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

// The following happen in order when a connection context
// is used for mail synchronization or delete.
-(void)setupContext;
-(BOOL)establishConnection;
-(void)teardownConnection;
-(void)teardownContext;

-(void)saveLocalChanges;

@end
