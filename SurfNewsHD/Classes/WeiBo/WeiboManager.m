//
//  WeiboManager.m
//  SurfNewsHD
//
//  Created by SYZ on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "WeiboManager.h"

@implementation WeiboManager

+ (WeiboManager*)sharedInstance
{
    static WeiboManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WeiboManager alloc] init];
    });
    return sharedInstance;
}

- (void)getSinaWeiboUserFriendsWithCursor:(NSInteger)cursor complete:(void (^)(BOOL, NSArray*, int, int))handler
{
    NSURLRequest* request = [WeiboRequestGenerator getSinaWeiboUserFriendsRequestWithCursor:cursor];
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
         if (!error) {
             NSStringEncoding encoding = [[[fetcher response] textEncodingName] convertToStringEncoding];
             NSString *body = [[NSString alloc] initWithData:data encoding:encoding];
             GetSinaWeiboUserFriendsResponse *resp = [EzJsonParser deserializeFromJson:body AsType:[GetSinaWeiboUserFriendsResponse class]];
             handler(YES, resp.users, resp.next_cursor, resp.total_number);
         } else {
             handler(YES, nil, 0, 0);
         }
    }];
}

@end
