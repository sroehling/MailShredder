//
//  EmailFolderFilter.h
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmailFolder, MessageFilter;

extern NSString * const EMAIL_FOLDER_FILTER_ENTITY_NAME;
extern NSString * const EMAIL_FOLDER_FILTER_MATCH_UNSELECTED_KEY;

@interface EmailFolderFilter : NSManagedObject

@property (nonatomic, retain) NSSet *selectedFolders;
@property (nonatomic, retain) MessageFilter *messageFilterFolderFilter;
@property (nonatomic, retain) NSNumber * matchUnselected;

-(NSString*)filterSynopsis;
-(NSString*)filterSynopsisShort;
-(NSString*)subFilterSynopsis;
-(BOOL)filterMatchesAnyFolder;
-(NSPredicate*)filterPredicate;

-(void)setFolders:(NSSet*)selectedFolders;

-(void)resetFilter;

@end

@interface EmailFolderFilter (CoreDataGeneratedAccessors)

- (void)addSelectedFoldersObject:(EmailFolder *)value;
- (void)removeSelectedFoldersObject:(EmailFolder *)value;
- (void)addSelectedFolders:(NSSet *)values;
- (void)removeSelectedFolders:(NSSet *)values;

@end
