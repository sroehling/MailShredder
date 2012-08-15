//
//  MsgDetailViewController.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgDetailViewController.h"

#import "MsgDetailView.h"
#import "EmailInfo.h"
#import "MailSyncConnectionContext.h"
#import "GetMessageBodyOperation.h"
#import "LocalizationHelper.h"

@implementation MsgDetailViewController

@synthesize detailView;
@synthesize mainThreadDmc;
@synthesize getBodyOperationQueue;
@synthesize emailInfo;

- (id)initWithEmailInfo:(EmailInfo*)theEmailInfo 
		andMainThreadDmc:(DataModelController*)theMainThreadDmc
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
		
		self.mainThreadDmc = theMainThreadDmc;
		
		
		self.emailInfo = theEmailInfo;
		
		self.getBodyOperationQueue = [[[NSOperationQueue alloc] init] autorelease];
		
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.detailView = [[[MsgDetailView alloc] initWithFrame:CGRectZero] autorelease];
		[self.detailView configureView:self.emailInfo];
		self.view = self.detailView;
		
	self.title = LOCALIZED_STR(@"MSG_DETAIL_VIEW_TITLE");
	

	
	MailSyncConnectionContext *syncConnectionContext = [[[MailSyncConnectionContext alloc]
		initWithMainThreadDmc:self.mainThreadDmc
		andProgressDelegate:self] autorelease];
		
	GetMessageBodyOperation *getMsgOperation = [[[GetMessageBodyOperation alloc] 
		initWithEmailInfo:self.emailInfo andConnectionContext:syncConnectionContext
		andGetMsgBodyDelegate:self] autorelease];
		
	[self.getBodyOperationQueue addOperation:getMsgOperation];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
	[detailView release];
	[mainThreadDmc release];
	[getBodyOperationQueue release];
	[emailInfo release];
	
	[super dealloc];
}

-(void)connectFailedAlert
{
	[self.detailView messageBodyFailedToLoad];
	UIAlertView *syncFailedAlert = [[[UIAlertView alloc] initWithTitle:
			LOCALIZED_STR(@"MESSAGE_SYNC_FAILURE_ALERT_TITLE")
		message:LOCALIZED_STR(@"MESSAGE_SYNC_FAILURE_ALERT_MSG") delegate:self 
		cancelButtonTitle:LOCALIZED_STR(@"MESSAGE_SYNC_FAILURE_ALERT_BUTTON_TITLE") 
		otherButtonTitles:nil] autorelease];
	[syncFailedAlert show];
}


-(void)msgBodyRetrievalFailedAlert
{
	[self.detailView messageBodyFailedToLoad];
    UIAlertView *failureAlert = [[[UIAlertView alloc] initWithTitle:
            LOCALIZED_STR(@"MSG_DETAIL_BODY_RETRIEVAL_FAILED_ALERT_TITLE")
        message:LOCALIZED_STR(@"MSG_DETAIL_BODY_RETRIEVAL_FAILED_ALERT_MSG") delegate:self 
        cancelButtonTitle:LOCALIZED_STR(@"MESSAGE_SYNC_FAILURE_ALERT_BUTTON_TITLE") 
        otherButtonTitles:nil] autorelease];
    [failureAlert show];
}

-(void)mailSyncConnectionStarted
{
	[self.detailView.bodyLoadActivity performSelectorOnMainThread:@selector(startAnimating) 
		withObject:nil waitUntilDone:TRUE];
}
-(void)mailSyncConnectionEstablished {}
-(void)mailSyncUpdateProgress:(CGFloat)percentProgress {}
-(void)mailSyncConnectionTeardownStarted {}
-(void)mailSyncConnectionTeardownFinished {}

-(void)mailSyncComplete:(BOOL)successfulCompletion 
{
	if(!successfulCompletion)
	{
		[self performSelectorOnMainThread:@selector(connectFailedAlert) withObject:nil waitUntilDone:TRUE];
		
	}
}

-(void)msgBodyRetrievalComplete:(NSString *)msgBody
{
	[self.detailView performSelectorOnMainThread:@selector(configureBody:) 
		withObject:msgBody waitUntilDone:TRUE];
}

-(void)msgBodyRetrievalFailed
{
	[self performSelectorOnMainThread:@selector(msgBodyRetrievalFailedAlert) withObject:nil waitUntilDone:TRUE];
}

@end
