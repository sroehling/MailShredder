//
//  SentReceivedFilterFieldEditInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 10/3/12.
//
//

#import "SentReceivedFilterFieldEditInfo.h"
#import "SentReceivedFilter.h"

@implementation SentReceivedFilterFieldEditInfo

@synthesize sentReceivedFilter;

-(void)dealloc
{
	[sentReceivedFilter release];
	[super dealloc];
}

-(id)initWithSentReceivedFilter:(SentReceivedFilter *)theFilter
{
	assert(theFilter != nil);
	self = [super initWithManagedObj:theFilter 
		andCaption:[theFilter filterSynopsis] 
		andContent:nil andSubtitle:[theFilter filterSubtitle]];
	if(self)
	{
		self.sentReceivedFilter = theFilter;
		self.sentReceivedFilter.selectionFlagForSelectableObjectTableView = FALSE;
	}
	return self;
}


-(id)initWithManagedObj:(NSManagedObject *)theFieldObj andCaption:(NSString *)theCaption andContent:(NSString *)theContent
{
	assert(0);
	return nil;
}

-(id)initWithManagedObj:(NSManagedObject *)theFieldObj andCaption:(NSString *)theCaption andContent:(NSString *)theContent andSubtitle:(NSString *)theSubtitle
{
	assert(0);
	return nil;
}


- (BOOL)isSelected
{
	return self.sentReceivedFilter.selectionFlagForSelectableObjectTableView;
}

- (void)updateSelection:(BOOL)isSelected
{
	self.sentReceivedFilter.selectionFlagForSelectableObjectTableView = isSelected;
}


@end
