//
//  MsgPredicateHelper.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataModelController;
@class MessageFilter;

@interface MsgPredicateHelper : NSObject

+(NSPredicate*)markedForDeletion;

+(NSPredicate*)emailInfoInCurrentAcctPredicate:(DataModelController*)appDmc;

+(NSFetchRequest*)emailInfoFetchRequestForDataModelController:(DataModelController*)appDmc
	andFilter:(MessageFilter*)msgFilter;

@end
