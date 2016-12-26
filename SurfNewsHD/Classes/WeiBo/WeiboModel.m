//
//  WeiboModel.m
//  SurfNewsHD
//
//  Created by SYZ on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "WeiboModel.h"

#define kTimeoutInterval 12

@implementation GetSinaWeiboUserFriendsRequest

- (id)initWithCursor:(NSInteger)cursor
{
    if (self = [super init]) {
        SurfDbManager *manager = [SurfDbManager sharedInstance];
        NSDictionary *dict = [manager getSinaWeiboInfoForUser:kDefaultID];
        if ([dict valueForKey:@"access_token"] && [dict valueForKey:@"uid"]) {
            _access_token = [dict valueForKey:@"access_token"];
            _uid = [[dict valueForKey:@"uid"] longLongValue];
        }
        _count = 50;        //赋值为50的原因参考新浪微博开发文档
        _trim_status = 1;   //赋值为1的原因参考新浪微博开发文档
        _cursor = cursor;
    }
    return self;
}

@end

@implementation SinaWeiboUserInfo

@synthesize uid = __KEY_NAME_id;

@end

@implementation GetSinaWeiboUserFriendsResponse

@synthesize users = __ELE_TYPE_SinaWeiboUserInfo;

@end

//-------------------------------以下为请求的生成类--------------------------------

@implementation WeiboRequestGenerator

+ (NSURLRequest*)getSinaWeiboUserFriendsRequestWithCursor:(NSInteger)cursor
{
    GetSinaWeiboUserFriendsRequest *req = [[GetSinaWeiboUserFriendsRequest alloc] initWithCursor:cursor];
    NSString *json = [EzJsonParser serializeObjectWithUtf8Encoding:req];
    NSDictionary *dict = [json objectFromJSONString];
    NSString *param = [dict stringWithFormEncodedComponents];
    NSString *url = [NSString stringWithFormat:@"%@?%@", kSinaWeiboFriendsURL, param];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = kTimeoutInterval;
    return request;
}

@end