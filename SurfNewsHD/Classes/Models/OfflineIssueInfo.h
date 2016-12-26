//
//  IssuesInfo.h
//  SurfNewsHD
//
//  Created by SYZ on 13-8-6.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OfflineIssueInfo : NSObject

@property long magId;
@property long issId;
@property long zipBytes;
@property NSString *name;
@property NSString *zipUrl;
@property NSString *localFileName;

//local only,used by OfflineDownloader
@property NSInteger issueStatus; //see OfflineIssueStatus in OfflineDownloader.h
@property long downloadedBytes; //bytes of .zip.tmp，仅在任务尚未下载完成时有意义
@property BOOL isDeleteStatus; //仅在期刊离线包下载页时有意义

@end

@interface OfflinesMagazines : NSObject

@property NSMutableArray *issues;

@end