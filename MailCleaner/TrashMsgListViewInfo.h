//
//  TrashMsgListViewInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataModelController;

@interface TrashMsgListViewInfo : NSObject
{
	@private
		DataModelController *emailInfoDmc;
		DataModelController *appDmc;
		NSPredicate *msgListPredicate;
		NSString *listHeader;
		NSString *listSubheader;

}

@property(nonatomic,retain) DataModelController *emailInfoDmc;
@property(nonatomic,retain) DataModelController *appDmc;
@property(nonatomic,retain) NSPredicate *msgListPredicate;
@property(nonatomic,retain) NSString *listHeader;
@property(nonatomic,retain) NSString *listSubheader;

-(id)initWithEmailInfoDataModelController:(DataModelController*)theEmailInfoDmc
	andAppDataModelController:(DataModelController*)theAppDmc
	andMsgListPredicate:(NSPredicate *)theMsgListPredicate 
	andListHeader:(NSString*)theHeader andListSubheader:(NSString*)theSubHeader;



@end
