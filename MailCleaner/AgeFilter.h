//
//  AgeFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
@property (nonatomic, retain) NSSet *ruleAgeFilter;

-(NSString*)filterSynopsis;
-(NSPredicate*)filterPredicate;

@end

@interface AgeFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterAgeFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterAgeFilterObject:(MessageFilter *)value;
- (void)addMessageFilterAgeFilter:(NSSet *)values;
- (void)removeMessageFilterAgeFilter:(NSSet *)values;

- (void)addRuleAgeFilterObject:(MsgHandlingRule *)value;
- (void)removeRuleAgeFilterObject:(MsgHandlingRule *)value;
- (void)addRuleAgeFilter:(NSSet *)values;
- (void)removeRuleAgeFilter:(NSSet *)values;

@end
