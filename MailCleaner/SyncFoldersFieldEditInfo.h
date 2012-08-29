//
//  SyncFoldersFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StaticNavFieldEditInfo.h"

@class EmailAccount;

@interface SyncFoldersFieldEditInfo : StaticNavFieldEditInfo
{
	@private
		EmailAccount* emailAcct;
}

@property(nonatomic,retain) EmailAccount* emailAcct;

-(id)initWithEmailAcct:(EmailAccount*) emailAcct;

@end
