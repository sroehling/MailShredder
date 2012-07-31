//
//  EmailFolder.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailFolder.h"

#import "DataModelController.h"

NSString * const EMAIL_FOLDER_ENTITY_NAME = @"EmailFolder";

@implementation EmailFolder

@dynamic folderName;
@dynamic emailFolderFilterSelectedFolders;

// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;


+(NSMutableDictionary*)foldersByName:(DataModelController*)appDataDmc
{
	NSSet *currFolders = [appDataDmc fetchObjectsForEntityName:EMAIL_FOLDER_ENTITY_NAME];
	NSMutableDictionary *currFolderByFolderName = [[[NSMutableDictionary alloc] init] autorelease];
	for(EmailFolder *currFolder in currFolders)
	{
		[currFolderByFolderName setObject:currFolder forKey:currFolder.folderName];
	}
	return currFolderByFolderName;
}

+(EmailFolder*)findOrAddFolder:(NSString*)folderName 
	inExistingFolders:(NSMutableDictionary*)currFoldersByName
	withDataModelController:(DataModelController*)appDataDmc
{
	EmailFolder *theFolder = [currFoldersByName objectForKey:folderName];
	if(theFolder == nil)
	{
		theFolder = [appDataDmc insertObject:EMAIL_FOLDER_ENTITY_NAME];
		theFolder.folderName = folderName;
		[currFoldersByName setObject:theFolder forKey:folderName];
	}
	return theFolder;
}

@end
