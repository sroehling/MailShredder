//
//  EmailFolderFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "StaticFieldEditInfo.h"

@class EmailFolder;
@class EmailFolderFilter;

@interface EmailFolderFieldEditInfo : StaticFieldEditInfo
{
	@private
		EmailFolder* emailFolder;
		EmailFolderFilter *parentFilter; // optional
}

@property(nonatomic,retain) EmailFolder* emailFolder;
@property(nonatomic,retain) EmailFolderFilter *parentFilter;

-(id)initWithEmailFolder:(EmailFolder*)theEmailFolder;

@end
