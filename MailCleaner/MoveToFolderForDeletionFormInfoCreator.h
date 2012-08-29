//
//  MoveToFolderForDeletionFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FormInfoCreator.h"

@class EmailAccount;
@class DontMoveToFolderSelectionFieldEditInfo;

@interface MoveToFolderForDeletionFormInfoCreator : NSObject  <FormInfoCreator> {
	@private
		EmailAccount *emailAcct;
		DontMoveToFolderSelectionFieldEditInfo *dontMoveFieldEditInfo;
}

@property(nonatomic,retain) EmailAccount *emailAcct;
@property(nonatomic,retain) DontMoveToFolderSelectionFieldEditInfo *dontMoveFieldEditInfo;

-(id)initWithEmailAcct:(EmailAccount*)theAcct;

@end
