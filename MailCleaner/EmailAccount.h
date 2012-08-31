//
//  EmailAccount.h
//  MailCleaner
//
//  Created by Steve Roehling on 7/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString * const EMAIL_ACCOUNT_ENTITY_NAME;
extern NSString * const EMAIL_ACCOUNT_NAME_KEY;
extern NSInteger const EMAIL_ACCOUNT_NAME_MAX_LENGTH;
extern NSString * const EMAIL_ACCOUNT_USESSL_KEY;
extern NSString * const EMAIL_ACCOUNT_PORTNUM_KEY;
extern NSString * const EMAIL_ACCOUNT_ADDRESS_KEY;
extern NSString * const EMAIL_ACCOUNT_IMAPSERVER_KEY;
extern NSString * const EMAIL_ACCOUNT_USERNAME_KEY;

extern NSInteger const EMAIL_ACCOUNT_DEFAULT_PORT_SSL;
extern NSInteger const EMAIL_ACCOUNT_DEFAULT_PORT_NOSSL;

extern NSString * const EMAIL_ACCOUNT_KEYCHAIN_PREFIX;
extern NSString * const EMAIL_ACCOUNT_UNIQUEACCTID_KEY;

extern NSString * const EMAIL_ACCOUNT_DELETE_HANDLING_DELETE_MSG_KEY;
extern NSString * const EMAIL_ACCOUNT_DELETE_HANDLING_MOVE_TO_FOLDER_KEY;

@class DataModelController;
@class SharedAppVals;
@class KeychainFieldInfo;
@class EmailFolder;
@class EmailDomain;
@class EmailAddress;
@class EmailInfo;
@class MsgHandlingRule;
@class MessageFilter;

@interface EmailAccount : NSManagedObject
{
	@private
		BOOL isSelectedForSelectableObjectTableView;
}

@property (nonatomic, retain) NSString * acctName;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * imapServer;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * useSSL;
@property (nonatomic, retain) NSNumber * portNumber;

// Current and saved list of filters
@property (nonatomic, retain) MessageFilter *msgListFilter;
@property (nonatomic, retain) NSSet *savedMsgListFilters;

// The last time a successful synchronization with the 
// server took place. This is displaying status in the UI.
@property (nonatomic, retain) NSDate * lastSync;

@property BOOL isSelectedForSelectableObjectTableView;


// The uniqueAcctID property is used to cross-reference the account with the
// user name and password stored separately in the keychain.
@property (nonatomic, retain) NSString * uniqueAcctID;

// Inverse relationship
@property (nonatomic, retain) SharedAppVals *sharedAppValsCurrentEmailAcct;

+(EmailAccount*)defaultNewEmailAcctWithDataModelController:(DataModelController*)acctDmc;
-(KeychainFieldInfo*)passwordFieldInfo;

// Folders belonging to this account
@property (nonatomic, retain) NSSet *foldersInAcct;

// Domains, addresses used by messages in this account
@property (nonatomic, retain) NSSet *domainsInAcct;
@property (nonatomic, retain) NSSet *addressesInAcct;

@property (nonatomic, retain) NSSet *emailsInAcct;


// Limit sync to specific folders
@property (nonatomic, retain) NSSet *onlySyncFolders;

// The following properties determine how
// deletion takes place. The message is only
// deleted if the boolean flag deleteHandlingDeleteMsg is set. If 
// a folder is also specified, then the message
// is moved to the folder before deleting.
@property (nonatomic, retain) EmailFolder *deleteHandlingMoveToFolder;
@property (nonatomic, retain) NSNumber * deleteHandlingDeleteMsg;

-(NSMutableDictionary*)foldersByName;
-(NSMutableDictionary*)emailDomainsByDomainName;
-(NSMutableDictionary*)emailAddressesByName;

// Folders which are sychronized in this account. If there
// are no folders, then all the folders are synchronized.
-(NSDictionary*)syncFoldersByName;

@end

@interface EmailAccount (CoreDataGeneratedAccessors)

- (void)addFoldersInAcctObject:(EmailFolder *)value;
- (void)removeFoldersInAcctObject:(EmailFolder *)value;
- (void)addFoldersInAcct:(NSSet *)values;
- (void)removeFoldersInAcct:(NSSet *)values;

- (void)addDomainsInAcctObject:(EmailDomain *)value;
- (void)removeDomainsInAcctObject:(EmailDomain *)value;
- (void)addDomainsInAcct:(NSSet *)values;
- (void)removeDomainsInAcct:(NSSet *)values;

- (void)addAddressesInAcctObject:(EmailAddress *)value;
- (void)removeAddressesInAcctObject:(EmailAddress *)value;
- (void)addAddressesInAcct:(NSSet *)values;
- (void)removeAddressesInAcct:(NSSet *)values;

- (void)addEmailsInAcctObject:(EmailInfo *)value;
- (void)removeEmailsInAcctObject:(EmailInfo *)value;
- (void)addEmailsInAcct:(NSSet *)values;
- (void)removeEmailsInAcct:(NSSet *)values;

- (void)addOnlySyncFoldersObject:(EmailFolder *)value;
- (void)removeOnlySyncFoldersObject:(EmailFolder *)value;
- (void)addOnlySyncFolders:(NSSet *)values;
- (void)removeOnlySyncFolders:(NSSet *)values;

- (void)addSavedMsgListFiltersObject:(MessageFilter *)value;
- (void)removeSavedMsgListFiltersObject:(MessageFilter *)value;
- (void)addSavedMsgListFilters:(NSSet *)values;
- (void)removeSavedMsgListFilters:(NSSet *)values;

@end
