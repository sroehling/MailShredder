//
//  FolderInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmailInfo;

extern NSString * const FOLDER_INFO_ENTITY_NAME;

@interface FolderInfo : NSManagedObject

@property (nonatomic, retain) NSString * fullyQualifiedName;
@property (nonatomic, retain) NSSet *emailFolderInfo;

@end

@interface FolderInfo (CoreDataGeneratedAccessors)

- (void)addEmailFolderInfoObject:(EmailInfo *)value;
- (void)removeEmailFolderInfoObject:(EmailInfo *)value;
- (void)addEmailFolderInfo:(NSSet *)values;
- (void)removeEmailFolderInfo:(NSSet *)values;

@end
