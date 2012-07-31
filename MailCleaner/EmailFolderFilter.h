//
//  EmailFolderFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmailFolder, MessageFilter, MsgHandlingRule;

extern NSString * const EMAIL_FOLDER_FILTER_ENTITY_NAME;

@interface EmailFolderFilter : NSManagedObject

@property (nonatomic, retain) NSSet *selectedFolders;
@property (nonatomic, retain) MsgHandlingRule *msgHandlingRuleFolderFilter;
@property (nonatomic, retain) MessageFilter *messageFilterFolderFilter;

-(NSString*)filterSynopsis;
-(NSString*)filterSynopsisShort;
-(NSString*)subFilterSynopsis;

-(NSPredicate*)filterPredicate;

-(void)setFolders:(NSSet*)selectedFolders;

@end

@interface EmailFolderFilter (CoreDataGeneratedAccessors)

- (void)addSelectedFoldersObject:(EmailFolder *)value;
- (void)removeSelectedFoldersObject:(EmailFolder *)value;
- (void)addSelectedFolders:(NSSet *)values;
- (void)removeSelectedFolders:(NSSet *)values;

@end
