//
//  EmailFolder.h
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const EMAIL_FOLDER_ENTITY_NAME;
extern NSString * const EMAIL_FOLDER_ACCT_KEY;

@class DataModelController;
@class EmailInfo;
@class EmailAccount;

@interface EmailFolder : NSManagedObject
{
	@private
		BOOL isSelectedForSelectableObjectTableView;

}

@property (nonatomic, retain) NSString * folderName;
@property (nonatomic, retain) NSSet *emailFolderFilterSelectedFolders;
@property (nonatomic, retain) NSSet *emailInfoFolder;

@property BOOL isSelectedForSelectableObjectTableView;

// EmailAccount this folder belongs to
@property (nonatomic, retain) EmailAccount *folderAccount;

// Inverse relationship for a list of folders synchronization will 
// take place for in this account. An empty list implies every folder
// will be synchronized.
@property (nonatomic, retain) NSSet *emailAccountOnlySyncFolders;

+(EmailFolder*)findOrAddFolder:(NSString*)folderName 
	inExistingFolders:(NSMutableDictionary*)currFoldersByName
	withDataModelController:(DataModelController*)appDataDmc
	andFolderAcct:(EmailAccount*)acctForFolder;
	
-(NSMutableDictionary*)emailInfosInFolderByUID;
-(BOOL)hasLocalEmailInfoObjects;
-(BOOL)isReferencedByFiltersOrSyncFolders;

@end


@interface EmailFolder (CoreDataGeneratedAccessors)

- (void)addEmailFolderFilterSelectedFoldersObject:(NSManagedObject *)value;
- (void)removeEmailFolderFilterSelectedFoldersObject:(NSManagedObject *)value;
- (void)addEmailFolderFilterSelectedFolders:(NSSet *)values;
- (void)removeEmailFolderFilterSelectedFolders:(NSSet *)values;

- (void)addEmailInfoFolderObject:(EmailInfo *)value;
- (void)removeEmailInfoFolderObject:(EmailInfo *)value;
- (void)addEmailInfoFolder:(NSSet *)values;
- (void)removeEmailInfoFolder:(NSSet *)values;

- (void)addEmailAccountOnlySyncFoldersObject:(EmailAccount *)value;
- (void)removeEmailAccountOnlySyncFoldersObject:(EmailAccount *)value;
- (void)addEmailAccountOnlySyncFolders:(NSSet *)values;
- (void)removeEmailAccountOnlySyncFolders:(NSSet *)values;


@end
