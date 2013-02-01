//
//  StressTestSyncAndDelete.h
//  MailShredder
//
//  Created by Steve Roehling on 1/25/13.
//
//

#import <SenTestingKit/SenTestingKit.h>

@class SharedAppVals;
@class DataModelController;
@class TestMailSyncProgressDelegate;
@class TestMailDeleteProgressDelegate;


@interface StressTestSyncAndDelete : SenTestCase
{
    @private
        SharedAppVals *appValsForTest;
        DataModelController *appDataDmc;
        TestMailSyncProgressDelegate *progressDelegate;
        TestMailDeleteProgressDelegate *deleteProgressDelegate;
}

@property(nonatomic,retain) SharedAppVals *appValsForTest;
@property(nonatomic,retain) DataModelController *appDataDmc;
@property(nonatomic,retain) TestMailSyncProgressDelegate *progressDelegate;
@property(nonatomic,retain) TestMailDeleteProgressDelegate *deleteProgressDelegate;


@end
