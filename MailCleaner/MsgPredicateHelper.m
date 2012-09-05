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
#import "DateHelper.h"
#import "MessageFilter.h"

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


+(NSFetchRequest*)emailInfoFetchRequestForDataModelController:(DataModelController*)appDmc
	andFilter:(MessageFilter*)msgFilter
{

	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_INFO_ENTITY_NAME 
		inManagedObjectContext:appDmc.managedObjectContext];
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[NSSortDescriptor alloc]
		initWithKey:EMAIL_INFO_SEND_DATE_KEY ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSPredicate *currentAcctPredicate = [MsgPredicateHelper emailInfoInCurrentAcctPredicate:appDmc];
		
	NSDate *baseDate = [DateHelper today];
	NSPredicate *filterPredicate = [msgFilter filterPredicate:baseDate];
	assert(filterPredicate != nil);
	
	
	NSPredicate *matchFilterInCurrentAcct = [NSCompoundPredicate andPredicateWithSubpredicates:
		[NSArray arrayWithObjects:currentAcctPredicate, filterPredicate,nil]];

	[fetchRequest setPredicate:matchFilterInCurrentAcct];
	[fetchRequest setFetchBatchSize:20];
	
	return fetchRequest;
}


@end
