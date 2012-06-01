//
//  RuleObjectAdder.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewObjectAdder.h"

@interface RuleObjectAdder : NSObject <TableViewObjectAdder> 
{
	@private
		FormContext *currentContext;
}

@property(nonatomic,retain) FormContext *currentContext;

@end
