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

@interface MailSyncConnectionContext : NSObject
{
	@private
		DataModelController *syncDmc;
		CTCoreAccount *mailAcct;
		EmailAccount *emailAcctInfo;
}

@property(nonatomic,retain) DataModelController *syncDmc;
@property(nonatomic,retain) CTCoreAccount *mailAcct;
@property(nonatomic,retain) EmailAccount *emailAcctInfo;

-(void)connect;
-(void)disconnect;

-(id)initWithMainThreadDmc:(DataModelController*)mainThreadDmc;

@end
