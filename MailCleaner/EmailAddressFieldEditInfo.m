//
//  EmailAddressFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailAddressFieldEditInfo.h"
#import "EmailAddress.h"
#import "EmailAddressFilter.h"

static CGFloat ROW_HEIGHT_ADDRESS_AND_NAME = 40.0f;
static CGFloat ROW_HEIGHT_ADDRESS_ONLY = 25.0f;

static NSUInteger CELL_TYPE_ADDRESS_AND_NAME = 0;
static NSUInteger CELL_TYPE_ADDRESS_ONLY = 1;

static NSString *ADDRESS_AND_NAME_CELL_ID = @"EmailAddressAndNameCell";
static NSString *ADDRESS_ONLY_CELL_ID = @"EmailAddressOnlyCell";

@implementation EmailAddressFieldEditInfo

@synthesize emailAddr;
@synthesize parentFilter;

-(id)initWithEmailAddress:(EmailAddress*)theEmailAddr
{
	self = [super init];
	if(self)
	{
		self.emailAddr = theEmailAddr;
	}
	return self;
}


-(void)dealloc
{
	[emailAddr release];
	[parentFilter release];
	[super dealloc];
}  


- (BOOL)isSelected
{
	return self.emailAddr.isSelectedForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	self.emailAddr.isSelectedForSelectableObjectTableView = isSelected;
}


-(BOOL)supportsDelete
{
	return (self.parentFilter != nil)?TRUE:FALSE;
}


-(void)deleteObject:(DataModelController*)dataModelController
{
	assert([self supportsDelete]);
	[self.parentFilter removeSelectedAddressesObject:self.emailAddr];
}

- (NSString*)detailTextLabel
{
    return @"N/A";
}

- (NSString*)textLabel
{
    return @"N/A";
}

-(NSUInteger)cellType
{
	if([self.emailAddr.name length] > 0)
	{
		
		if([self.emailAddr.name isEqualToString:self.emailAddr.address])
		{
			return CELL_TYPE_ADDRESS_ONLY;
		}
		else
		{
			return CELL_TYPE_ADDRESS_AND_NAME;
		}

	}
	else
	{
		return CELL_TYPE_ADDRESS_ONLY;
	}

}

- (CGFloat)cellHeightForWidth:(CGFloat)width
{
	return [self cellType] == CELL_TYPE_ADDRESS_AND_NAME?
		ROW_HEIGHT_ADDRESS_AND_NAME:ROW_HEIGHT_ADDRESS_ONLY;
}

- (UITableViewCell*)cellForFieldEdit:(UITableView *)tableView
{
    assert(tableView!=nil);
	
	UITableViewCell *tableCell;
	
	if([self cellType] == CELL_TYPE_ADDRESS_AND_NAME)
	{
		tableCell = [tableView dequeueReusableCellWithIdentifier:ADDRESS_AND_NAME_CELL_ID];
		if(tableCell == nil)
		{
			tableCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
				reuseIdentifier:ADDRESS_AND_NAME_CELL_ID] autorelease];
		}
		
		tableCell.textLabel.text = self.emailAddr.name;
		tableCell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
		tableCell.detailTextLabel.text = self.emailAddr.address;
		tableCell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
	}
	else
	{
		tableCell = [tableView dequeueReusableCellWithIdentifier:ADDRESS_ONLY_CELL_ID];
		if(tableCell == nil)
		{
			tableCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
				reuseIdentifier:ADDRESS_ONLY_CELL_ID] autorelease];
		}
		
		tableCell.textLabel.text = self.emailAddr.address;
		tableCell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
	}
	
	return tableCell;
		
 }


- (BOOL)fieldIsInitializedInParentObject
{
    return FALSE;
}

- (void)disableFieldAccess
{
    // no-op
    // TBD - should this be a no-op
}

- (NSManagedObject*) managedObject
{
    return self.emailAddr;
}

@end
