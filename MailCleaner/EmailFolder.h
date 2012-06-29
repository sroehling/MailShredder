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

@interface EmailFolder : NSManagedObject
{
	@private
		BOOL isSelectedForSelectableObjectTableView;

}

@property (nonatomic, retain) NSString * folderName;
@property (nonatomic, retain) NSSet *emailFolderFilterSelectedFolders;

@property BOOL isSelectedForSelectableObjectTableView;

@end

@interface EmailFolder (CoreDataGeneratedAccessors)

- (void)addEmailFolderFilterSelectedFoldersObject:(NSManagedObject *)value;
- (void)removeEmailFolderFilterSelectedFoldersObject:(NSManagedObject *)value;
- (void)addEmailFolderFilterSelectedFolders:(NSSet *)values;
- (void)removeEmailFolderFilterSelectedFolders:(NSSet *)values;

@end
