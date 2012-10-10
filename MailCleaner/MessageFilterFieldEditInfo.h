//
//  MessageFilterFieldEditInfo.h
//
//  Created by Steve Roehling on 5/18/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ManagedObjectFieldEditInfo.h"
#import "FieldEditInfo.h"

@class MessageFilter;
@class ValueSubtitleTableCell;

@interface MessageFilterFieldEditInfo : NSObject <FieldEditInfo> {
	@private
		MessageFilter *msgFilter;
		ValueSubtitleTableCell *valueCell;


}

@property(nonatomic,retain) MessageFilter *msgFilter;
@property(nonatomic,retain) ValueSubtitleTableCell *valueCell;

-(id)initWithMsgFilter:(MessageFilter*)theMsgFilter;

@end
