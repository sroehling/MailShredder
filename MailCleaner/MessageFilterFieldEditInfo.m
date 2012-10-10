//
//  MessageFilterFieldEditInfo.m
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "MessageFilterFieldEditInfo.h"
#import "MessageFilter.h"
#import "ValueSubtitleTableCell.h"
#import "ColorHelper.h"
#import "LocalizationHelper.h"

@implementation MessageFilterFieldEditInfo

@synthesize valueCell;
@synthesize msgFilter;

-(id)initWithMsgFilter:(MessageFilter *)theMsgFilter
{
	self = [super init];
	if(self)
	{
		self.valueCell = [[[ValueSubtitleTableCell alloc] init] autorelease];
		self.valueCell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.valueCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

		assert(theMsgFilter != nil);
		self.msgFilter = theMsgFilter;

	}
	return self;
}

- (id) init
{
    assert(0); // should not be called
	return nil;
}

- (NSString*)textLabel
{
	return @"";
}

- (NSString*)detailTextLabel
{
	return @"";
}


- (BOOL)fieldIsInitializedInParentObject
{
	return TRUE;
}

- (void)disableFieldAccess
{
	// no-op
}

- (NSManagedObject*) managedObject
{
	return self.msgFilter;
}


- (void) configureValueCell
{
	self.valueCell.caption.text = LOCALIZED_STR(@"MESSAGE_FILTER_TITLE");
	self.valueCell.valueDescription.textColor = [ColorHelper blueTableTextColor];
	self.valueCell.valueDescription.text = @"None (TBD)";
	self.valueCell.valueSubtitle.text = @"";
}

- (UIViewController*)fieldEditController:(FormContext*)parentContext
{    	      
	assert(0); // not implemented yet.
    return nil;
}


- (CGFloat)cellHeightForWidth:(CGFloat)width
{
	[self configureValueCell];
	return [self.valueCell cellHeight];
}

-(UITableViewCell*)cellForFieldEdit:(UITableView *)tableView
{
	[self configureValueCell];
    return self.valueCell;
}



-(void)dealloc
{
	[valueCell release];
	[msgFilter release];
	[super dealloc];
}

@end
