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
NSInteger const MAX_SPECIFIC_DOMAIN_SYNOPSIS = 2;

@implementation EmailDomainFilter

@dynamic selectedDomains;

// Inverse relationships
@dynamic messageFilterDomainFilter;
@dynamic msgHandlingRuleDomainFilter;

-(NSString*)filterSynopsisShort
{
	if([self.selectedDomains count] == 0)
	{
		return LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_NONE_TITLE");
	}
	else 
	{
		return LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_SELECTED");
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
			LOCALIZED_STR(@"EMAIL_DOMAIN_FILTER_SELECTED"),[self subFilterSynopsis]];
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
		return matchSpecificDomains;
	}
}


@end
