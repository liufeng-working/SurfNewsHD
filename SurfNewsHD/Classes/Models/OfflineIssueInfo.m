//
//  IssuesInfo.m
//  SurfNewsHD
//
//  Created by SYZ on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "OfflineIssueInfo.h"

@implementation OfflineIssueInfo

@synthesize issueStatus = __DO_NOT_SERIALIZE_;
@synthesize downloadedBytes = __DO_NOT_SERIALIZE_1;
@synthesize isDeleteStatus = __DO_NOT_SERIALIZE_2;

@end

@implementation OfflinesMagazines

@synthesize issues = __ELE_TYPE_OfflineIssueInfo;

@end