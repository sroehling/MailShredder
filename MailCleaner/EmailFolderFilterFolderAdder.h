//
//  EmailFolderFilterFolderAdder.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TableViewObjectAdder.h"
#import "MultipleSelectionAddViewController.h"

@class EmailFolderFilter;

@interface EmailFolderFilterFolderAdder : NSObject 
	<TableViewObjectAdder,MultipleSelectionAddListener> 
{
	@private
		EmailFolderFilter *emailFolderFilter;
}

@property(nonatomic,retain) EmailFolderFilter *emailFolderFilter;

-(id)initWithEmailFolderFilter:(EmailFolderFilter*)theFolderFilter;

@end
