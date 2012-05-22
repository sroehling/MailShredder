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

@interface AgeFilter : NSManagedObject {
	@private
		BOOL selectionFlagForSelectableObjectTableView;
}

@property (nonatomic, retain) NSSet *messageFilterAgeFilter;

@property BOOL selectionFlagForSelectableObjectTableView;

-(NSString*)filterSynopsis;
-(NSPredicate*)filterPredicate;

@end

@interface AgeFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterAgeFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterAgeFilterObject:(MessageFilter *)value;
- (void)addMessageFilterAgeFilter:(NSSet *)values;
- (void)removeMessageFilterAgeFilter:(NSSet *)values;

@end
