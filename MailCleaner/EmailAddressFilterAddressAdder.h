//
//  EmailAddressFilterAddressAdder.h
//
//  Created by Steve Roehling on 6/18/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewObjectAdder.h"
#import "MultipleSelectionAddViewController.h"
#import "MultipleSelectionAddListener.h"

@class EmailAddressFilterFormInfo;

@interface EmailAddressFilterAddressAdder : NSObject 
	<TableViewObjectAdder,MultipleSelectionAddListener> 
{
	@private
		EmailAddressFilterFormInfo *emailAddressFilterFormInfo;
}

@property(nonatomic,retain) EmailAddressFilterFormInfo *emailAddressFilterFormInfo;

-(id)initWithEmailAddressFilter:(EmailAddressFilterFormInfo*)theAddressFilterFormInfo;

@end
