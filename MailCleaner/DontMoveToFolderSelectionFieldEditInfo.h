//
//  DontMoveToFolderSelectionFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "StaticFieldEditInfo.h"

@interface DontMoveToFolderSelectionFieldEditInfo : StaticFieldEditInfo
{
	@private
		BOOL isSelectedForTableView;
}

@end
