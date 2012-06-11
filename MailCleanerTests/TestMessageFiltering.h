//
//  TestMessageFiltering.h
//  MailCleaner
//
//  Created by Steve Roehling on 6/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class SharedAppVals;
@class DataModelController;

@interface TestMessageFiltering : SenTestCase
{
	@private
		SharedAppVals *testAppVals;
		DataModelController *appDataDmc;
		DataModelController *emailInfoDmc;
		NSInteger currMessageId;
}

@property(nonatomic,retain) SharedAppVals *testAppVals;
@property(nonatomic,retain) DataModelController *appDataDmc;
@property(nonatomic,retain) DataModelController *emailInfoDmc;

@end
