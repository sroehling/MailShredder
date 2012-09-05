//
//  MessageFilterCountOperation.m
//  MailCleaner
//
//  Created by Steve Roehling on 9/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MessageFilterCountOperation.h"
#import "EmailAccount.h"
#import "DataModelController.h"
#import "CoreDataHelper.h"
#import "DateHelper.h"
#import "MsgPredicateHelper.h"
#import "MessageFilter.h"

@implementation MessageFilterCountOperation

@synthesize emailAccount;
@synthesize mainThreadDmc;

-(id)initWithMainThreadDmc:(DataModelController*)theMainThreadDmc
	andEmailAccount:(EmailAccount*)theEmailAccount
{
	self = [super init];
	if(self)
	{
		assert(theEmailAccount != nil);
		self.emailAccount = theEmailAccount;
		
		assert(theMainThreadDmc != nil);
		self.mainThreadDmc = theMainThreadDmc;
	}
	return self;
}

-(void)dealloc
{
	[emailAccount release];
	[mainThreadDmc release];
	[super dealloc];
}

-(void)msgCountsThreadDidSaveNotificationHandler:(NSNotification*)notification
{
	[self.mainThreadDmc.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
}

-(void)main
{
	NSLog(@"Starting operation to update message filter counts");
	
	@autoreleasepool {
		DataModelController *msgCountsDmc = [[[DataModelController alloc] 
				initWithPersistentStoreCoord:self.mainThreadDmc.managedObjectContext.persistentStoreCoordinator] autorelease];
				
		[[NSNotificationCenter defaultCenter] addObserver:self 
			selector:@selector(msgCountsThreadDidSaveNotificationHandler:)
			name:NSManagedObjectContextDidSaveNotification 
			object:msgCountsDmc.managedObjectContext];
			
		@try {
			EmailAccount *acctInMsgCountingThread = (EmailAccount*)[CoreDataHelper 
				objectInOtherContext:msgCountsDmc.managedObjectContext forOriginalObj:self.emailAccount];
				
			for(MessageFilter *savedFilter in acctInMsgCountingThread.savedMsgListFilters)
			{
		
				NSFetchRequest *savedFilterFetch = [MsgPredicateHelper 
					emailInfoFetchRequestForDataModelController:msgCountsDmc andFilter:savedFilter];
					
				NSArray *matchingMsgs = [CoreDataHelper executeFetchOrThrow:savedFilterFetch 
						inManagedObectContext:msgCountsDmc.managedObjectContext];
				NSLog(@"Matching message count for filter: %@ = %d",savedFilter.filterName,[matchingMsgs count]);
				savedFilter.matchingMsgs = [NSNumber numberWithInt:[matchingMsgs count]];
	 
			}
			
			[msgCountsDmc saveContext];
		}
		@catch (NSException *exception)
		{
			;
		}
		@finally 
		{
			[[NSNotificationCenter defaultCenter] removeObserver:self 
					name:NSManagedObjectContextDidSaveNotification 
					object:msgCountsDmc.managedObjectContext];
		}

   
	} // autoreleasepool
	
}


@end
