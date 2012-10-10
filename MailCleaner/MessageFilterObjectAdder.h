//
//  RuleObjectAdder.h
//
//  Created by Steve Roehling on 5/30/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableViewObjectAdder.h"
#import "GenericFieldBasedTableAddViewController.h"

@interface MessageFilterObjectAdder : NSObject <TableViewObjectAdder> 
{
	@private
		DataModelController *mainDmc;
		DataModelController *addFilterDmc;
}

@property(nonatomic,retain) DataModelController *mainDmc;
@property(nonatomic,retain) DataModelController *addFilterDmc;

@end
