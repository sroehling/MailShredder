//
//  MsgDetailView.m
//
//  Created by Steve Roehling on 8/13/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MsgDetailView.h"
#import "EmailInfo.h"
#import "LocalizationHelper.h"
#import "EmailAddress.h"
#import "DateHelper.h"
#import "EmailFolder.h"
#import "MsgDetailHelper.h"

CGFloat const MSG_DETAIL_VIEW_MARGIN = 4.0;
CGFloat const MSG_DETAIL_CAPTION_TEXT_SPACE = 4.0f;
CGFloat const MSG_DETAIL_HEADER_LINE_VERTICAL_SPACE = 3.0f;

@implementation MsgDetailView

@synthesize subjectCaption;
@synthesize subjectText;
@synthesize fromCaption;
@synthesize fromText;
@synthesize toCaption;
@synthesize toText;
@synthesize dateCaption;
@synthesize dateText;
@synthesize headerSeparatorLine;
@synthesize bodyView;
@synthesize bodyLoadActivity;
@synthesize folderCaption;
@synthesize folderText;


-(CGFloat)widthOfCaption:(UILabel*)captionLabel
{
	[captionLabel sizeToFit];
	return captionLabel.frame.size.width;

}

-(CGFloat)calcCaptionWidth
{
	CGFloat maxWidth = 0;
	
	CGFloat theCaptionWidth = [self widthOfCaption:self.subjectCaption];
	maxWidth = (theCaptionWidth > maxWidth)?theCaptionWidth:maxWidth;
	
	theCaptionWidth = [self widthOfCaption:self.toCaption];
	maxWidth = (theCaptionWidth > maxWidth)?theCaptionWidth:maxWidth;
	
	theCaptionWidth = [self widthOfCaption:self.dateCaption];
	maxWidth = (theCaptionWidth > maxWidth)?theCaptionWidth:maxWidth;

	theCaptionWidth = [self widthOfCaption:self.fromCaption];
	maxWidth = (theCaptionWidth > maxWidth)?theCaptionWidth:maxWidth;

	theCaptionWidth = [self widthOfCaption:self.folderCaption];
	maxWidth = (theCaptionWidth > maxWidth)?theCaptionWidth:maxWidth;

	
	return maxWidth;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.subjectCaption = [MsgDetailHelper msgHeaderCaptionLabel];
		[self addSubview:self.subjectCaption];
		
		self.subjectText = [MsgDetailHelper msgHeaderTextLabel];
		[self addSubview:self.subjectText];
		
		self.fromCaption = [MsgDetailHelper msgHeaderCaptionLabel];
		[self addSubview:self.fromCaption];
		
		self.fromText = [MsgDetailHelper msgHeaderTextLabel];
		[self addSubview:fromText];
		
		self.toText = [MsgDetailHelper msgHeaderTextLabel];
		[self addSubview:toText];
		
		self.toCaption = [MsgDetailHelper msgHeaderCaptionLabel];
		[self addSubview:toCaption];
		
		self.dateCaption = [MsgDetailHelper msgHeaderCaptionLabel];
		[self addSubview:self.dateCaption];
		
		self.dateText = [MsgDetailHelper msgHeaderTextLabel];
		[self addSubview:self.dateText];
		
		self.folderCaption = [MsgDetailHelper msgHeaderCaptionLabel];
		[self addSubview:self.folderCaption];
		
		self.folderText = [MsgDetailHelper msgHeaderTextLabel];
		[self addSubview:self.folderText];
		
		
		self.subjectCaption.text = LOCALIZED_STR(@"MESSAGE_DETAIL_SUBJECT_CAPTION");
		self.fromCaption.text = LOCALIZED_STR(@"MESSAGE_DETAIL_FROM_CAPTION");
		self.toCaption.text = LOCALIZED_STR(@"MESSAGE_DETAIL_TO_CAPTION");
		self.dateCaption.text = LOCALIZED_STR(@"MESSAGE_DETAIL_DATE_CAPTION");
		self.folderCaption.text = LOCALIZED_STR(@"MESSAGE_DETAIL_FOLDER_CAPTION");
		
		
		captionWidth = [self calcCaptionWidth];
		
		self.headerSeparatorLine = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
		self.headerSeparatorLine.backgroundColor = [UIColor grayColor];
		[self addSubview:self.headerSeparatorLine];
		
		self.bodyView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
		[self addSubview:self.bodyView];
		
		self.bodyLoadActivity = [[[UIActivityIndicatorView alloc]
			initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
		[self addSubview:self.bodyLoadActivity];
		
		self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


-(void)configureView:(EmailInfo*)emailInfo
{
	self.subjectText.text = emailInfo.subject;
    self.fromText.text = [emailInfo.senderAddress formattedAddress];
	self.folderText.text = emailInfo.folderInfo.folderName;
		
	self.toText.text = [EmailAddress formattedAddresses:emailInfo.recipientAddresses];
	self.dateText.text = [emailInfo formattedSendDateAndTime];

}

-(void)configureBody:(NSString*)bodyHtml
{
	[self.bodyLoadActivity stopAnimating];
	[self.bodyView loadHTMLString:bodyHtml baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

-(void)messageBodyFailedToLoad
{
	[self.bodyLoadActivity stopAnimating];
	
	[self.bodyView loadHTMLString:LOCALIZED_STR(@"MSG_DETAIL_BODY_RETRIEVAL_FAILED_BODY_PLACEHOLDER_HTML") 
		baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
	
}

-(CGFloat)layoutHeaderLineWithCaption:(UILabel*)captionLabel andText:(UILabel*)textLabel
	andCurrYOffset:(CGFloat)yOffset
{
	[captionLabel sizeToFit];
	[textLabel sizeToFit];
		
	CGRect captionFrame = captionLabel.frame;
	captionFrame.origin.x = MSG_DETAIL_VIEW_MARGIN;
	captionFrame.origin.y = yOffset;
	captionFrame.size.width = captionWidth;
	[captionLabel setFrame:captionFrame];
	
	CGFloat maxTextWidth = self.frame.size.width - captionFrame.size.width - 2 * MSG_DETAIL_VIEW_MARGIN - MSG_DETAIL_CAPTION_TEXT_SPACE;
	CGSize maxTextSize = CGSizeMake(maxTextWidth, 200);
	CGSize textSize = [textLabel.text sizeWithFont:textLabel.font
		constrainedToSize:maxTextSize lineBreakMode:textLabel.lineBreakMode];

	
	CGRect textFrame = textLabel.frame;
	textFrame.origin.x = captionFrame.size.width + MSG_DETAIL_VIEW_MARGIN + MSG_DETAIL_CAPTION_TEXT_SPACE;
	textFrame.origin.y = yOffset;
	textFrame.size.width = textSize.width;
	textFrame.size.height = textSize.height;
	[textLabel setFrame:textFrame];
	
	CGFloat headerLineHeight = MAX(CGRectGetHeight(textFrame),CGRectGetHeight(captionFrame));
	
	return headerLineHeight;
}

-(void)layoutSubviews
{
	[super layoutSubviews];
	
	CGFloat currYOffset = MSG_DETAIL_VIEW_MARGIN;
	
	CGFloat headerLineHeight = [self layoutHeaderLineWithCaption:self.fromCaption 
		andText:self.fromText andCurrYOffset:currYOffset];

	currYOffset += headerLineHeight + MSG_DETAIL_HEADER_LINE_VERTICAL_SPACE;
	
	headerLineHeight = [self layoutHeaderLineWithCaption:self.dateCaption 
		andText:self.dateText andCurrYOffset:currYOffset];
	
	currYOffset += headerLineHeight + MSG_DETAIL_HEADER_LINE_VERTICAL_SPACE;
	
	headerLineHeight = [self layoutHeaderLineWithCaption:self.toCaption 
		andText:self.toText andCurrYOffset:currYOffset];
	
	currYOffset += headerLineHeight + MSG_DETAIL_HEADER_LINE_VERTICAL_SPACE;
	
	headerLineHeight = [self layoutHeaderLineWithCaption:self.subjectCaption 
		andText:self.subjectText andCurrYOffset:currYOffset];

	currYOffset += headerLineHeight + MSG_DETAIL_HEADER_LINE_VERTICAL_SPACE;
	
	headerLineHeight = [self layoutHeaderLineWithCaption:self.folderCaption 
		andText:self.folderText andCurrYOffset:currYOffset];
		
	currYOffset += headerLineHeight + MSG_DETAIL_HEADER_LINE_VERTICAL_SPACE;
	
	CGRect headerSeparatorRect = self.headerSeparatorLine.frame;
	headerSeparatorLine.backgroundColor = [UIColor darkGrayColor];
	headerSeparatorRect.size.width = self.frame.size.width - 2.0 * MSG_DETAIL_VIEW_MARGIN;
	headerSeparatorRect.size.height = 1.5;
	headerSeparatorRect.origin.x = MSG_DETAIL_VIEW_MARGIN;
	headerSeparatorRect.origin.y = currYOffset;
	[self.headerSeparatorLine setFrame:headerSeparatorRect];
	
	currYOffset += MSG_DETAIL_HEADER_LINE_VERTICAL_SPACE;
	
		
	CGRect bodyRect = bodyView.frame;
	bodyRect.size.width = self.frame.size.width;
	CGFloat remainingHeight = self.frame.size.height - currYOffset;
	bodyRect.size.height = MAX(remainingHeight,150.0f);
	bodyRect.origin.x = 0.0;
	bodyRect.origin.y = currYOffset;
	[self.bodyView setFrame:bodyRect];
	
	[self.bodyLoadActivity setFrame:bodyRect];
	
}

-(void)dealloc
{
	[subjectText release];
	[subjectCaption release];
	
	[fromCaption release];
	[fromText release];
	
	[toCaption release];
	[toText release];
	
	[dateCaption release];
	[dateText release];
	
	[folderCaption release];
	[folderText release];
	
	[headerSeparatorLine release];
	
	[bodyView release];
	[bodyLoadActivity release];
	
	[super dealloc];
}

@end
