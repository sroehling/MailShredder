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
		UIImageView *lockedIndicator;
		UIImageView *trashIndicator;
		UILabel *subjectlabel;
}

@property(nonatomic,retain) UILabel *sendDateLabel;
@property(nonatomic,retain) UILabel *fromLabel;
@property(nonatomic,retain) UIImageView *selectedCheckbox;
@property(nonatomic,retain) UIImageView *lockedIndicator;
@property(nonatomic,retain) UIImageView *trashIndicator;
@property(nonatomic,retain) UILabel *subjectLabel;

@end
