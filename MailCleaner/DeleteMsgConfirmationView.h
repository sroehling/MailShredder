//
//  DeleteMsgConfirmationView.h
//
//  Created by Steve Roehling on 7/19/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DataModelController;

@protocol DeleteMsgConfirmationViewDelegate;

@interface DeleteMsgConfirmationView : UIView
{
	@private
	
		UILabel *confirmationTitle;
	
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
		
		UILabel *currentMsgNumber;
		
		UIView *msgDisplayView;
		
		NSArray *msgsToDelete;
		NSUInteger currentMsgIndex;
		NSMutableSet *msgsConfirmedForDeletion;
		
		UIImageView *backgroundImage;
		
		DataModelController *appDmc;
		
		id<DeleteMsgConfirmationViewDelegate> delegate;

}

@property(nonatomic,retain) UILabel *confirmationTitle;

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

@property(nonatomic,retain) UILabel *currentMsgNumber;

@property(nonatomic,retain) UIView *msgDisplayView;

@property(nonatomic,retain) UIImageView *backgroundImage;

@property(nonatomic,retain) NSArray *msgsToDelete;
@property(nonatomic,retain) NSMutableSet *msgsConfirmedForDeletion;

@property(nonatomic,retain) DataModelController *appDmc;

@property(nonatomic,assign) id<DeleteMsgConfirmationViewDelegate> delegate;


- (id)initWithFrame:(CGRect)frame andMsgsToDelete:(NSArray*)theMsgsToDelete
	andAppDataModelController:(DataModelController*)theAppDmc
	andDelegate:(id<DeleteMsgConfirmationViewDelegate>)deleteDelegate;

-(void)showWithAnimation;

@end

@protocol DeleteMsgConfirmationViewDelegate <NSObject>

-(void)msgsConfirmedForDeletion:(NSSet*)confirmedMsgs;


@end


