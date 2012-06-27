//
//  EmailDomainFilterDomainAdder.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TableViewObjectAdder.h"
#import "MultipleSelectionAddViewController.h"

@class EmailDomainFilter;

@interface EmailDomainFilterDomainAdder : NSObject 
	<TableViewObjectAdder,MultipleSelectionAddListener> 
{
	@private
		EmailDomainFilter *emailDomainFilter;
}

@property(nonatomic,retain) EmailDomainFilter *emailDomainFilter;

-(id)initWithEmailDomainFilter:(EmailDomainFilter*)theDomainFilter;

@end
