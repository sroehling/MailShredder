//
//  AgeFilter.h
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MessageFilter;
@class MsgHandlingRule;

@interface AgeFilter : NSManagedObject {
	@private
		BOOL selectionFlagForSelectableObjectTableView;
}

@property BOOL selectionFlagForSelectableObjectTableView;

// Inverse Properties
@property (nonatomic, retain) NSSet *messageFilterAgeFilter;

-(NSString*)filterSynopsis;
-(NSPredicate*)filterPredicate:(NSDate*)baseDate;
-(BOOL)filterMatchesAnyAge;

@end

@interface AgeFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterAgeFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterAgeFilterObject:(MessageFilter *)value;
- (void)addMessageFilterAgeFilter:(NSSet *)values;
- (void)removeMessageFilterAgeFilter:(NSSet *)values;

@end
