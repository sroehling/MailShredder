//
//  MailSyncController.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MailClientServerSyncController.h"
#import "DataModelController.h"
#import "DateHelper.h"
#import "EmailInfo.h"
#import "MsgPredicateHelper.h"

@implementation MailClientServerSyncController

@synthesize mailAcct;
@synthesize emailInfoDmc;

-(id)initWithDataModelController:(DataModelController*)theDmcForEmailInfo
{
	self = [super init];
	if(self)
	{
		assert(theDmcForEmailInfo != nil);
		self.emailInfoDmc = theDmcForEmailInfo;
	
		self.mailAcct = [[CTCoreAccount alloc] init];
		[self.mailAcct connectToServer:@"debianvm" port:143
			connectionType:CONNECTION_TYPE_PLAIN
			authType:IMAP_AUTH_TYPE_PLAIN 
			login:@"testimapuser@debianvm.local" password:@"pass"]; 
	}
	return self;
}

-(id)init
{
	assert(0);
	return nil;
}

-(void)dealloc
{
	[mailAcct release];
	[emailInfoDmc release];
	[super dealloc];
}

-(void)syncWithServer
{

	NSMutableDictionary *emailInfoByMsgId = [[NSMutableDictionary alloc] init];

	// Create a map of message IDs to the local EmailInfo objects used to display and 
	// manipulate the email information locally.
	NSSet *currEmailInfo = [self.emailInfoDmc fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME];
	for(EmailInfo *emailInfo in currEmailInfo)
	{
			[emailInfoByMsgId setObject:emailInfo forKey:emailInfo.messageId];
	}

	CTCoreFolder *inbox = [self.mailAcct folderWithPath:@"INBOX"];
    NSLog(@"INBOX %@", inbox);
    // set the toIndex to 0 so all messages are loaded
    NSSet *messageSet = [inbox messageObjectsFromIndex:1 toIndex:0];
    NSLog(@"Done getting list of messages...");

    NSEnumerator *objEnum = [messageSet objectEnumerator];
	CTCoreMessage *msg;
	NSInteger numNewMsgs = 0;
	NSInteger totalMsgs = 0;
    while(msg = [objEnum nextObject]) 
	{
 		[msg fetchBodyStructure];
		NSLog(@"Msg: %@[%@] - %@",
			msg.uid,[DateHelper stringFromDate:msg.senderDate],msg.subject);
			
		EmailInfo *existingEmailInfo = [emailInfoByMsgId objectForKey:msg.uid];
		if(existingEmailInfo == nil)
		{
			EmailInfo *newEmailInfo = (EmailInfo*) [emailInfoDmc insertObject:EMAIL_INFO_ENTITY_NAME];
			newEmailInfo.sendDate = msg.senderDate;
			newEmailInfo.from = msg.sender.email;
			newEmailInfo.subject = msg.subject;
			newEmailInfo.messageId = msg.uid;
			numNewMsgs ++;
			
		}
		totalMsgs++;
		
		[self.emailInfoDmc saveContext];

    }
	NSLog(@"Done synchronizing messages: new msgs = %d, total msgs = %d",
		numNewMsgs,totalMsgs);


}

-(void)deleteMarkedMsgs
{
	CTCoreFolder *inbox = [self.mailAcct folderWithPath:@"INBOX"];
    NSLog(@"INBOX %@", inbox);
	
	NSArray *msgsMarkedForDeletion = [self.emailInfoDmc fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME 
		andPredicate:[MsgPredicateHelper markedForDeletion]];
	for(EmailInfo *markedForDeletion  in msgsMarkedForDeletion)
	{
		NSLog(@"Deleting msg: msg ID = %@, subject = %@",markedForDeletion.messageId,
			markedForDeletion.subject);
		CTCoreMessage *msgMarkedForDeletion = [inbox messageWithUID:markedForDeletion.messageId];
		if(msgMarkedForDeletion != nil)
		{
			[inbox setFlags:CTFlagDeleted forMessage:msgMarkedForDeletion];
		}
	}
	[inbox expunge];
	
	for(EmailInfo *markedForDeletion  in msgsMarkedForDeletion)
	{
		[self.emailInfoDmc deleteObject:markedForDeletion];
	}
	[self.emailInfoDmc saveContext];

}

@end
