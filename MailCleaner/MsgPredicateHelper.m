//
//  MsgPredicateHelper.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgPredicateHelper.h"
#import "DataModelController.h"
#import "SharedAppVals.h"
#import "EmailInfo.h"

@implementation MsgPredicateHelper

+(NSPredicate*)markedForDeletion
{
	return [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_DELETED_KEY,[NSNumber numberWithBool:TRUE]];
}

+(NSPredicate*)emailInfoInCurrentAcctPredicate:(DataModelController*)appDmc
{
	SharedAppVals *sharedVals =  [SharedAppVals getUsingDataModelController:appDmc];
	NSPredicate *matchingCurrentAcctPredicate = [NSPredicate predicateWithFormat:@"%K=%@",
		EMAIL_INFO_ACCT_KEY,sharedVals.currentEmailAcct];
	return matchingCurrentAcctPredicate;
}


@end
