//
//  MsgHandlingRuleFieldEditInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 5/31/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FieldEditInfo.h"

@protocol FormInfoCreator;
@class MsgHandlingRule;
@class FormFieldWithSubtitleTableCell;

@interface MsgHandlingRuleFieldEditInfo : NSObject <FieldEditInfo> {
	@private
		MsgHandlingRule *rule;
		FormFieldWithSubtitleTableCell *ruleCell;
		id<FormInfoCreator> subFormInfoCreator;

}

@property(nonatomic,retain) id<FormInfoCreator> subFormInfoCreator;
@property(nonatomic,retain) MsgHandlingRule *rule;
@property(nonatomic,retain) FormFieldWithSubtitleTableCell *ruleCell;

-(id)initWithMsgHandlingRule:(MsgHandlingRule*)theRule
	andSubFormInfoCreator:(id<FormInfoCreator>)theFormInfoCreator;

@end
