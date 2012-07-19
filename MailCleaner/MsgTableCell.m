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

const CGFloat MSG_TABLE_CELL_LEFT_MARGIN = 5.0f;
const CGFloat MSG_TABLE_CELL_TOP_MARGIN = 5.0f;
const CGFloat MSG_TABLE_CELL_RIGHT_MARGIN = 5.0f;
const CGFloat MSG_TABLE_CELL_LABEL_HORIZ_SPACE = 5.0f;

NSString *const MSG_TABLE_CELL_IDENTIFIER = @"MsgTableCell";

@implementation MsgTableCell

@synthesize sendDateLabel;
@synthesize fromLabel;
@synthesize selectedCheckbox;
@synthesize subjectLabel;



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
		self.fromLabel.highlightedTextColor = [UIColor blackColor];
		self.fromLabel.font = [UIFont boldSystemFontOfSize:13];       
		[self.contentView addSubview: self.fromLabel]; 
		
		self.sendDateLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.sendDateLabel.backgroundColor = [UIColor clearColor];
		self.sendDateLabel.opaque = NO;
		self.sendDateLabel.textColor = [ColorHelper blueTableTextColor];
		self.sendDateLabel.textAlignment = UITextAlignmentRight;
		self.sendDateLabel.highlightedTextColor = [ColorHelper blueTableTextColor];
		self.sendDateLabel.font = [UIFont systemFontOfSize:13];       
		[self.contentView addSubview:self.sendDateLabel];
		
		self.subjectLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.subjectLabel.backgroundColor = [UIColor clearColor];
		self.subjectLabel.opaque = NO;
		self.subjectLabel.textColor = [UIColor grayColor];
		self.subjectLabel.textAlignment = UITextAlignmentLeft;
		self.subjectLabel.highlightedTextColor = [UIColor darkGrayColor];
		self.subjectLabel.font = [UIFont systemFontOfSize:13];        
		self.subjectLabel.lineBreakMode = UILineBreakModeTailTruncation;
		self.subjectLabel.numberOfLines = 1;
		[self.contentView addSubview: self.subjectLabel]; 
		
		
		self.selectionStyle = UITableViewCellSelectionStyleGray;
		UIView *selBgView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		selBgView.alpha = 1.0;
		self.selectedBackgroundView = selBgView;
				
		self.selectedCheckbox = [[[UIImageView alloc] initWithFrame:CGRectMake(0,0,20,20)] autorelease];
		[self.selectedCheckbox setHighlightedImage:[UIImage imageNamed:@"selectedMsgcheckbox.png"]];
		[self.selectedCheckbox setImage:[UIImage imageNamed:@"unselectedMsgCheckbox.png"]];
		[self.contentView addSubview:self.selectedCheckbox];


	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
	[super dealloc];
}

@end
