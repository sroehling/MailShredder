//
//  MsgDetailViewController.h
//  MailCleaner
//
//  Created by Steve Roehling on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MailSyncProgressDelegate.h"
#import "GetMessageBodyOperation.h"

@class EmailInfo;

@class MsgDetailView;
@class DataModelController;

@interface MsgDetailViewController : UIViewController <MailSyncProgressDelegate,GetMessageBodyDelegate>
{
	@private
		MsgDetailView *detailView;
		DataModelController *mainThreadDmc;
		EmailInfo *emailInfo;
}

@property(nonatomic,retain) MsgDetailView *detailView;
@property(nonatomic,retain) EmailInfo *emailInfo;
@property(nonatomic,retain) DataModelController *mainThreadDmc;

- (id)initWithEmailInfo:(EmailInfo*)theEmailInfo 
		andMainThreadDmc:(DataModelController*)theMainThreadDmc;

@end
