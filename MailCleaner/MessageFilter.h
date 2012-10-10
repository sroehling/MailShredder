//
//  MessageFilter.h
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AgeFilter;
@class FromAddressFilter;
@class SharedAppVals;
@class EmailDomainFilter;
@class EmailFolderFilter;
@class DataModelController;
@class RecipientAddressFilter;
@class EmailAccount;
@class ReadFilter;
@class StarredFilter;
@class SubjectFilter;
@class SenderDomainFilter;
@class RecipientDomainFilter;
@class SentReceivedFilter;

extern NSString * const MESSAGE_FILTER_ENTITY_NAME;
extern NSString * const MESSAGE_FILTER_AGE_FILTER_KEY;
extern NSString * const MESSAGE_FILTER_NAME_KEY;
extern NSString * const MESSAGE_FILTER_READ_FILTER_KEY;
extern NSString * const MESSAGE_FILTER_STARRED_FILTER_KEY;
extern NSInteger const MESSAGE_FILTER_NAME_MAX_LENGTH;
extern NSString * const MESSAGE_FILTER_SENT_RECEIVED_FILTER_KEY;

@interface MessageFilter : NSManagedObject

@property (nonatomic, retain) NSString * filterName;

@property (nonatomic, retain) AgeFilter *ageFilter;

@property (nonatomic, retain) SenderDomainFilter *senderDomainFilter;
@property (nonatomic, retain) RecipientDomainFilter *recipientDomainFilter;

@property (nonatomic, retain) EmailFolderFilter *folderFilter;
@property (nonatomic, retain) ReadFilter *readFilter;
@property (nonatomic, retain) StarredFilter *starredFilter;
@property (nonatomic, retain) SentReceivedFilter *sentReceivedFilter;

@property (nonatomic, retain) SubjectFilter *subjectFilter;
@property (nonatomic, retain) FromAddressFilter *fromAddressFilter;
@property (nonatomic, retain) RecipientAddressFilter *recipientAddressFilter;

@property (nonatomic, retain) EmailAccount *emailAcctMsgListFilter;
@property (nonatomic, retain) EmailAccount *emailAcctSavedFilter;


// This is the number of messages matching the filter. This is
// updated after delete or synchronization operations, so it will be
// immediately available when the user chooses to load a filter.
@property (nonatomic, retain) NSNumber * matchingMsgs;

-(NSPredicate*)filterPredicate:(NSDate*)baseDate;
-(void)resetToDefault:(DataModelController*)filterDmc;

-(BOOL)nonEmptyFilterName;
-(void)resetFilterName;

-(BOOL)matchesAnyMessage;

-(NSString*)filterSynopsis;

+(MessageFilter*)defaultMessageFilter:(DataModelController*)filterDmc;

@end
