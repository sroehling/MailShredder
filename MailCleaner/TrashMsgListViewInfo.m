//
//  TrashMsgListViewInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 7/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrashMsgListViewInfo.h"
#import "DataModelController.h"
#import "StringValidation.h"

@implementation TrashMsgListViewInfo

@synthesize listHeader;
@synthesize listSubheader;
@synthesize emailInfoDmc;
@synthesize msgListPredicate;
@synthesize appDmc;

-(id)initWithEmailInfoDataModelController:(DataModelController*)theEmailInfoDmc
	andAppDataModelController:(DataModelController*)theAppDmc
	andMsgListPredicate:(NSPredicate *)theMsgListPredicate 
	andListHeader:(NSString*)theHeader andListSubheader:(NSString*)theSubHeader
{
	self = [super init];
	if(self)
	{
		assert([StringValidation nonEmptyString:theHeader]);
		assert([StringValidation nonEmptyString:theSubHeader]);
		assert(theEmailInfoDmc != nil);
		assert(theAppDmc != nil);
		assert(theMsgListPredicate != nil);
	
		self.emailInfoDmc = theEmailInfoDmc;
		self.appDmc = theAppDmc;
		self.listHeader = theHeader;
		self.listSubheader = theSubHeader;
		self.msgListPredicate = theMsgListPredicate;
	}
	return self;
}

-(void)dealloc
{
	[listHeader release];
	[listSubheader release];
	[emailInfoDmc release];
	[appDmc release];
	[msgListPredicate release];
	[super dealloc];
}

@end
