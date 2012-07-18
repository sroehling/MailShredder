//
//  EmailAcctFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StaticNavFieldEditInfo.h"

@class EmailAccount;
@class DataModelController;

@interface EmailAcctFieldEditInfo : StaticNavFieldEditInfo
{
	@private
		EmailAccount *emailAcct;
		DataModelController *appDmc;
}

@property(nonatomic,retain) EmailAccount *emailAcct;
@property(nonatomic,retain) DataModelController *appDmc;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct andAppDmc:(DataModelController*)theAppDmc;

@end
