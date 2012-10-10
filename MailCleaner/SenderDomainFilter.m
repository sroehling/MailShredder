//
//  SenderDomainFilter.m
//
//  Created by Steve Roehling on 10/2/12.
//
//

#import "SenderDomainFilter.h"
#import "MessageFilter.h"
#import "EmailInfo.h"

NSString * const SENDER_DOMAIN_FILTER_ENTITY_NAME = @"SenderDomainFilter";

@implementation SenderDomainFilter

@dynamic messageFilterSenderDomainFilter;

-(NSPredicate*)filterPredicate
{
	if([self.selectedDomains count] == 0)
	{
		return [NSPredicate predicateWithValue:TRUE];
	}
	else 
	{
		NSPredicate *matchSpecificDomains = [NSPredicate predicateWithFormat:@"%K IN %@",
				EMAIL_INFO_SENDER_DOMAIN_KEY,self.selectedDomains];
			
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


@end
