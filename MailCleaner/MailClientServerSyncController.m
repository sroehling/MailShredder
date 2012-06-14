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
#import "FolderInfo.h"
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
	
	}
	return self;
}

-(void)connect
{
	self.mailAcct = [[CTCoreAccount alloc] init];
	[self.mailAcct connectToServer:@"debianvm" port:143
		connectionType:CONNECTION_TYPE_PLAIN
		authType:IMAP_AUTH_TYPE_PLAIN 
		login:@"testimapuser@debianvm.local" password:@"pass"]; 
	
}

-(void)disconnect
{
	if(self.mailAcct != nil)
	{
		[self.mailAcct disconnect];
		self.mailAcct = nil;
	}
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

-(EmailInfo*)emailInfoFromServerMsg:(CTCoreMessage*)msg andFolderInfo:(FolderInfo*)folderInfo
{
	EmailInfo *newEmailInfo = (EmailInfo*) [self.emailInfoDmc insertObject:EMAIL_INFO_ENTITY_NAME];
	
	newEmailInfo.sendDate = msg.senderDate;
	newEmailInfo.from = msg.sender.email;
	newEmailInfo.subject = msg.subject;
	newEmailInfo.messageId = msg.uid;
	
	newEmailInfo.folderInfo = folderInfo;
	
	return newEmailInfo;

}

-(void)syncWithServer
{

	[self connect];
	
	
	NSSet *currFolderInfo = [self.emailInfoDmc fetchObjectsForEntityName:FOLDER_INFO_ENTITY_NAME];
	for (FolderInfo *currFolder in currFolderInfo)
	{
		[self.emailInfoDmc deleteObject:currFolder];
	}
	[self.emailInfoDmc saveContext];


	NSSet *allFolders = [self.mailAcct allFolders];
	NSInteger numNewMsgs = 0;
	NSInteger totalMsgs = 0;
	for (NSString *folderName in allFolders)
	{
		NSLog(@"%@: Processing folder",folderName);
		CTCoreFolder *currFolder = [self.mailAcct folderWithPath:folderName];
		
		FolderInfo *folderInfo = (FolderInfo*)[self.emailInfoDmc insertObject:FOLDER_INFO_ENTITY_NAME];
		folderInfo.fullyQualifiedName = currFolder.path;
		
		if(currFolder.totalMessageCount > 0)
		{
			// set the toIndex to 0 so all messages are loaded
			NSSet *serverMsgSet = [currFolder messageObjectsFromIndex:1 toIndex:0];
			NSLog(@"%@: ... done getting message list",folderName);

			for(CTCoreMessage *msg in serverMsgSet)
			{
				NSLog(@"Sync msg: uid= %@, msg id = %@, send date = %@, subj = %@", msg.uid,msg.messageId,
					[DateHelper stringFromDate:msg.senderDate],msg.subject);
				[self emailInfoFromServerMsg:msg andFolderInfo:folderInfo];
				numNewMsgs ++;
					
			}
		}
		
		NSLog(@"%@: ... done synchronizing message list",folderName);
		NSLog(@"-------");
		
	}
	
	[self.emailInfoDmc saveContext];

	NSLog(@"Done synchronizing messages: new msgs = %d, total server msgs = %d",
		numNewMsgs, totalMsgs);

	[self disconnect];

}

-(void)deleteMarkedMsgs
{

	[self connect];
	
	
	NSSet *allFolders = [self.mailAcct allFolders];
	NSMutableDictionary *folderByPath = [[NSMutableDictionary alloc] init];
	for (NSString *folderName in allFolders)
	{
		CTCoreFolder *serverFolder = [self.mailAcct folderWithPath:folderName];
		[folderByPath setObject:serverFolder forKey:folderName];
	}
	
	NSMutableSet *serverFoldersToExpunge = [[NSMutableSet alloc] init];
		
	NSArray *msgsMarkedForDeletion = [self.emailInfoDmc fetchObjectsForEntityName:EMAIL_INFO_ENTITY_NAME 
		andPredicate:[MsgPredicateHelper markedForDeletion]];
	for(EmailInfo *markedForDeletion  in msgsMarkedForDeletion)
	{
		NSLog(@"Deleting msg: msg ID = %@, subject = %@",markedForDeletion.messageId,
			markedForDeletion.subject);
		CTCoreFolder *msgFolder = (CTCoreFolder*)[folderByPath 
			objectForKey:markedForDeletion.folderInfo.fullyQualifiedName];
		if(msgFolder != nil)
		{
			NSLog(@"Deleting msg: uid= %@, send date = %@, subj = %@", markedForDeletion.messageId,
					[DateHelper stringFromDate:markedForDeletion.sendDate],markedForDeletion.subject);

			CTCoreMessage *msgMarkedForDeletion = [msgFolder messageWithUID:markedForDeletion.messageId];
			[msgFolder setFlags:CTFlagDeleted forMessage:msgMarkedForDeletion];
			[serverFoldersToExpunge addObject:msgFolder];
		}
			
	}
	
	if([serverFoldersToExpunge count] > 0)
	{
		for(CTCoreFolder *sererFolderWithDeletedMsgs in serverFoldersToExpunge)
		{
			[sererFolderWithDeletedMsgs expunge];
		}
	}
	
	for(EmailInfo *markedForDeletion  in msgsMarkedForDeletion)
	{
		[self.emailInfoDmc deleteObject:markedForDeletion];
	}
	
	[self.emailInfoDmc saveContext];

	[serverFoldersToExpunge release];
	[folderByPath release];

	
	[self disconnect];

}

@end
