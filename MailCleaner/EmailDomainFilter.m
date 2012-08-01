//
//  EmailDomainFilter.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailDomainFilter.h"
#import "EmailDomain.h"
#import "MessageFilter.h"
#import "MsgHandlingRule.h"
#import "EmailInfo.h"
#import "LocalizationHelper.h"

NSString * const EMAIL_DOMAIN_FILTER_ENTITY_NAME = @"EmailDomainFilter";
NSString * const EMAIL_DOMAIN_FILTER_MATCH_UNSELECTED_KEY = @"matchUnselected";

NSInteger const MAX_SPECIFIC_DOMAIN_SYNOPSIS = 2;

@implementation EmailDomainFilter

@dynamic selectedDomains;
@dynamic matchUnselected;


// Inverse relationships
@dynamic messageFilterDomainFilter;
@dynamic msgHandlingRuleDomainFilter;

-(NSString*)filterSelectedPrefix
{
	if([self.matchUnselected boolValue])
	{
		return LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_UNSELECTED");
	}
	else 
	{
		return LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_SELECTED");
	}
}

-(NSString*)filterSynopsisShort
{
	if([self.selectedDomains count] == 0)
	{
		return LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_NONE_TITLE");
	}
	else 
	{
		return [self filterSelectedPrefix];
	}
}

-(NSString*)subFilterSynopsis
{
	NSInteger domainNum = 0;
	NSMutableArray *specificDomainNames = [[[NSMutableArray alloc] init] autorelease];
	for(EmailDomain *senderDomain in self.selectedDomains)
	{
		if(domainNum < MAX_SPECIFIC_DOMAIN_SYNOPSIS)
		{
			[specificDomainNames addObject:[NSString stringWithFormat:@"@%@",senderDomain.domainName]];
		}
		domainNum++;
	}
	if(domainNum <= MAX_SPECIFIC_DOMAIN_SYNOPSIS)
	{
		return [specificDomainNames componentsJoinedByString:@", "];
	}
	else
	{
		NSInteger remainingFolders = [self.selectedDomains count] - MAX_SPECIFIC_DOMAIN_SYNOPSIS;
		NSString *remainingFolderDesc = [NSString stringWithFormat:
			LOCALIZED_STR(@"EMAIL_FOLDER_FILTER_SELECTED_REMAINING_DOMAINS_FORMAT"),remainingFolders];
		return [NSString stringWithFormat:@"%@ %@",
			[specificDomainNames componentsJoinedByString:@", "],remainingFolderDesc];
	}
}

-(NSString*)filterSynopsis
{
	if([self.selectedDomains count] == 0)
	{
		return LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_NONE_TITLE");
	}
	else 
	{
		return [NSString stringWithFormat:@"%@ (%@)",
			[self filterSelectedPrefix],[self subFilterSynopsis]];
	}
}

-(NSPredicate*)filterPredicate
{
	if([self.selectedDomains count] == 0)
	{
		return [NSPredicate predicateWithValue:TRUE];
	}
	else 
	{
		NSMutableArray *specificDomainPredicates = [[[NSMutableArray alloc] init] autorelease];
		for(EmailDomain *senderDomain in self.selectedDomains)
		{
			[specificDomainPredicates addObject:[NSPredicate predicateWithFormat:@"%K == %@",
				EMAIL_INFO_DOMAIN_KEY,senderDomain.domainName]];
		}

		NSPredicate *matchSpecificDomains = 
			[NSCompoundPredicate orPredicateWithSubpredicates:specificDomainPredicates];
			
		if([self.matchUnselected boolValue])
		{
			return [NSCompoundPredicate notPredicateWithSubpredicate:matchSpecificDomains];
		}
		else 
		{
			return matchSpecificDomains;
		}
	}
}

-(void)setDomains:(NSSet*)selectedDomains
{
	// Clear out the list of current domains
	NSSet *existingDomains = [NSSet setWithSet:self.selectedDomains];
	[self removeSelectedDomains:existingDomains];
	
	// Add the selected domains
	[self addSelectedDomains:selectedDomains];
}

@end
