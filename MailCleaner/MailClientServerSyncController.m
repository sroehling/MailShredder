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
#import "EmailDomain.h"
#import "EmailAddress.h"
#import "MailAddressHelper.h"
#import "EmailFolder.h"

@implementation MailClientServerSyncController

@synthesize mailAcct;
@synthesize emailInfoDmc;
@synthesize appDataDmc;

-(id)initWithDataModelController:(DataModelController*)theDmcForEmailInfo
	andAppDataDmc:(DataModelController*)theAppDataDmc
{
	self = [super init];
	if(self)
	{
		assert(theDmcForEmailInfo != nil);
		self.emailInfoDmc = theDmcForEmailInfo;
		
		assert(theAppDataDmc != nil);
		self.appDataDmc = theAppDataDmc;
	
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
	[appDataDmc release];
	[super dealloc];
}

-(EmailInfo*)emailInfoFromServerMsg:(CTCoreMessage*)msg andFolderInfo:(FolderInfo*)folderInfo
{
	EmailInfo *newEmailInfo = (EmailInfo*) [self.emailInfoDmc insertObject:EMAIL_INFO_ENTITY_NAME];
	
	newEmailInfo.sendDate = msg.senderDate;
	newEmailInfo.from = msg.sender.email;
	newEmailInfo.subject = msg.subject;
	newEmailInfo.messageId = msg.uid;
	newEmailInfo.domain = [MailAddressHelper emailAddressDomainName:msg.sender.email];
	
	newEmailInfo.folderInfo = folderInfo;
	newEmailInfo.folder = folderInfo.fullyQualifiedName;
	
	return newEmailInfo;

}

-(void)syncWithServer
{

	[self connect];
	
	NSSet *currEmailAddresses = [self.appDataDmc fetchObjectsForEntityName:EMAIL_ADDRESS_ENTITY_NAME]; 
	NSMutableDictionary *currEmailAddressByAddress = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailAddress *currAddr in currEmailAddresses)
	{
		[currEmailAddressByAddress setObject:currAddr forKey:currAddr.address];
	}
	
	NSSet *currDomains = [self.appDataDmc fetchObjectsForEntityName:EMAIL_DOMAIN_ENTITY_NAME];
	NSMutableDictionary *currDomainByDomainName = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailDomain *currDomain in currDomains)
	{
		[currDomainByDomainName setObject:currDomain forKey:currDomain.domainName];
	}
	
	NSSet *currFolders = [self.appDataDmc fetchObjectsForEntityName:EMAIL_FOLDER_ENTITY_NAME];
	NSMutableDictionary *currFolderByFolderName = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailFolder *currFolder in currFolders)
	{
		[currFolderByFolderName setObject:currFolder forKey:currFolder.folderName];
	}

	
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

		EmailFolder *existingFolder = [currFolderByFolderName objectForKey:folderName];
		if(existingFolder == nil)
		{
			EmailFolder *newFolder = [self.appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
			newFolder.folderName = folderName;
			[currFolderByFolderName setObject:newFolder forKey:folderName];
		}

		
		if(currFolder.totalMessageCount > 0)
		{
			// set the toIndex to 0 so all messages are loaded
			NSSet *serverMsgSet = [currFolder messageObjectsFromIndex:1 toIndex:0];
			NSLog(@"%@: ... done getting message list",folderName);

			for(CTCoreMessage *msg in serverMsgSet)
			{
				NSLog(@"Sync msg: uid= %@, msg id = %@, send date = %@, subj = %@", msg.uid,msg.messageId,
					[DateHelper stringFromDate:msg.senderDate],msg.subject);
				EmailInfo *newEmailInfo = [self emailInfoFromServerMsg:msg andFolderInfo:folderInfo];
				
				// Update the list of known senders' addresses, if the address is not
				// already in the list.
				EmailAddress *newEmailAddr = [currEmailAddressByAddress objectForKey:newEmailInfo.from];
				if(newEmailAddr == nil)
				{
					newEmailAddr = [self.appDataDmc insertObject:EMAIL_ADDRESS_ENTITY_NAME];
					newEmailAddr.address = newEmailInfo.from;
					[currEmailAddressByAddress setObject:newEmailAddr forKey:newEmailAddr.address];
				}
				
				EmailDomain *existingDomain = [currDomainByDomainName objectForKey:newEmailInfo.domain];
				if(existingDomain == nil)
				{
					EmailDomain *newDomain = [self.appDataDmc insertObject:EMAIL_DOMAIN_ENTITY_NAME];
					newDomain.domainName = newEmailInfo.domain;
					[currDomainByDomainName setObject:newDomain forKey:newDomain.domainName];
				}

				
				numNewMsgs ++;
					
			}
		}
		
		NSLog(@"%@: ... done synchronizing message list",folderName);
		NSLog(@"-------");
		
	}
	
	[self.emailInfoDmc saveContext];
	[self.appDataDmc saveContext];

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
	[self.appDataDmc saveContext];

	[serverFoldersToExpunge release];
	[folderByPath release];

	
	[self disconnect];

}

@end
