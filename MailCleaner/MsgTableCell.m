//
//  MsgTableCell.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgTableCell.h"
#import "TableCellHelper.h"
#import "ColorHelper.h"

CGFloat const MSG_TABLE_CELL_LEFT_MARGIN = 5.0f;
CGFloat const MSG_TABLE_CELL_TOP_MARGIN = 5.0f;
CGFloat const MSG_TABLE_CELL_RIGHT_MARGIN = 5.0f;
CGFloat const MSG_TABLE_CELL_LABEL_HORIZ_SPACE = 5.0f;
CGFloat const MSG_TABLE_CELL_HEADER_FONT_SIZE = 13.0f;

NSString *const MSG_TABLE_CELL_IDENTIFIER = @"MsgTableCell";

@implementation MsgTableCell

@synthesize sendDateLabel;
@synthesize fromLabel;
@synthesize selectedCheckbox;
@synthesize subjectLabel;
@synthesize msgFlag;



-(id)init
{
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MSG_TABLE_CELL_IDENTIFIER];
	if(self)
	{
		self.fromLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];       
		self.fromLabel.backgroundColor = [UIColor clearColor];
		self.fromLabel.opaque = NO;
		self.fromLabel.textColor = [UIColor blackColor];
		self.fromLabel.textAlignment = UITextAlignmentLeft;
		self.fromLabel.font = [UIFont systemFontOfSize:MSG_TABLE_CELL_HEADER_FONT_SIZE];
		[self.contentView addSubview: self.fromLabel]; 
		
		self.sendDateLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.sendDateLabel.backgroundColor = [UIColor clearColor];
		self.sendDateLabel.opaque = NO;
		self.sendDateLabel.textColor = [ColorHelper blueTableTextColor];
		self.sendDateLabel.textAlignment = UITextAlignmentRight;
		self.sendDateLabel.highlightedTextColor = [ColorHelper blueTableTextColor];
		self.sendDateLabel.font = [UIFont systemFontOfSize:MSG_TABLE_CELL_HEADER_FONT_SIZE];       
		[self.contentView addSubview:self.sendDateLabel];
		
		// TODO - Add icon for flag
		
		self.subjectLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.subjectLabel.backgroundColor = [UIColor clearColor];
		self.subjectLabel.opaque = NO;
		self.subjectLabel.textColor = [UIColor blackColor];
		self.subjectLabel.textAlignment = UITextAlignmentLeft;
		self.subjectLabel.font = [UIFont systemFontOfSize:MSG_TABLE_CELL_HEADER_FONT_SIZE];        
		self.subjectLabel.lineBreakMode = UILineBreakModeTailTruncation;
		self.subjectLabel.numberOfLines = 1;
		[self.contentView addSubview: self.subjectLabel];
		
		self.msgFlag = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,12,12)] autorelease];
		[self.msgFlag setImage:[UIImage imageNamed:@"msgflag.png"]];
		[self.contentView addSubview:self.msgFlag];
		
		
		self.selectionStyle = UITableViewCellSelectionStyleGray;
		UIView *selBgView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		selBgView.alpha = 1.0;
		self.selectedBackgroundView = selBgView;
				
		self.selectedCheckbox = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20)] autorelease];
		[self.selectedCheckbox setHighlightedImage:[UIImage imageNamed:@"checkboxselected.png"]];
		[self.selectedCheckbox setImage:[UIImage imageNamed:@"checkbox.png"]];
		[self.contentView addSubview:self.selectedCheckbox];


	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureForMsgRead:(BOOL)msgIsRead
{
	if(msgIsRead)
	{
		self.fromLabel.font = [UIFont systemFontOfSize:MSG_TABLE_CELL_HEADER_FONT_SIZE];
		self.fromLabel.textColor = [UIColor darkGrayColor];

		self.subjectLabel.font = [UIFont systemFontOfSize:MSG_TABLE_CELL_HEADER_FONT_SIZE];
		self.subjectLabel.textColor = [UIColor grayColor];
	}
	else
	{
		self.fromLabel.font = [UIFont boldSystemFontOfSize:MSG_TABLE_CELL_HEADER_FONT_SIZE];
		self.fromLabel.textColor = [UIColor blackColor];
		
		self.subjectLabel.font = [UIFont boldSystemFontOfSize:MSG_TABLE_CELL_HEADER_FONT_SIZE];
		self.subjectLabel.textColor = [UIColor darkGrayColor];

	}
}

-(void)configureForMsgFlagged:(BOOL)msgIsFlagged
{
	self.msgFlag.hidden = msgIsFlagged?FALSE:TRUE;
}


-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGRect contentFrame = self.contentView.frame;
	
	CGRect checkboxFrame = self.selectedCheckbox.frame;
	checkboxFrame.origin.x = MSG_TABLE_CELL_LEFT_MARGIN;
	checkboxFrame.origin.y = contentFrame.size.height/2.0 - checkboxFrame.size.height/2.0;
	[self.selectedCheckbox setFrame:checkboxFrame];
	
	[self.sendDateLabel sizeToFit];
	CGRect sendDateFrame = self.sendDateLabel.frame;
	sendDateFrame.origin.y = MSG_TABLE_CELL_TOP_MARGIN;
	sendDateFrame.origin.x = contentFrame.size.width - MSG_TABLE_CELL_RIGHT_MARGIN - sendDateFrame.size.width;
	[self.sendDateLabel setFrame:sendDateFrame];
	
	[self.fromLabel sizeToFit];
	CGRect fromFrame = self.fromLabel.frame;
	fromFrame.origin.x = checkboxFrame.origin.x + checkboxFrame.size.width + MSG_TABLE_CELL_LABEL_HORIZ_SPACE;
	fromFrame.origin.y = MSG_TABLE_CELL_TOP_MARGIN;
	fromFrame.size.width = sendDateFrame.origin.x - fromFrame.origin.x - 2*MSG_TABLE_CELL_LABEL_HORIZ_SPACE;
	[self.fromLabel setFrame:fromFrame];
	
	CGFloat secondRowYStart = MAX(sendDateFrame.origin.y + sendDateFrame.size.height,
		fromFrame.origin.y + fromFrame.size.height) + 2;
		
	CGRect flagFrame = self.msgFlag.frame;
	flagFrame.origin.x = contentFrame.size.width - MSG_TABLE_CELL_RIGHT_MARGIN - flagFrame.size.width;
	flagFrame.origin.y = secondRowYStart;
	[self.msgFlag setFrame:flagFrame];
	
	[self.subjectLabel sizeToFit];
	CGRect subjectFrame = self.subjectLabel.frame;
	subjectFrame.origin.x = fromFrame.origin.x;
	subjectFrame.origin.y = secondRowYStart;
	subjectFrame.size.width = contentFrame.size.width - MSG_TABLE_CELL_RIGHT_MARGIN - subjectFrame.origin.x;
	[self.subjectLabel setFrame:subjectFrame]; 
}

-(void)dealloc
{
	[sendDateLabel release];
	[fromLabel release];
	[selectedCheckbox release];
	[subjectLabel release];
	[msgFlag release];
	[super dealloc];
}

@end
