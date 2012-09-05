//
//  MessageFilterCountOperation.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EmailAccount;
@class DataModelController;

@interface MessageFilterCountOperation : NSOperation
{
	@private
		EmailAccount *emailAccount;
		DataModelController *mainThreadDmc;
}

@property(nonatomic,retain) EmailAccount *emailAccount;
@property(nonatomic,retain) DataModelController *mainThreadDmc;

-(id)initWithMainThreadDmc:(DataModelController*)mainThreadDmc
	andEmailAccount:(EmailAccount*)theEmailAccount;

@end
