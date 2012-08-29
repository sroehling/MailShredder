//
//  SyncFolderSelectionFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StaticFieldEditInfo.h"

@class EmailAccount;
@class EmailFolder;

@interface SyncFolderSelectionFieldEditInfo : StaticFieldEditInfo {
	@private
		EmailFolder *emailFolder;
		EmailAccount *emailAcct;
}

@property(nonatomic,retain) EmailFolder *emailFolder;
@property(nonatomic,retain) EmailAccount *emailAcct;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct andFolder:(EmailFolder*)theEmailFolder;

@end
