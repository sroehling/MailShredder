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
		UIButton *deleteAllButton;
		UIButton *skipButton;
		UIButton *cancelButton;

		UILabel *sendDateLabel;
		UILabel *sendDateCaption;
		
		UILabel *fromLabel;
		UILabel *fromCaption;

		UILabel *subjectlabel;
		UILabel *subjectCaption;
		
		UIView *msgDisplayView;
		
		NSArray *msgsToDelete;
		NSUInteger currentMsgIndex;
		NSMutableSet *msgsConfirmedForDeletion;
		
		DataModelController *appDmc;

}

@property(nonatomic,retain) UIButton *cancelButton;
@property(nonatomic,retain) UIButton *deleteButton;
@property(nonatomic,retain) UIButton *deleteAllButton;
@property(nonatomic,retain) UIButton *skipButton;

@property(nonatomic,retain) UILabel *sendDateLabel;
@property(nonatomic,retain) UILabel *sendDateCaption;

@property(nonatomic,retain) UILabel *fromLabel;
@property(nonatomic,retain) UILabel *fromCaption;

@property(nonatomic,retain) UILabel *subjectLabel;
@property(nonatomic,retain) UILabel *subjectCaption;

@property(nonatomic,retain) UIView *msgDisplayView;

@property(nonatomic,retain) NSArray *msgsToDelete;
@property(nonatomic,retain) NSMutableSet *msgsConfirmedForDeletion;

@property(nonatomic,retain) DataModelController *appDmc;


- (id)initWithFrame:(CGRect)frame andMsgsToDelete:(NSArray*)theMsgsToDelete
	andAppDataModelController:(DataModelController*)theAppDmc;


@end


