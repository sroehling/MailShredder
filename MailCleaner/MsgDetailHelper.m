//
//  MsgDetailHelper.m
//
//  Created by Steve Roehling on 9/11/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MsgDetailHelper.h"

@implementation MsgDetailHelper

CGFloat const MSG_DETAIL_FONT_SIZE = 14.0;

+(UILabel*)msgHeaderCaptionLabel
{
	UILabel *captionLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	
	captionLabel.backgroundColor = [UIColor clearColor];
	captionLabel.opaque = NO;
	captionLabel.textColor = [UIColor darkGrayColor];
	captionLabel.textAlignment = NSTextAlignmentRight;
	captionLabel.highlightedTextColor = [UIColor darkGrayColor];
	captionLabel.font = [UIFont boldSystemFontOfSize:MSG_DETAIL_FONT_SIZE];        
	captionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
	captionLabel.numberOfLines = 1;
	
	return captionLabel;
}

+(UILabel*)msgHeaderTextLabel
{
	UILabel *textLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
	
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.opaque = NO;
	textLabel.textColor = [UIColor grayColor];
	textLabel.textAlignment = NSTextAlignmentLeft;
	textLabel.highlightedTextColor = [UIColor grayColor];
	textLabel.font = [UIFont systemFontOfSize:MSG_DETAIL_FONT_SIZE];        
	textLabel.lineBreakMode = NSLineBreakByWordWrapping;
	textLabel.numberOfLines = 0;
	
	return textLabel;

}



@end
