//
//  EmailFolder.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EmailFolder.h"

NSString * const EMAIL_FOLDER_ENTITY_NAME = @"EmailFolder";

@implementation EmailFolder

@dynamic folderName;
@dynamic emailFolderFilterSelectedFolders;

// This property is not persisted via CoreData. It is used for tracking of 
// selection of the EmailAddress in a table view.
@synthesize isSelectedForSelectableObjectTableView;


@end
