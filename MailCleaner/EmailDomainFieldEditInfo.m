//
//  EmailDomainFieldEditInfo.m
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "EmailDomainFieldEditInfo.h"
#import "EmailDomain.h"
#import "DataModelController.h"
#import "EmailDomainFilter.h"

static CGFloat const EMAIL_DOMAIN_CELL_HEIGHT = 25.0f;
static NSString * const EMAIL_DOMAIN_FIELD_CELL_ID = @"EmailDomainFieldCellID";
static CGFloat const ROW_HEIGHT_WITH_DELETE = 35.0f;

@implementation EmailDomainFieldEditInfo

@synthesize emailDomain;
@synthesize parentFilter;

-(id)initWithEmailDomain:(EmailDomain*)theEmailDomain
{
	self = [super init];
	if(self)
	{
		self.emailDomain = theEmailDomain;
	}
	return self;
}

-(void)dealloc
{
	[emailDomain release];
	[parentFilter release];
	[super dealloc];
}  


- (BOOL)isSelected
{
	return self.emailDomain.isSelectedForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	self.emailDomain.isSelectedForSelectableObjectTableView = isSelected;
}


-(BOOL)supportsDelete
{
	return (self.parentFilter != nil)?TRUE:FALSE;
}


-(void)deleteObject:(DataModelController*)dataModelController
{
	assert([self supportsDelete]);
	[self.parentFilter removeSelectedDomainsObject:self.emailDomain];
}


- (CGFloat)cellHeightForWidth:(CGFloat)width
{
	CGFloat normalHeight =  EMAIL_DOMAIN_CELL_HEIGHT;
	
	if([self supportsDelete])
	{
		return MAX(ROW_HEIGHT_WITH_DELETE,normalHeight);
	}
	else
	{
		return normalHeight;
	}
}

- (UITableViewCell*)cellForFieldEdit:(UITableView *)tableView
{
    assert(tableView!=nil);
	
	UITableViewCell *tableCell = [tableView dequeueReusableCellWithIdentifier:EMAIL_DOMAIN_FIELD_CELL_ID];
	if(tableCell == nil)
	{
		tableCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:EMAIL_DOMAIN_FIELD_CELL_ID] autorelease];
	}
	
	tableCell.textLabel.text = self.emailDomain.domainName;
	tableCell.textLabel.font = [UIFont boldSystemFontOfSize:13.0f];
	
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
    return self.emailDomain;
}

- (NSString*)detailTextLabel
{
    return @"N/A";
}

- (NSString*)textLabel
{
    return @"N/A";
}


@end
