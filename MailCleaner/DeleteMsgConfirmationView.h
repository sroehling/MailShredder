//
//  DeleteMsgConfirmationView.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataModelController;

@interface DeleteMsgConfirmationView : UIView
{
	@private
		UIButton *deleteButton;
		UIButton *skipButton;
		UIButton *cancelButton;

		UILabel *sendDateLabel;
		UILabel *fromLabel;
		UILabel *subjectlabel;
		
		UIView *msgDisplayView;
		
		NSArray *msgsToDelete;
		NSUInteger currentMsgIndex;
		NSMutableSet *msgsConfirmedForDeletion;
		
		DataModelController *emailInfoDmc;
		DataModelController *appDmc;

}

@property(nonatomic,retain) UIButton *cancelButton;
@property(nonatomic,retain) UIButton *deleteButton;
@property(nonatomic,retain) UIButton *skipButton;

@property(nonatomic,retain) UILabel *sendDateLabel;
@property(nonatomic,retain) UILabel *fromLabel;
@property(nonatomic,retain) UILabel *subjectLabel;
@property(nonatomic,retain) UIView *msgDisplayView;

@property(nonatomic,retain) NSArray *msgsToDelete;
@property(nonatomic,retain) NSMutableSet *msgsConfirmedForDeletion;

@property(nonatomic,retain) DataModelController *emailInfoDmc;
@property(nonatomic,retain) DataModelController *appDmc;


- (id)initWithFrame:(CGRect)frame andMsgsToDelete:(NSArray*)theMsgsToDelete
	andEmailInfoDataModelController:(DataModelController*)theEmailInfoDmc
	andAppDataModelController:(DataModelController*)theAppDmc;


@end


