//
//  ReadFilter.h
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

extern NSString * const READ_FILTER_ENTITY_NAME;
extern NSUInteger const READ_FILTER_MATCH_LOGIC_READ;
extern NSUInteger const READ_FILTER_MATCH_LOGIC_UNREAD;
extern NSUInteger const READ_FILTER_MATCH_LOGIC_READ_OR_UNREAD;

@interface ReadFilter : NSManagedObject
{
	@private
		BOOL selectionFlagForSelectableObjectTableView;
}

@property (nonatomic, retain) NSNumber * matchLogic;

// Inverse relationships
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultReadFilterRead;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultReadFilterReadOrUnread;
@property (nonatomic, retain) SharedAppVals *sharedAppValsDefaultReadFilterUnread;
@property (nonatomic, retain) NSSet *messageFilterReadFilter;


+(ReadFilter*)readFilterInDataModelController:(DataModelController*)dmcForNewFilter
	andMatchLogic:(NSUInteger)theMatchLogic;

-(NSString*)filterSynopsis;
-(NSPredicate*)filterPredicate;
-(BOOL)filterMatchesAnyReadStatus;

@property BOOL selectionFlagForSelectableObjectTableView;

@end

@interface ReadFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterReadFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterReadFilterObject:(MessageFilter *)value;
- (void)addMessageFilterReadFilter:(NSSet *)values;
- (void)removeMessageFilterReadFilter:(NSSet *)values;


@end
