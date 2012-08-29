//
//  MoveToFolderSelectionFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StaticFieldEditInfo.h"

@class EmailFolder;

@interface MoveToFolderSelectionFieldEditInfo : StaticFieldEditInfo
{
	@private
		EmailFolder* emailFolder;
}

@property(nonatomic,retain) EmailFolder* emailFolder;

-(id)initWithEmailFolder:(EmailFolder*)theEmailFolder;

@end
