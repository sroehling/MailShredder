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
#import "AppHelper.h"

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

+(NSFetchRequest*)emptyFetchRequestForLaunchScreenGeneration:(DataModelController*)appDmc
{
	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_INFO_ENTITY_NAME 
		inManagedObjectContext:appDmc.managedObjectContext];
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[[NSSortDescriptor alloc]
		initWithKey:EMAIL_INFO_SEND_DATE_KEY ascending:NO] autorelease];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	

	[fetchRequest setPredicate:[NSPredicate predicateWithValue:FALSE]];
	[fetchRequest setFetchBatchSize:20];
	
	return fetchRequest;
}

+(NSFetchRequest*)emailInfoFetchRequestForDataModelController:(DataModelController*)appDmc
	andFilter:(MessageFilter*)msgFilter
{

	NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_INFO_ENTITY_NAME 
		inManagedObjectContext:appDmc.managedObjectContext];
	[fetchRequest setEntity:entity];
 
	NSSortDescriptor *sort = [[[NSSortDescriptor alloc]
		initWithKey:EMAIL_INFO_SEND_DATE_KEY ascending:NO] autorelease];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
	
	NSPredicate *currentAcctPredicate = [MsgPredicateHelper emailInfoInCurrentAcctPredicate:appDmc];
	
	// Once a message has been confirmed for deletion, it no longer needs to be shown
	// in the message list or used for counting the number of messages matching each
	// filter.
	NSPredicate *notDeletedPredicate = [NSPredicate predicateWithFormat:@"%K == %@",
		EMAIL_INFO_DELETED_KEY,[NSNumber numberWithBool:FALSE]];
		
	NSDate *baseDate = [DateHelper today];
	NSPredicate *filterPredicate = [msgFilter filterPredicate:baseDate];
	assert(filterPredicate != nil);
	
	
	NSPredicate *matchFilterInCurrentAcct = [NSCompoundPredicate andPredicateWithSubpredicates:
		[NSArray arrayWithObjects:currentAcctPredicate, filterPredicate,notDeletedPredicate,nil]];

	[fetchRequest setPredicate:matchFilterInCurrentAcct];
	[fetchRequest setFetchBatchSize:20];
	
	return fetchRequest;
}


@end
