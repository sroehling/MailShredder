//
//  EmailAddressFilterAddressAdder.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewObjectAdder.h"
#import "MultipleSelectionAddViewController.h"

@class EmailAddressFilter;

@interface EmailAddressFilterAddressAdder : NSObject 
	<TableViewObjectAdder,MultipleSelectionAddListener> 
{
	@private
		EmailAddressFilter *emailAddressFilter;
}

@property(nonatomic,retain) EmailAddressFilter *emailAddressFilter;

-(id)initWithEmailAddressFilter:(EmailAddressFilter*)theAddressFilter;

@end
