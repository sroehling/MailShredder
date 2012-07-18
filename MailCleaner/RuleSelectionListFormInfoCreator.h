//
//  RuleSelectionListFormInfoCreator.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FormInfoCreator.h"

@interface RuleSelectionListFormInfoCreator : NSObject <FormInfoCreator>
{
	@private
		DataModelController *emailInfoDmc;
}

@property(nonatomic,retain) DataModelController *emailInfoDmc;

-(id)initWithEmailInfoDataModelController:(DataModelController*)theEmailInfoDmc;

@end
