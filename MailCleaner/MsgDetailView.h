//
//  MsgDetailView.h
//
//  Created by Steve Roehling on 8/13/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmailInfo;

@interface MsgDetailView : UIView
{
	@private
		UILabel *subjectCaption;
		UILabel *subjectText;
		
		UILabel *fromCaption;
		UILabel *fromText;
		
		UILabel *toCaption;
		UILabel *toText;
		
		UILabel *dateCaption;
		UILabel *dateText;
		
		UILabel *folderCaption;
		UILabel *folderText;
		
		UIView *headerSeparatorLine;
				
		UIWebView *bodyView;
		UIActivityIndicatorView *bodyLoadActivity;
		
		CGFloat captionWidth;
}

@property(nonatomic,retain) UILabel *subjectCaption;
@property(nonatomic,retain) UILabel *subjectText;

@property(nonatomic,retain) UILabel *fromCaption;
@property(nonatomic,retain) UILabel *fromText;

@property(nonatomic,retain) UILabel *toCaption;
@property(nonatomic,retain) UILabel *toText;

@property(nonatomic,retain) UILabel *dateCaption;
@property(nonatomic,retain) UILabel *dateText;

@property(nonatomic,retain) UILabel *folderCaption;
@property(nonatomic,retain) UILabel *folderText;

@property(nonatomic,retain) UIView *headerSeparatorLine;

@property(nonatomic,retain) UIWebView *bodyView;
@property(nonatomic,retain) UIActivityIndicatorView *bodyLoadActivity;

-(void)configureView:(EmailInfo*)emailInfo;

// Load the message body, which is done asynchronously.
-(void)configureBody:(NSString*)bodyHtml;
-(void)messageBodyFailedToLoad;

@end
