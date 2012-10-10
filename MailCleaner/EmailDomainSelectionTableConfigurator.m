//
//  EmailDomainSelectionTableConfigurator.m
//
//  Created by Steve Roehling on 9/30/12.
//
//

#import "EmailDomainSelectionTableConfigurator.h"
#import "EmailDomain.h"
#import "SharedAppVals.h"
#import "DataModelController.h"
#import "EmailDomainFilter.h"

@implementation EmailDomainSelectionTableConfigurator

@synthesize domainFrc;
@synthesize dmcForDomains;
@synthesize domainFilter;

-(void)dealloc
{
	[domainFrc release];
	[dmcForDomains release];
	[domainFilter release];
	[super dealloc];
}

-(id)init
{
	assert(0);
	return nil;
}

-(void)configureFetchedResultsWithSearchText:(NSString*)searchText
{
	NSFetchRequest *domainFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
	
	NSEntityDescription *entity = [NSEntityDescription
		entityForName:EMAIL_DOMAIN_ENTITY_NAME
		inManagedObjectContext:dmcForDomains.managedObjectContext];
		
	[domainFetchRequest setEntity:entity];

	NSSortDescriptor *sortSectionDesc = [[[NSSortDescriptor alloc]
		initWithKey:EMAIL_DOMAIN_SECTION_NAME_KEY ascending:TRUE] autorelease];
	NSSortDescriptor *sortNameDesc = [[[NSSortDescriptor alloc]
		initWithKey:EMAIL_DOMAIN_NAME_KEY ascending:TRUE] autorelease];
		
	[domainFetchRequest setSortDescriptors:
		[NSArray arrayWithObjects:sortSectionDesc,sortNameDesc,nil]];
	
	
	SharedAppVals *sharedVals = [SharedAppVals getUsingDataModelController:dmcForDomains];
	NSPredicate *currentAcctPredicate = [NSPredicate predicateWithFormat:@"%K=%@",
		EMAIL_DOMAIN_ACCT_KEY,sharedVals.currentEmailAcct];
	
	NSMutableArray *fetchPredicates = [[[NSMutableArray alloc] init] autorelease];
	[fetchPredicates addObject:currentAcctPredicate];
	
	if(searchText.length > 0)
	{
		NSPredicate *searchDomainName = [NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@",
			EMAIL_DOMAIN_NAME_KEY,searchText];
		
		[fetchPredicates addObject:searchDomainName];
	}
	
	
	// TODO - To implement recipient domain selection, a flag needs to be
	// passed in to indicate whether to select senders' domains or recipients'
	// domains.
	NSPredicate *matchSenderDomains = [NSPredicate predicateWithFormat:@"%K = %@",
				EMAIL_DOMAIN_IS_SENDER_KEY,[NSNumber numberWithBool:TRUE]];
		[fetchPredicates addObject:matchSenderDomains];

	
	
	NSPredicate *dontMatchAlreadySelectedDomains = [NSCompoundPredicate notPredicateWithSubpredicate:
		[NSPredicate predicateWithFormat:@"SELF IN %@",
		self.domainFilter.selectedDomains]];
	[fetchPredicates addObject:dontMatchAlreadySelectedDomains];
	
	NSPredicate *overallPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:fetchPredicates];
		
	[domainFetchRequest setPredicate:overallPredicate];
	
	self.domainFrc = [[[NSFetchedResultsController alloc]
		initWithFetchRequest:domainFetchRequest
		managedObjectContext:self.dmcForDomains.managedObjectContext
		sectionNameKeyPath:EMAIL_DOMAIN_SECTION_NAME_KEY cacheName:nil] autorelease];
		

}

-(id)initWithDataModelController:(DataModelController*)theDmcForDomains
	andDomainFilter:(EmailDomainFilter *)theDomainFilter
	
{
	self = [super init];
	if(self)
	{
		assert(theDomainFilter != nil);
		self.domainFilter = theDomainFilter;
	
		self.dmcForDomains = theDmcForDomains;
		[self configureFetchedResultsWithSearchText:@""];
	}
	return self;
}

-(NSFetchedResultsController*)fetchedResultsController
{
	return self.domainFrc;
}

-(void)configCoreDataTableRowCellForRowObject:(id)rowObject inTableCell:(UITableViewCell*)tableCell
{
	assert([rowObject isKindOfClass:[EmailDomain class]]);
	EmailDomain *emailDomain = rowObject;

	tableCell.textLabel.text = emailDomain.domainName;
	tableCell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];

	tableCell.selectionStyle = UITableViewCellSelectionStyleNone;

}

-(UITableViewCell *)coreDataTableTableCellForRowObject:(id)rowObject
{
	
	UITableViewCell *tableCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
				reuseIdentifier:@"EmailDomainCellID"] autorelease];
		
	return tableCell;
}



@end
