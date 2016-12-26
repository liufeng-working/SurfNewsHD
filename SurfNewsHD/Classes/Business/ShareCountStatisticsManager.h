//
//  ShareCountStatisticsManager.h
//  SurfNewsHD
//
//  Created by SYZ on 14-5-15.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "EzJsonParser.h"
#import "SurfRequestGenerator.h"

typedef enum {
    SMS_SHARE = 0,
    SNS_SHARE,
} ShareType;

@interface ShareCountStatisticsManager : NSObject

+ (ShareCountStatisticsManager*)sharedInstance;

//统计分享
//activeId不为空时是分享活动
//activeId为@""时是分享快讯，目前android有这个功能
- (void)shareCountStatisticsWithActiveId:(NSString *)activeId shareType:(ShareType)type;

@end
