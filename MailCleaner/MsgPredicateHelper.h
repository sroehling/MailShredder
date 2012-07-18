//
//  MsgPredicateHelper.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataModelController;
@class TrashRule;

@interface MsgPredicateHelper : NSObject

+(NSPredicate*)trashedByUser:(BOOL)isTrashed;
+(NSPredicate*)lockedByUser:(BOOL)isLocked;
+(NSPredicate*)markedForDeletion;

+(NSPredicate*)trashedByMsgRules:(DataModelController*)appDmc andBaseDate:(NSDate*)baseDate;
+(NSPredicate*)trashedByUserOrRules:(DataModelController*)appDmc andBaseDate:(NSDate*)baseDate;

+(NSPredicate*)trashedByOneRule:(TrashRule*)theTrashRule 
	inDataModelController:(DataModelController*)appDmc andBaseDate:(NSDate*)baseDate;

+(NSPredicate*)notTrashedByUserOrRules:(DataModelController*)appDmc
	andBaseDate:(NSDate*)baseDate;

@end
