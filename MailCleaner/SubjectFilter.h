//
//  SubjectFilter.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MessageFilter;

extern NSString * const SUBJECT_FILTER_ENTITY_NAME;
extern NSString * const SUBJECT_FILTER_CASE_SENSITIVE_KEY;
extern NSString * const SUBJECT_FILTER_SEARCH_STRING_KEY;

@interface SubjectFilter : NSManagedObject

@property (nonatomic, retain) NSString * searchString;
@property (nonatomic, retain) NSNumber * caseSensitive;

// Inverse relationship
@property (nonatomic, retain) NSSet *messageFilterSubjectFilters;


-(NSString*)filterSynopsis;
-(NSString*)filterSynopsisShort;
-(NSString*)subFilterSynopsis;
-(NSPredicate*)filterPredicate;

-(BOOL)filterMatchesAnySubject;

-(void)resetFilter;

@end

@interface SubjectFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterSubjectFiltersObject:(MessageFilter *)value;
- (void)removeMessageFilterSubjectFiltersObject:(MessageFilter *)value;
- (void)addMessageFilterSubjectFilters:(NSSet *)values;
- (void)removeMessageFilterSubjectFilters:(NSSet *)values;

@end
