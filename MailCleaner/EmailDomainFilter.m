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

@implementation EmailDomainFilter

@dynamic selectedDomains;

// Inverse relationships
@dynamic messageFilterDomainFilter;
@dynamic msgHandlingRuleDomainFilter;

-(NSString*)filterSynopsis
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
