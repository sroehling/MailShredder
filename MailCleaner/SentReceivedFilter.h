//
//  SentReceivedFilter.h
//
//  Created by Steve Roehling on 10/3/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MessageFilter, SharedAppVals;
@class DataModelController;

extern NSString * const SENT_RECEIVED_FILTER_ENTITY_NAME;
extern NSUInteger const SENT_RECEIVED_FILTER_MATCH_LOGIC_EITHER;
extern NSUInteger const SENT_RECEIVED_FILTER_MATCH_LOGIC_RECEIVED;
extern NSUInteger const SENT_RECEIVED_FILTER_MATCH_LOGIC_SENT;


@interface SentReceivedFilter : NSManagedObject

@property (nonatomic, retain) NSNumber * matchLogic;

@property (nonatomic, retain) NSSet *messageFilterSentReceivedFilter;

@property (nonatomic, retain) SharedAppVals *sharedAppValsSentReceivedFilterEither;
@property (nonatomic, retain) SharedAppVals *sharedAppValsSentReceivedFilterSent;
@property (nonatomic, retain) SharedAppVals *sharedAppValsSentReceivedFilterReceived;

@property BOOL selectionFlagForSelectableObjectTableView;


+(SentReceivedFilter*)sentReceivedFilterInDataModelController:(DataModelController*)dmcForNewFilter
	andMatchLogic:(NSUInteger)theMatchLogic;

-(NSString*)filterSynopsis;
-(NSString*)filterSubtitle;
-(NSPredicate*)filterPredicate;
-(BOOL)filterMatchesEitherSentOrReceived  ;


@end

@interface SentReceivedFilter (CoreDataGeneratedAccessors)

- (void)addMessageFilterSentReceivedFilterObject:(MessageFilter *)value;
- (void)removeMessageFilterSentReceivedFilterObject:(MessageFilter *)value;
- (void)addMessageFilterSentReceivedFilter:(NSSet *)values;
- (void)removeMessageFilterSentReceivedFilter:(NSSet *)values;

@end
