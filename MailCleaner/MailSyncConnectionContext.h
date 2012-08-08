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

@interface MailSyncConnectionContext : NSObject
{
	@private
		DataModelController *syncDmc;
		CTCoreAccount *mailAcct;
}

@property(nonatomic,retain) DataModelController *syncDmc;
@property(nonatomic,retain) CTCoreAccount *mailAcct;

-(void)connect;
-(void)disconnect;

@end
