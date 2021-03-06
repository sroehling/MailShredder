//
//  EmailAccountFormPopulator.h
//
//  Created by Steve Roehling on 9/6/12.
//  Copyright (c) 2012 Resultra, LLC. All rights reserved.
//

#import "FormPopulator.h"

@class EmailAccount;

@interface EmailAccountFormPopulator : FormPopulator

-(void)populateEmailAccountNameField:(EmailAccount*)emailAccount;
-(void)populatePasswordField:(EmailAccount*)emailAccount;
-(void)populateUserNameField:(EmailAccount*)emailAccount;
-(void)populateIMAPHostNameField:(EmailAccount*)emailAccount;
-(void)populateEmailAddressField:(EmailAccount*)emailAccount;
-(void)populateMoveToDeleteFolderSetting:(EmailAccount*)emailAccount;
-(void)populateUseSSL:(EmailAccount*)emailAccount;
-(void)populatePortNumberField:(EmailAccount *)emailAccount;
-(void)populateDeleteMsgsField:(EmailAccount*)emailAccount;
-(void)populateSyncFoldersField:(EmailAccount*)emailAccount;

-(void)populateSyncOldMsgsFirst:(EmailAccount*)emailAccount;
-(void)populateMaxSyncMsgs:(EmailAccount*)emailAccount;

@end
