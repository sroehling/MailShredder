//
//  EmailAccount.m
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "EmailAccount.h"
#import "DataModelController.h"
#import "StringValidation.h"
#import "EmailFolder.h"
#import "KeychainFieldInfo.h"
#import "EmailDomain.h"
#import "LocalizationHelper.h"
#import "MessageFilter.h"
#import "EmailAddress.h"

NSString * const EMAIL_ACCOUNT_ENTITY_NAME = @"EmailAccount";
NSString * const EMAIL_ACCOUNT_NAME_KEY = @"acctName";
NSString * const EMAIL_ACCOUNT_USESSL_KEY = @"useSSL";
NSInteger const EMAIL_ACCOUNT_NAME_MAX_LENGTH = 32;
NSString * const EMAIL_ACCOUNT_PORTNUM_KEY= @"portNumber";
NSString * const EMAIL_ACCOUNT_ADDRESS_KEY = @"emailAddress";
NSString * const EMAIL_ACCOUNT_IMAPSERVER_KEY = @"imapServer";
NSString * const EMAIL_ACCOUNT_USERNAME_KEY = @"userName";
NSString * const EMAIL_ACCOUNT_UNIQUEACCTID_KEY = @"uniqueAcctID";
NSString * const EMAIL_ACCOUNT_SYNC_OLD_MSGS_FIRST_KEY = @"syncOldMsgsFirst";
NSString * const EMAIL_ACCOUNT_MAX_SYNC_MSGS_KEY = @"maxSyncMsgs";

NSString * const EMAIL_ACCOUNT_DELETE_HANDLING_DELETE_MSG_KEY = @"deleteHandlingDeleteMsg";
NSString * const EMAIL_ACCOUNT_DELETE_HANDLING_MOVE_TO_FOLDER_KEY = @"deleteHandlingMoveToFolder";

NSInteger const EMAIL_ACCOUNT_DEFAULT_PORT_SSL = 993;
NSInteger const EMAIL_ACCOUNT_DEFAULT_PORT_NOSSL = 143;

NSString * const EMAIL_ACCOUNT_KEYCHAIN_PREFIX = @"EmailAccountLoginInfo";


@implementation EmailAccount

@dynamic acctName;
@dynamic emailAddress;
@dynamic imapServer;
@dynamic userName;
@dynamic useSSL;
@dynamic portNumber;
@dynamic uniqueAcctID;
@dynamic sharedAppValsCurrentEmailAcct;
@dynamic lastSync;
@dynamic foldersInAcct;
@dynamic domainsInAcct;
@dynamic addressesInAcct;
@dynamic emailsInAcct;
@dynamic onlySyncFolders;

@dynamic maxSyncMsgs;
@dynamic syncOldMsgsFirst;

@dynamic msgListFilter;
@dynamic savedMsgListFilters;

@dynamic deleteHandlingMoveToFolder;
@dynamic deleteHandlingDeleteMsg;

@synthesize isSelectedForSelectableObjectTableView;


+(EmailAccount*)defaultNewEmailAcctWithDataModelController:(DataModelController*)acctDmc
{

	EmailAccount *newAcct = [acctDmc insertObject:EMAIL_ACCOUNT_ENTITY_NAME];
	newAcct.portNumber = [NSNumber numberWithInt:EMAIL_ACCOUNT_DEFAULT_PORT_SSL];
	newAcct.useSSL = [NSNumber numberWithBool:TRUE];
	
	NSString *uniqueIDCandidate;
	NSArray *collidingUniqueIDs;
	do {
		uniqueIDCandidate = [StringValidation pseudoRandomToken];
		NSPredicate *uniqueIDPredicate = [NSPredicate predicateWithFormat:@"%K == %@",
					EMAIL_ACCOUNT_UNIQUEACCTID_KEY,uniqueIDCandidate];
		collidingUniqueIDs = [acctDmc fetchObjectsForEntityName:EMAIL_ACCOUNT_ENTITY_NAME andPredicate:uniqueIDPredicate];
	} while ([collidingUniqueIDs count] > 0);
	
	newAcct.uniqueAcctID = uniqueIDCandidate;
	
	newAcct.msgListFilter = [MessageFilter defaultMessageFilter:acctDmc];	
	
	return newAcct;
}


-(KeychainFieldInfo*)passwordFieldInfo
{
	NSString *keychainID = [NSString stringWithFormat:@"%@-%@",EMAIL_ACCOUNT_KEYCHAIN_PREFIX,
		self.uniqueAcctID];
	KeychainFieldInfo *passwordFieldInfo = [[[KeychainFieldInfo alloc] 
		initWithFieldLabel:LOCALIZED_STR(@"EMAIL_ACCOUNT_PASSWORD_FIELD_LABEL")  
		andFieldPlaceholder:LOCALIZED_STR(@"EMAIL_ACCOUNT_PASSWORD_PLACEHOLDER") 
		andKeyChainID:keychainID andKeychainKey:kSecValueData] autorelease];
	
	return passwordFieldInfo;
}

-(NSMutableDictionary*)foldersByName
{
	NSMutableDictionary *currFolderByFolderName = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailFolder *currFolder in self.foldersInAcct)
	{
		[currFolderByFolderName setObject:currFolder forKey:currFolder.folderName];
	}
	return currFolderByFolderName;
}

-(NSDictionary*)syncFoldersByName
{
	NSMutableDictionary *syncFolders = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailFolder *syncFolder in self.onlySyncFolders)
	{
		[syncFolders setObject:syncFolder forKey:syncFolder.folderName];
	}
	return syncFolders;
}

-(NSMutableDictionary*)emailDomainsByDomainName
{
	NSMutableDictionary *currDomainByDomainName = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailDomain *currDomain in self.domainsInAcct)
	{
		[currDomainByDomainName setObject:currDomain forKey:currDomain.domainName];
	}
	return currDomainByDomainName;
}

-(NSMutableDictionary*)emailAddressesByName
{
	NSMutableDictionary *currEmailAddressByAddress = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailAddress *currAddr in self.addressesInAcct)
	{
		[currEmailAddressByAddress setObject:currAddr forKey:currAddr.address];
	}
	return currEmailAddressByAddress;
}

-(NSString*)msgDeletionPreDeletionSummary:(NSUInteger)numMsgsToBeDeleted
{
	BOOL deletionErasesMsgs = [self.deleteHandlingDeleteMsg boolValue];
	NSString *deleteFolder =(self.deleteHandlingMoveToFolder != nil)?self.deleteHandlingMoveToFolder.folderName:nil;
	
	NSString *msgCountDescription;
	if(numMsgsToBeDeleted == 1)
	{
		msgCountDescription = LOCALIZED_STR(@"MESSAGE_DELETE_SINGULAR_MESSAGE_LABEL");
	}
	else 
	{
		msgCountDescription = LOCALIZED_STR(@"MESSAGE_DELETE_PLURAL_MESSAGE_LABEL");
	}

	if(deleteFolder != nil) 
	{
		if(deletionErasesMsgs)
		{
			return [NSString 
				stringWithFormat:LOCALIZED_STR(@"MESSAGE_DELETE_ACTION_SUMMARY_MOVE_THEN_PERMANENTLY_DELETE_FORMAT"),
				msgCountDescription,deleteFolder];
		}
		else 
		{
			return [NSString stringWithFormat:LOCALIZED_STR(@"MESSAGE_DELETE_ACTION_SUMMARY_MOVE_FORMAT"),
				msgCountDescription,deleteFolder];

		}
	}
	else if (deletionErasesMsgs)
	{
		return [NSString stringWithFormat:LOCALIZED_STR(@"MESSAGE_DELETE_ACTION_SUMMARY_PERMANENTLY_DELETE_FORMAT"),
			msgCountDescription];
	}
	else 
	{
		return LOCALIZED_STR(@"MESSAGE_DELETION_COMPLETION_STATUS_NO_ACTION");
	}
}

@end
