//
//  EmailFolder.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const EMAIL_FOLDER_ENTITY_NAME;

@class DataModelController;
@class EmailInfo;

@interface EmailFolder : NSManagedObject
{
	@private
		BOOL isSelectedForSelectableObjectTableView;

}

@property (nonatomic, retain) NSString * folderName;
@property (nonatomic, retain) NSSet *emailFolderFilterSelectedFolders;
@property (nonatomic, retain) NSSet *emailInfoFolder;

@property BOOL isSelectedForSelectableObjectTableView;

+(NSMutableDictionary*)foldersByName:(DataModelController*)appDataDmc;
+(EmailFolder*)findOrAddFolder:(NSString*)folderName 
	inExistingFolders:(NSMutableDictionary*)currFoldersByName
	withDataModelController:(DataModelController*)appDataDmc;

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


@end
