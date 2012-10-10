//
//  MailDeleteCompletionInfo.h
//
//  Created by Steve Roehling on 9/18/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MailDeleteCompletionInfo : NSObject
{
	@private
		NSString *destinationFolder;
		NSUInteger numMsgsDeleted;
		BOOL didEraseMsgs;
}

@property(nonatomic,retain) NSString *destinationFolder;
@property NSUInteger numMsgsDeleted;
@property BOOL didEraseMsgs;

-(NSString*)completionSummary;

@end
