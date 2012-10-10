//
//  EmailAddressFilterTableConfigurator.m
//
//  Created by Steve Roehling on 9/28/12.
//
//

#import "EmailAddressSelectionTableConfigurator.h"
#import "DataModelController.h"
#import "EmailAddress.h"
#import "SharedAppVals.h"
#import "EmailAddressFilterFormInfo.h"
#import "EmailAddressFilter.h"

@implementation EmailAddressSelectionTableConfigurator

@synthesize addressFrc;
@synthesize dmcForAddresses;
@synthesize filterFormInfo;

-(void)dealloc
{
	[addressFrc release];
	[dmcForAddresses release];
	[filterFormInfo release];
	[super dealloc];
}

-(id)init
{
	assert(0);
	return nil;
}

-(void)configureFetchedResultsWithSearchText:(NSString*)searchText
{
	NSFetchRequest *addressFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_ADDRESS_ENTITY_NAME
		inManagedObjectContext:dmcForAddresses.managedObjectContext];
		
	[addressFetchRequest setEntity:entity];

	NSSortDescriptor *sortSectionDesc = [[[NSSortDescriptor alloc]
		initWithKey:EMAIL_ADDRESS_SECTION_NAME_KEY ascending:TRUE] autorelease];
	NSSortDescriptor *sortAddressDesc = [[[NSSortDescriptor alloc]
		initWithKey:EMAIL_ADDRESS_SORT_KEY ascending:TRUE] autorelease];
	[addressFetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortSectionDesc,sortAddressDesc,nil]];
	
	
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:dmcForAddresses];
	NSPredicate *currentAcctPredicate = [NSPredicate predicateWithFormat:@"%K=%@",
		EMAIL_ADDRESS_ACCT_KEY,sharedVals.currentEmailAcct];
	
	NSMutableArray *fetchPredicates = [[[NSMutableArray alloc] init] autorelease];
	[fetchPredicates addObject:currentAcctPredicate];
	
	if(searchText.length > 0)
	{
		NSPredicate *searchAddr = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",
			EMAIL_ADDRESS_ADDRESS_KEY,searchText];
		
		NSPredicate *searchName = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",
			EMAIL_ADDRESS_NAME_KEY,searchText];
	
		NSPredicate *searchNameOrAddr =[NSCompoundPredicate orPredicateWithSubpredicates:
			[NSArray arrayWithObjects:searchAddr,searchName,nil]];
	
		[fetchPredicates addObject:searchNameOrAddr];
	}
	
	if(self.filterFormInfo.selectFromRecipients && self.filterFormInfo.selectFromSenders)
	{
		NSPredicate *matchSenders = [NSPredicate predicateWithFormat:@"%K = %@",
				EMAIL_ADDRESS_IS_SENDER_KEY,[NSNumber numberWithBool:TRUE]];
		NSPredicate *matchRecipients = [NSPredicate predicateWithFormat:@"%K = %@",
				EMAIL_ADDRESS_IS_RECIPIENT_KEY,[NSNumber numberWithBool:TRUE]];
		NSPredicate *matchSenderOrRecipient =
			[NSCompoundPredicate orPredicateWithSubpredicates:
				[NSArray arrayWithObjects:matchRecipients,matchSenders,nil]];
		[fetchPredicates addObject:matchSenderOrRecipient];
	}
	
	else if(self.filterFormInfo.selectFromSenders)
	{
		NSPredicate *matchSenders = [NSPredicate predicateWithFormat:@"%K = %@",
				EMAIL_ADDRESS_IS_SENDER_KEY,[NSNumber numberWithBool:TRUE]];
		[fetchPredicates addObject:matchSenders];
	}
	
	else if(self.filterFormInfo.selectFromRecipients)
	{
		NSPredicate *matchRecipients = [NSPredicate predicateWithFormat:@"%K = %@",
				EMAIL_ADDRESS_IS_RECIPIENT_KEY,[NSNumber numberWithBool:TRUE]];
		[fetchPredicates addObject:matchRecipients];
	}
	
	NSPredicate *dontMatchAlreadySelectedAddresses = [NSCompoundPredicate notPredicateWithSubpredicate:
		[NSPredicate predicateWithFormat:@"SELF IN %@",
		self.filterFormInfo.emailAddressFilter.selectedAddresses]];
	[fetchPredicates addObject:dontMatchAlreadySelectedAddresses];
	
	NSPredicate *overallPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fetchPredicates];
		
	[addressFetchRequest setPredicate:overallPredicate];
	
	self.addressFrc = [[[NSFetchedResultsController alloc]
		initWithFetchRequest:addressFetchRequest
		managedObjectContext:dmcForAddresses.managedObjectContext
		sectionNameKeyPath:EMAIL_ADDRESS_SECTION_NAME_KEY cacheName:nil] autorelease];
		

}

-(id)initWithDataModelController:(DataModelController*)theDmcForAddresses
	andFilterFormInfo:(EmailAddressFilterFormInfo *)theFilterFormInfo
	
{
	self = [super init];
	if(self)
	{
		assert(theFilterFormInfo != nil);
		self.filterFormInfo = theFilterFormInfo;
	
		self.dmcForAddresses = theDmcForAddresses;
		[self configureFetchedResultsWithSearchText:@""];
		
		

	}
	return self;
}

-(NSFetchedResultsController*)fetchedResultsController
{
	return self.addressFrc;
}

-(void)configCoreDataTableRowCellForRowObject:(id)rowObject inTableCell:(UITableViewCell*)tableCell
{
	assert([rowObject isKindOfClass:[EmailAddress class]]);
	EmailAddress *emailAddr = rowObject;

	tableCell.textLabel.text = emailAddr.name;
	tableCell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
	tableCell.detailTextLabel.text = emailAddr.address;
	tableCell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];

	tableCell.selectionStyle = UITableViewCellSelectionStyleNone;

}

-(UITableViewCell *)coreDataTableTableCellForRowObject:(id)rowObject
{
	
	UITableViewCell *tableCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
				reuseIdentifier:@"EmailAddressCellID"] autorelease];
		
	return tableCell;
}



@end
