//
//  ShareCountStatisticsManager.m
//  SurfNewsHD
//
//  Created by SYZ on 14-5-15.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "ShareCountStatisticsManager.h"

@implementation ShareCountStatisticsManager

+ (ShareCountStatisticsManager *)sharedInstance
{
    static ShareCountStatisticsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShareCountStatisticsManager alloc] init];
    });
    return sharedInstance;
}

- (void)shareCountStatisticsWithActiveId:(NSString *)activeId shareType:(ShareType)type
{
    id req = [SurfRequestGenerator shareCountStatisticsRequestWithActiveId:activeId shareType:type];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* err) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        //不管提交失败还是成功,直接进行分享
        if(err) {
            
        }
//        else {
//            NSString *body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
//            DJLog(@"分享统计信息提交 = %@", body);
//        }
    }];
}

@end
