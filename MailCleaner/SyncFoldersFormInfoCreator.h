//
//  SyncFoldersFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormInfoCreator.h"

@class EmailAccount;

@interface SyncFoldersFormInfoCreator : NSObject <FormInfoCreator> {
	@private
		EmailAccount *emailAcct;
}

@property(nonatomic,retain) EmailAccount *emailAcct;

-(id)initWithEmailAcct:(EmailAccount*)theAcct;

@end
