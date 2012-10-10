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
@synthesize msgCountsDmc;
@synthesize cachedChangeNotifications;
@synthesize changeNotificationsLock;

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
		
		self.cachedChangeNotifications = [[[NSMutableArray alloc] init] autorelease];
		self.changeNotificationsLock = [[[NSLock alloc] init] autorelease];
	}
	return self;
}

-(void)dealloc
{
	[emailAccount release];
	[mainThreadDmc release];
	[msgCountsDmc release];
	[cachedChangeNotifications release];
	[changeNotificationsLock release];
	[super dealloc];
}

-(void)mergeChangesFromCountingThread:(NSNotification*)notification
{
	[self.changeNotificationsLock lock];
	[self.mainThreadDmc.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
	[self.mainThreadDmc saveContext];
	[self.changeNotificationsLock unlock];
}


-(void)msgCountsThreadDidSaveNotificationHandler:(NSNotification*)notification
{
	[self performSelectorOnMainThread:@selector(mergeChangesFromCountingThread:)
		withObject:notification waitUntilDone:TRUE];
}

-(void)mainThreadDidSaveNotificationHandler:(NSNotification*)notification
{
	[self.cachedChangeNotifications addObject:notification];
}


-(void)main
{
	NSLog(@"Starting operation to update message filter counts");

	self.msgCountsDmc = [[[DataModelController alloc] 
				initWithPersistentStoreCoord:self.mainThreadDmc.managedObjectContext.persistentStoreCoordinator] autorelease];
	[self.msgCountsDmc.managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];

	
	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(msgCountsThreadDidSaveNotificationHandler:)
		name:NSManagedObjectContextDidSaveNotification 
		object:msgCountsDmc.managedObjectContext];

	[[NSNotificationCenter defaultCenter] addObserver:self 
		selector:@selector(mainThreadDidSaveNotificationHandler:)
		name:NSManagedObjectContextDidSaveNotification 
		object:mainThreadDmc.managedObjectContext];
		
						
	@try {
		EmailAccount *acctInMsgCountingThread = (EmailAccount*)[CoreDataHelper 
			objectInOtherContext:self.msgCountsDmc.managedObjectContext forOriginalObj:self.emailAccount];
			
		for(MessageFilter *savedFilter in acctInMsgCountingThread.savedMsgListFilters)
		{
	
			NSFetchRequest *savedFilterFetch = [MsgPredicateHelper 
				emailInfoFetchRequestForDataModelController:msgCountsDmc andFilter:savedFilter];
				
			NSError *countError = nil;
			NSUInteger filterMatchCount = [msgCountsDmc.managedObjectContext
			countForFetchRequest:savedFilterFetch error:&countError];
			if (countError != nil)
			{
				NSLog(@"Unresolved error %@", [countError description]);
				[NSException raise:NSGenericException format:[countError description] arguments:nil];
			}
		
			NSLog(@"Matching message count for filter: %@ = %d",savedFilter.filterName,filterMatchCount);
			if([savedFilter.matchingMsgs unsignedIntegerValue] != filterMatchCount)
			{
				savedFilter.matchingMsgs = [NSNumber numberWithUnsignedInteger:filterMatchCount];
			}
		}
		
		[self.changeNotificationsLock lock];
		for(NSNotification *cachedNotification in self.cachedChangeNotifications)
		{
			NSLog(@"Merging cached changes from main thread MOC to msg filter counting thread MOC");
			[self.msgCountsDmc.managedObjectContext mergeChangesFromContextDidSaveNotification:cachedNotification];
		}
		[self.cachedChangeNotifications removeAllObjects];
		[self.changeNotificationsLock unlock];
		
		[self.msgCountsDmc saveContext];

		NSLog(@"Done with operation to update message filter counts");


	}
	@catch (NSException *exception)
	{
		// If the message counting fails for some reason, it is not critical. The counts
		// are only used for display in the UI.
	}
	@finally 
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self 
				name:NSManagedObjectContextDidSaveNotification 
				object:msgCountsDmc.managedObjectContext];

		[[NSNotificationCenter defaultCenter] removeObserver:self 
				name:NSManagedObjectContextDidSaveNotification 
				object:mainThreadDmc.managedObjectContext];

		self.msgCountsDmc = nil;
	}

}


@end
