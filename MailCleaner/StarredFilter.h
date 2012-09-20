//
//  StarredFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SharedAppVals;
@class DataModelController;
@class MessageFilter;

extern NSString * const STARRED_FILTER_ENTITY_NAME;
extern NSUInteger const STARRED_FILTER_MATCH_LOGIC_STARRED;
extern NSUInteger const STARRED_FILTER_MATCH_LOGIC_UNSTARRED;
extern NSUInteger const STARRED_FILTER_MATCH_LOGIC_STARRED_OR_UNSTARRED;

@interface StarredFilter : NSManagedObject
{
	@private
		BOOL selectionFlagForSelectableObjectTableView;
}

@property (nonatomic, retain) NSNumber * matchLogic;

// Inverse relationships
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultStarredFilterStarred;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultStarredFilterStarredOrUnstarred;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultStarredFilterUnstarred;
@property (nonatomic, retain) NSSet *messageFilterStarredFilter;


+(StarredFilter*)starredFilterInDataModelController:(DataModelController*)dmcForNewFilter
	andMatchLogic:(NSUInteger)theMatchLogic;

-(NSString*)filterSynopsis;
-(NSString*)filterSubtitle;
-(NSPredicate*)filterPredicate;
-(BOOL)filterMatchesAnyStarredStatus;

@property BOOL selectionFlagForSelectableObjectTableView;

@end

@interface StarredFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterStarredFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterStarredFilterObject:(MessageFilter *)value;
- (void)addMessageFilterStarredFilter:(NSSet *)values;
- (void)removeMessageFilterStarredFilter:(NSSet *)values;


@end
