//
//  MsgSyncContext.m
//  MailCleaner
//
//  Created by Steve Roehling on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgSyncContext.h"

#import "MailSyncConnectionContext.h"
#import "MailAddressHelper.h"
#import "EmailInfo.h"
#import "DataModelController.h"
#import "EmailDomain.h"
#import "EmailAddress.h"
#import "EmailFolder.h"
#import "EmailInfo.h"
#import "EmailAccount.h"
#import "PercentProgressCounter.h"
#import "MailSyncProgressDelegate.h"

NSUInteger const MAIL_SYNC_NEW_MSGS_SAVE_THRESHOLD = 1000;

@implementation MsgSyncContext

@synthesize progressDelegate;
@synthesize connectionContext;
@synthesize currDomainByDomainName;
@synthesize currEmailAddressByAddress;
@synthesize existingEmailInfoByUID;
@synthesize currFolder;
@synthesize syncProgressCounter;
@synthesize syncAcct;

-(id)initWithConnectionContext:(MailSyncConnectionContext *)theConnectionContext
	andTotalExpectedMsgs:(NSUInteger)totalMsgs andProgressDelegate:(id<MailSyncProgressDelegate>)theProgressDelegate
{
	self = [super init];
	if(self)
	{
		self.connectionContext = theConnectionContext;
		
		self.syncAcct = [self.connectionContext acctInSyncObjectContext];
		
		self.currEmailAddressByAddress = [syncAcct emailAddressesByName];
		self.currDomainByDomainName = [syncAcct emailDomainsByDomainName];
		
		newLocalMsgsCreated=0;
		self.syncProgressCounter = [[PercentProgressCounter alloc] 
			initWithTotalCount:totalMsgs];
			
		assert(theProgressDelegate != nil);
		self.progressDelegate = theProgressDelegate;

	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}


-(void)startMsgSyncForFolder:(EmailFolder*)emailFolder
{
	// If emailFolder is an existing folder, then it might have existing EmailInfo objects in its 
	// emailInfoFolder relationship. If a local EmailInfo object already exists with the same UID,
	// then there is no need to create a new one. To perform this check, we need a dictionary of 
	// existing EmailInfo objects, whereby the key is the UID.
	self.existingEmailInfoByUID = [emailFolder emailInfosInFolderByUID];
	self.currFolder = emailFolder;
}

-(EmailInfo*)emailInfoFromServerMsg:(CTCoreMessage*)msg
{
	EmailInfo *newEmailInfo = (EmailInfo*) [self.connectionContext.syncDmc insertObject:EMAIL_INFO_ENTITY_NAME];
	
	newEmailInfo.sendDate = msg.sentDateGMT;

	newEmailInfo.senderAddress = [EmailAddress findOrAddAddress:msg.sender.email
			withName:msg.sender.name andSendDate:msg.sentDateGMT
			withCurrentAddresses:self.currEmailAddressByAddress 
				inDataModelController:self.connectionContext.syncDmc
				andEmailAcct:self.syncAcct];

	newEmailInfo.subject = msg.subject;
	newEmailInfo.uid = [NSNumber numberWithUnsignedInt:msg.uid];
	newEmailInfo.size = [NSNumber numberWithUnsignedInt:msg.messageSize];
	
	newEmailInfo.senderDomain = [EmailDomain 
			findOrAddDomainName:[MailAddressHelper emailAddressDomainName:msg.sender.email] 
			withCurrentDomains:self.currDomainByDomainName 
			inDataModelController:self.connectionContext.syncDmc
			andEmailAcct:self.syncAcct];	

	newEmailInfo.emailAcct = self.syncAcct;
		
	newEmailInfo.isRead = [NSNumber numberWithBool:msg.isUnread?FALSE:TRUE];
	newEmailInfo.isStarred = [NSNumber numberWithBool:msg.isStarred];
	
	NSSet *recipients = [msg to];
	for(CTCoreAddress *toAddress in recipients)
	{
		EmailAddress *recipientAddress = [EmailAddress findOrAddAddress:toAddress.email
					withName:toAddress.name andSendDate:msg.sentDateGMT
					withCurrentAddresses:self.currEmailAddressByAddress 
					inDataModelController:self.connectionContext.syncDmc
					andEmailAcct:self.syncAcct];
		[newEmailInfo addRecipientAddressesObject:recipientAddress];
	}
	
	newEmailInfo.folderInfo = self.currFolder;
	
	return newEmailInfo;

}


-(void)syncOneMsg:(CTCoreMessage*)msg
{
	NSNumber *msgKey = [NSNumber numberWithUnsignedInt:msg.uid];
	EmailInfo *existingEmailInfo =[existingEmailInfoByUID objectForKey:msgKey];
	if(existingEmailInfo != nil)
	{
	
		// Update the flags if they've changed
		BOOL isRead = msg.isUnread?FALSE:TRUE;
		if([existingEmailInfo.isRead boolValue] != isRead)
		{
			existingEmailInfo.isRead = [NSNumber numberWithBool:isRead];
		}
		
		BOOL isStarred = msg.isStarred;
		if([existingEmailInfo.isStarred boolValue] != isStarred)
		{
			existingEmailInfo.isStarred = [NSNumber numberWithBool:isStarred];
		}

		// The EmailInfo's remaining in the dictionary after the folder 
		// synchronization represent messages which are no longer on the server,
		// but there's still a local EmailInfo.
		[existingEmailInfoByUID removeObjectForKey:msgKey];
	}
	else 
	{
		// Allocate a new local EmailInfo, since there's not an existing local
		// one with the same UID.
		[self emailInfoFromServerMsg:msg];
		
		newLocalMsgsCreated ++;

	}
	
	BOOL progressThresholdCrossed = [syncProgressCounter incrementProgressCount];
	if(progressThresholdCrossed)
	{
		if([self.progressDelegate respondsToSelector:@selector(mailSyncUpdateProgress:)])
		{
			[self.progressDelegate mailSyncUpdateProgress:
				[syncProgressCounter currentProgress]];
		}
	}
	if((newLocalMsgsCreated % MAIL_SYNC_NEW_MSGS_SAVE_THRESHOLD) == 0)
	{
		[self.connectionContext saveLocalChanges];
	}
	
}

-(void)finishFolderSync
{
	// Delete any local EmailInfo's which are unacounted after 
	// synchronizing this folder with the server.
	[self.connectionContext.syncDmc deleteObjects:[existingEmailInfoByUID allValues]];

	self.currFolder = nil;
	self.existingEmailInfoByUID = nil;
}

-(void)dealloc
{
	[connectionContext release];
	[currEmailAddressByAddress release];
	[currDomainByDomainName release];
	
	[existingEmailInfoByUID release];
	[currFolder release];
	
	[syncAcct release];
	
	[syncProgressCounter release];
	[super dealloc];
}

@end
