//
//  MessageFilterTableHeader.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilterTableHeader.h"

#import "ColorHelper.h"
#import "TableCellHelper.h"
#import "UIHelper.h"

static CGFloat kLeftMargin = 6.0;
static CGFloat kRightMargin = 6.0;
static CGFloat kTopMargin = 4.0;
static CGFloat kBottomMargin = 4.0;
static CGFloat kLabelSpace = 4.0;
static CGFloat kButtonWidth = 24.0;
static CGFloat kButtonHeight = 24.0;

@implementation MessageFilterTableHeader

@synthesize header;
@synthesize subTitle;
@synthesize editFilterButton;
@synthesize loadFilterButton;
@synthesize delegate;

- (id)initWithDelegate:(id<MessageFilterTableHeaderDelegate>)theDelegate
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
		self.backgroundColor = [ColorHelper tableHeaderBackgroundColor];


        self.header =[[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		self.header.backgroundColor = [UIColor clearColor];
        self.header.opaque = NO;
        self.header.textColor = [UIColor blackColor];
		self.header.textAlignment = UITextAlignmentCenter;
        self.header.highlightedTextColor = [UIColor whiteColor];
        self.header.font = [UIFont boldSystemFontOfSize:12];       
		[self addSubview:self.header];
		
		self.subTitle = [TableCellHelper createWrappedSubtitleLabel];
		self.subTitle.textColor = [UIColor whiteColor];
		self.subTitle.textAlignment = UITextAlignmentCenter;
		[self addSubview:self.subTitle];
		

		self.delegate = theDelegate;
		
		self.editFilterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.editFilterButton.backgroundColor = [UIColor clearColor];

		[self.editFilterButton setBackgroundImage:[UIHelper stretchableButtonImage:@"search.png"] 
				forState:UIControlStateNormal];
		[self.editFilterButton setBackgroundImage:nil forState:UIControlStateHighlighted];	
       [self.editFilterButton addTarget:self.delegate 
				action:@selector(messageFilterHeaderEditFilterButtonPressed) 
                     forControlEvents:UIControlEventTouchUpInside];
        // add button to right corner of section        
        [self addSubview:self.editFilterButton];
		
		self.loadFilterButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		self.loadFilterButton.backgroundColor = [UIColor clearColor];
		[self.loadFilterButton setBackgroundImage:[UIHelper stretchableButtonImage:@"loadfilter.png"] 
				forState:UIControlStateNormal];
		[self.loadFilterButton setBackgroundImage:nil forState:UIControlStateHighlighted];	
		[self.loadFilterButton addTarget:self.delegate 
				action:@selector(messageFilterHeaderLoadFilterButtonPressed) 
                     forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.loadFilterButton];
    }
    return self;
}


- (id) initWithFrame:(CGRect)frame
{
    assert(0);
	return nil;
}

- (id) init 
{
    assert(0);
	return nil;
}

- (void)dealloc
{
	[header release];
	[subTitle release];
	[editFilterButton release];
	[loadFilterButton release];
    [super dealloc];
}


- (CGFloat)subTitleWidth
{
	CGSize constraintSize =CGSizeMake([UIScreen mainScreen].bounds.size.width, MAXFLOAT);
	return constraintSize.width - kLeftMargin - kRightMargin - 2.0*kButtonWidth - 2.0*kLabelSpace;

}

- (CGFloat)subTitleHeight
{
	
	CGSize maxSize = CGSizeMake([self subTitleWidth], 150);
	
	CGSize subTitleSize = [self.subTitle.text sizeWithFont:self.subTitle.font
			constrainedToSize:maxSize lineBreakMode:self.subTitle.lineBreakMode];
			
	return subTitleSize.height;

}


- (void)resizeForChildren
{
	[self.header sizeToFit];   
	CGFloat headerHeight = CGRectGetHeight(self.header.bounds);
		
	if([subTitle.text length] > 0)
	{
		headerHeight += kLabelSpace;
		headerHeight += [self subTitleHeight];
	}
	
	CGFloat newHeight = kTopMargin + headerHeight + kBottomMargin;
		
	CGRect frame = self.frame;
	frame.size.height = newHeight;
	
	self.frame = frame;
}

-(void) layoutSubviews {    
	
	[super layoutSubviews];    
		
	CGRect buttonFrame = self.editFilterButton.frame;
	buttonFrame.size.width = kButtonWidth;
	buttonFrame.size.height = kButtonHeight;
	buttonFrame.origin.x = CGRectGetMaxX(self.bounds)- kRightMargin-kButtonWidth;
	buttonFrame.origin.y = CGRectGetMidY(self.bounds)-buttonFrame.size.height/2.0;
	[self.editFilterButton setFrame:buttonFrame];
	
	buttonFrame = self.loadFilterButton.frame;
	buttonFrame.size.width = kButtonWidth;
	buttonFrame.size.height = kButtonHeight;
	buttonFrame.origin.x = kLeftMargin;
	buttonFrame.origin.y = CGRectGetMidY(self.bounds)-buttonFrame.size.height/2.0;
	[self.loadFilterButton setFrame:buttonFrame];
	
	// Position the labels at the top of the table cell    
	[self.header sizeToFit];      
	CGRect headerFrame = self.header.frame;    
	headerFrame.size.width = CGRectGetWidth(self.bounds) - 2.0*kButtonWidth - kRightMargin - kLabelSpace;
	headerFrame.origin.x =CGRectGetMidX(self.bounds) - headerFrame.size.width/2.0;
	headerFrame.origin.y =kTopMargin;
	[self.header setFrame: headerFrame];


	CGFloat subTitleWidth = [self subTitleWidth];
	CGFloat subTitleX = CGRectGetMidX(self.bounds) - subTitleWidth/2.0;
	CGFloat subTitleY = CGRectGetMaxY(self.header.bounds)+kLabelSpace;
	CGRect subTitleFrame = CGRectMake(subTitleX, subTitleY, subTitleWidth,
						[self subTitleHeight]);
	[self.subTitle setFrame:subTitleFrame];
	

	
}



@end
