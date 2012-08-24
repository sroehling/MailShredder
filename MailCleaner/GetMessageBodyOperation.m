//
//  GetMessageBodyOperation.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GetMessageBodyOperation.h"
#import "EmailInfo.h"
#import "MailSyncConnectionContext.h"
#import "EmailFolder.h"

@implementation GetMessageBodyOperation

@synthesize emailInfo;
@synthesize connectionContext;
@synthesize getMsgBodyDelegate;

-(id)initWithEmailInfo:(EmailInfo*)theEmailInfo 
	andConnectionContext:(MailSyncConnectionContext*)theConnectionContext
	andGetMsgBodyDelegate:(id<GetMessageBodyDelegate>) msgBodyDelegate
{
	self = [super init];
	if(self)
	{
		self.emailInfo = theEmailInfo;
		self.connectionContext = theConnectionContext;
		self.getMsgBodyDelegate = msgBodyDelegate;
	}
	return self;
}

-(void)main
{
	NSLog(@"GetMessageBodyOperation: message retrieval started");
	
	if([self.connectionContext establishConnection])
	{
		@try {

			if(self.isCancelled) { return; }

			NSString *folderName = self.emailInfo.folderInfo.folderName;
			CTCoreFolder *emailFolder = [self.connectionContext.mailAcct folderWithPath:folderName];
			if(emailFolder == nil)
			{
				[self.connectionContext teardownConnection];
				[self.getMsgBodyDelegate msgBodyRetrievalFailed];
				[self.connectionContext.progressDelegate mailSyncComplete:TRUE];
				return;
			}

			if(self.isCancelled) { return; }

			CTCoreMessage *serverEmailMsg = [emailFolder messageWithUID:[self.emailInfo.uid unsignedIntValue]];
			if(serverEmailMsg == nil)
			{
				[self.connectionContext teardownConnection];
				[self.getMsgBodyDelegate msgBodyRetrievalFailed];
				[self.connectionContext.progressDelegate mailSyncComplete:TRUE];
				return;
			}
			
			if(![serverEmailMsg fetchBodyStructure])
			{
				if(self.isCancelled) { return; }
				[self.connectionContext teardownConnection];
				[self.getMsgBodyDelegate msgBodyRetrievalFailed];
				[self.connectionContext.progressDelegate mailSyncComplete:TRUE];
				return;
			}			
			
			if(self.isCancelled) { return; }
			
			NSString *msgBody = [serverEmailMsg htmlBody];
			if((msgBody == nil) || ([msgBody length] == 0))
			{
				NSString *plainTextBody = [serverEmailMsg body];
				msgBody = [NSString stringWithFormat:@"<pre>%@</pre>",plainTextBody];
			}
			
			if(self.isCancelled) { return; }
			
			[self.getMsgBodyDelegate msgBodyRetrievalComplete:msgBody];
			
			[self.connectionContext teardownConnection];
			[self.connectionContext.progressDelegate mailSyncComplete:TRUE];
		}
		@catch (NSException *exception) {
				[self.getMsgBodyDelegate msgBodyRetrievalFailed];
				[self.connectionContext.progressDelegate mailSyncComplete:TRUE];
		}
	}
	else 
	{
		[self.connectionContext.progressDelegate mailSyncComplete:FALSE];
	}
	
	NSLog(@"GetMessageBodyOperation: message body retrieval finished");

}

-(void)dealloc
{
	[emailInfo release];
	[connectionContext release];
	[super dealloc];
}

@end
