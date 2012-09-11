//
//  EmailFolder.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailFolder.h"

#import "DataModelController.h"
#import "EmailInfo.h"

NSString * const EMAIL_FOLDER_ENTITY_NAME = @"EmailFolder";
NSString * const EMAIL_FOLDER_ACCT_KEY = @"folderAccount";

@implementation EmailFolder

@dynamic folderName;
@dynamic emailFolderFilterSelectedFolders;
@dynamic emailInfoFolder;
@dynamic folderAccount;
@dynamic emailAccountOnlySyncFolders;

// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;

+(EmailFolder*)findOrAddFolder:(NSString*)folderName 
	inExistingFolders:(NSMutableDictionary*)currFoldersByName
	withDataModelController:(DataModelController*)appDataDmc
	andFolderAcct:(EmailAccount*)acctForFolder
{
	EmailFolder *theFolder = [currFoldersByName objectForKey:folderName];
	if(theFolder == nil)
	{
		theFolder = [appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
		theFolder.folderName = folderName;
		theFolder.folderAccount = acctForFolder;
		[currFoldersByName setObject:theFolder forKey:folderName];
	}
	return theFolder;
}

-(BOOL)hasLocalEmailInfoObjects
{
	return ((self.emailInfoFolder != nil) && 
		(self.emailInfoFolder.count > 0))?TRUE:FALSE;
}


-(BOOL)isReferencedByFiltersOrSyncFolders
{
	if((self.emailFolderFilterSelectedFolders != nil) &&
		(self.emailFolderFilterSelectedFolders.count >0))
	{
		return TRUE;
	}
	if((self.emailAccountOnlySyncFolders != nil) &&
		(self.emailAccountOnlySyncFolders.count >0))
	{
		return TRUE;
	}
	return FALSE;
}

-(NSMutableDictionary*)emailInfosInFolderByUID
{
	NSMutableDictionary *emailInfoByUID = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailInfo *emailInfoInCurrFolder in self.emailInfoFolder)
	{
		[emailInfoByUID setObject:emailInfoInCurrFolder forKey:emailInfoInCurrFolder.uid];
	}
	return emailInfoByUID;
}

@end
