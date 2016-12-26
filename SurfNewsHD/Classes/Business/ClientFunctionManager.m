//
//  ClientFunctionManager.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-11-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ClientFunctionManager.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "ClientFunctionResponse.h"
#import "EzJsonParser.h"
#import "AppSettings.h"
#import "SurfRequestGenerator.h"
#import "Encrypt.h"


#import "HtmlUtil.h"

typedef enum
{
    kWebContentRecommend = 1001, // 正文的相关推荐功能

}ClientFunctionType;


@implementation ClientFunctionManager
+ (ClientFunctionManager*)sharedInstance
{
    static ClientFunctionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [ClientFunctionManager new];
    });
    return sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        _funcInfoList = [NSMutableArray arrayWithCapacity:5];            
    }
    return self;
}
// 刷新一下客户端需要开启的功能
-(void)refreshClientFunction
{
    id req = [SurfRequestGenerator webContentRecommendIsOpen];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         if(!error)
         {
             NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
             DJLog(@"相关推荐开启内容 = %@",body);
             ClientFunctionResponse *res =  [EzJsonParser deserializeFromJson:body
                                                                       AsType:[ClientFunctionResponse class]];

             if (res && res.item) {
                 [_funcInfoList removeAllObjects];
                 [_funcInfoList addObjectsFromArray:res.item];
                 
                 // 把相关推荐的开启工程记录到本地数据中
                 [AppSettings setBool:[self isOpenWebContentRecommend] forKey:BooLKeyOpenRecommend];
             }
             if (res && res.mobile) {
                 [AppSettings setString:[Encrypt decryptUseDES:res.mobile] forKey:StringIMSIPhone];
             }
         }
         else{
             // 请求失败，就从上次记录的状态加载
             if ([AppSettings boolForKey:BooLKeyOpenRecommend]) {
                 ClientFunctionInfo* info = [ClientFunctionInfo new];
                 info.fId = kWebContentRecommend;
                 info.isOpen = YES;
                 [_funcInfoList addObject:info];
             }
             [AppSettings setString:nil forKey:StringIMSIPhone];
         }
     }];
    
}


// 是否开启网页正文相关推荐
- (BOOL)isOpenWebContentRecommend
{
    for (ClientFunctionInfo *info in _funcInfoList) {
        if ([info isKindOfClass:[ClientFunctionInfo class]]) {
            if (info.fId == kWebContentRecommend && info.isOpen) {
                return YES;
            }
        }
    }
    return NO;
}
@end
