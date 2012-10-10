//
//  TestMessageFiltering.h
//
//  Created by Steve Roehling on 6/1/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@class SharedAppVals;
@class DataModelController;
@class EmailFolder;

@interface TestMessageFiltering : SenTestCase
{
	@private
		SharedAppVals *testAppVals;
		DataModelController *appDataDmc;
		EmailFolder *testFolder;
		NSInteger currMessageId;
}

@property(nonatomic,retain) SharedAppVals *testAppVals;
@property(nonatomic,retain) EmailFolder *testFolder;
@property(nonatomic,retain) DataModelController *appDataDmc;

@end
