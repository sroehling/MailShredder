//
//  MessageFilterTableFooterController.h
//
//  Created by Steve Roehling on 7/20/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "TableFooterController.h"

@class MessageFilter;
@class FormContext;
@class WEPopoverController;

@interface MessageFilterTableFooterController : TableFooterController
{
	@private
		MessageFilter *messageFilter;
		FormContext *parentContext;
		WEPopoverController *filterOptionsPopupController;

}

@property(nonatomic,retain) MessageFilter *messageFilter;
@property(nonatomic,retain) FormContext *parentContext;
@property(nonatomic,retain) WEPopoverController *filterOptionsPopupController;

-(id)initWithMessageFilter:(MessageFilter*)theMessageFilter 
	andParentContext:(FormContext*)theParentContext;



@end
