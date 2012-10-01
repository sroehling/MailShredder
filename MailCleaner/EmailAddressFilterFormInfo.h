//
//  EmailAddressFilterFormInfo.h
//  MailCleaner
//
//  Created by Steve Roehling on 9/29/12.
//
//

#import <Foundation/Foundation.h>

@class EmailAddressFilter;

@interface EmailAddressFilterFormInfo : NSObject
{
	@private
		EmailAddressFilter *emailAddressFilter;
		BOOL selectFromSenders;
		BOOL selectFromRecipients;
    
}

@property(nonatomic,retain) EmailAddressFilter *emailAddressFilter;
@property BOOL selectFromSenders;
@property BOOL selectFromRecipients;

-(id)initWithEmailAddressFilter:(EmailAddressFilter*)theEmailAddrFilter;

@end
