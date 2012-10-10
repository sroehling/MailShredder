//
//  EmailDomainFilterDomainAdder.h
//
//  Created by Steve Roehling on 6/26/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TableViewObjectAdder.h"
#import "MultipleSelectionAddViewController.h"
#import "MultipleSelectionAddListener.h"

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
