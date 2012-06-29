//
//  EmailFolderSelectionFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormInfoCreator.h"

@class EmailFolderFilter;

@interface EmailFolderSelectionFormInfoCreator : NSObject  <FormInfoCreator> {
	@private
		EmailFolderFilter *emailFolderFilter;
}

@property(nonatomic,retain) EmailFolderFilter *emailFolderFilter;

-(id)initWithEmailFolderFilter:(EmailFolderFilter*)theEmailFolderFilter;


@end
