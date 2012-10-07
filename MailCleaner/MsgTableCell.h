//
//  MsgTableCell.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const MSG_TABLE_CELL_IDENTIFIER;

@interface MsgTableCell : UITableViewCell {
	@private
		UILabel *sendDateLabel;
		UILabel *fromLabel;
		UIImageView *selectedCheckbox;
		UILabel *subjectLabel;
		UIImageView *msgFlag;
}

@property(nonatomic,retain) UILabel *sendDateLabel;
@property(nonatomic,retain) UILabel *fromLabel;
@property(nonatomic,retain) UIImageView *selectedCheckbox;
@property(nonatomic,retain) UILabel *subjectLabel;
@property(nonatomic,retain) UIImageView *msgFlag;

-(void)configureForMsgRead:(BOOL)msgIsRead;
-(void)configureForMsgFlagged:(BOOL)msgIsFlagged;

@end
