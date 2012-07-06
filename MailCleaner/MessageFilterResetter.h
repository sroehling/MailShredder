//
//  MessageFilterResetter.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SingleButtonTableFooter.h"

#import "TableFooterController.h"


@class MessageFilter;
@class GenericFieldBasedTableViewController;
@class DataModelController;

@interface MessageFilterResetter : TableFooterController <TableFooterButtonDelegate>
{
	@private
		MessageFilter *messageFilter;
		DataModelController *filterDmc;

}

@property(nonatomic,retain) MessageFilter *messageFilter;
@property(nonatomic,retain) DataModelController *filterDmc;

-(id)initWithMessageFilter:(MessageFilter*)theMessageFilter 
	andFilterDataModelController:(DataModelController*)theFilterDmc;

@end
