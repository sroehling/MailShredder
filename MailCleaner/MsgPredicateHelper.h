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

+(NSPredicate*)markedForDeletion;

+(NSPredicate*)emailInfoInCurrentAcctPredicate:(DataModelController*)appDmc;

+(NSPredicate*)trashedByMsgRules:(DataModelController*)appDmc andBaseDate:(NSDate*)baseDate;

+(NSPredicate*)trashedByOneRule:(TrashRule*)theTrashRule 
	inDataModelController:(DataModelController*)appDmc andBaseDate:(NSDate*)baseDate;
	
+(NSPredicate*)rulesInCurrentAcctPredicate:(DataModelController*)appDmc;
+(NSPredicate*)enabledInCurrentAcctPredicate:(DataModelController*)appDmc;


@end
