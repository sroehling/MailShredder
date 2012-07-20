//
//  MessageFilterTableFooterController.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableFooterController.h"

@class MessageFilter;
@class DataModelController;

@interface MessageFilterTableFooterController : TableFooterController
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
