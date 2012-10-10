//
//  DeleteRuleFormInfoCreator.h
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MessageFilter;
@class EmailAccount;

#import "FormInfoCreator.h"

@interface SavedMessageFilterFormInfoCreator : NSObject <FormInfoCreator> {
	@private
		MessageFilter *messageFilter;
		EmailAccount *emailAccount;
}

@property(nonatomic,retain) MessageFilter *messageFilter;
@property(nonatomic,retain) EmailAccount *emailAccount;

-(id)initWithEmailAcct:(EmailAccount*)theEmailAcct 
	andMessageFilter:(MessageFilter*)theMessageFilter;

@end