//
//  FolderInfo.m
//  MailCleaner
//
//  Created by Steve Roehling on 6/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FolderInfo.h"
#import "EmailInfo.h"

NSString * const FOLDER_INFO_ENTITY_NAME = @"FolderInfo";

@implementation FolderInfo

@dynamic fullyQualifiedName;

// Inverse relationship
@dynamic emailFolderInfo;

@end
