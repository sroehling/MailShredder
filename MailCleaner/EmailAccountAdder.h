//
//  EmailAccountAdder.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TableViewObjectAdder.h"
#import "GenericFieldBasedTableAddViewController.h"

@class FormContext;
@class ImapAcctPresets;

@interface EmailAccountAdder : NSObject <TableViewObjectAdder,GenericTableAddViewSaveCompleteDelegate>
{
	@private
		FormContext *currParentContext;
		ImapAcctPresets *emailAcctPresets;
		id<GenericTableAddViewSaveCompleteDelegate> acctSaveCompleteDelegate;
		NSInteger currentStep;
}

@property(nonatomic,retain) FormContext *currParentContext;
@property(nonatomic,retain) ImapAcctPresets *emailAcctPresets;
@property(nonatomic, assign) id<GenericTableAddViewSaveCompleteDelegate> acctSaveCompleteDelegate; // optional

-(GenericFieldBasedTableAddViewController*)addViewControllerForNewAccountAddr:
	(DataModelController*)dmcForNewAcct;

@end
