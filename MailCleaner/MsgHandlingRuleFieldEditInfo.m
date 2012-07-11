//
//  MsgHandlingRuleFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MsgHandlingRuleFieldEditInfo.h"
#import "MsgHandlingRule.h"
#import "FormContext.h"
#import "FormFieldWithSubtitleTableCell.h"
#import "GenericTableViewFactory.h"
#import "FormInfoCreator.h"
#import "GenericFieldBasedTableEditViewControllerFactory.h"

@implementation MsgHandlingRuleFieldEditInfo

@synthesize rule;
@synthesize ruleCell;
@synthesize subFormInfoCreator;

-(id)initWithMsgHandlingRule:(MsgHandlingRule*)theRule
	andSubFormInfoCreator:(id<FormInfoCreator>)theFormInfoCreator
{
	self = [super init];
	if(self)
	{
		self.rule = theRule;
		
		self.ruleCell = [[[FormFieldWithSubtitleTableCell alloc] initWithFrame:CGRectZero] autorelease];
		self.ruleCell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.ruleCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		assert(theFormInfoCreator != nil);
		self.subFormInfoCreator = theFormInfoCreator;

	}
	return self;
}

- (id) init
{
	assert(0); // must call init with caption, description, etc.
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

- (UIViewController*)fieldEditController:(FormContext*)parentContext
{
	GenericFieldBasedTableEditViewControllerFactory *theSubViewFactory = 
		[[[GenericFieldBasedTableEditViewControllerFactory alloc]
			initWithFormInfoCreator:self.subFormInfoCreator] autorelease];

	return [theSubViewFactory createTableView:parentContext];	
}


- (void)configureRuleCell
{
	self.ruleCell.caption.text = self.rule.ruleName;	
	self.ruleCell.subTitle.text = [self.rule ruleSynopsis];
}


- (CGFloat)cellHeightForWidth:(CGFloat)width
{
	[self configureRuleCell];
	return [self.ruleCell cellHeightForWidth:width];
}

- (UITableViewCell*)cellForFieldEdit:(UITableView *)tableView
{
	[self configureRuleCell];
    return self.ruleCell;
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
    return nil;
}


- (void)dealloc
{
	[ruleCell release];
	[subFormInfoCreator release];
	[rule release];
	[super dealloc];
}

-(BOOL)supportsDelete
{
	return TRUE;
}


- (void)deleteObject:(DataModelController*)dataModelController
{
	assert(self.rule != nil);
	[dataModelController deleteObject:self.rule];
	self.rule = nil;
}

@end
