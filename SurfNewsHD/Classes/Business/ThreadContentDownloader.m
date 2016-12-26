    //
//  ThreadContentDownloader.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-11.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ThreadContentDownloader.h"
#import "SurfRequestGenerator.h"
#import "GTMHTTPFetcher.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "NSObject+Extensions.h"
#import "NSString+Extensions.h"
#import "NotificationManager.h"
#import "MJExtension.h"


@implementation ThreadContentDownloader(private)

-(id) init
{
    self = [super init];
    if(self)
    {
        userDict_ = [NSMutableDictionary new];
    }
    return self;
}

@end


@implementation ThreadContentDownloader

+ (ThreadContentDownloader *)sharedInstance
{
    static ThreadContentDownloader *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ThreadContentDownloader alloc] init];
    });
    
    return sharedInstance;
}

- (void)download:(ThreadSummary*)thread
       isCollect:(BOOL)isCollect
withCompletionHandler:(void(^)(BOOL succeeded,NSString* content,ThreadSummary* thread))handler
{
    id key = [thread hashForDictionaryKey];
    
    //已经在下载中
    if([userDict_ objectForKey:key])
        return;
    
    //添加下载
    NSURLRequest* request = nil;
    if (ImageChannelThread == thread.threadM) {
        // 图片频道请求
        request=[SurfRequestGenerator photoCollectionContent:(PhotoCollection*)thread];
    }
    else{
        request =
        [SurfRequestGenerator getThreadContentRequest:thread
                                            isCollect:isCollect];
    }
    
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error)
     {
         [[NSURLCache sharedURLCache] removeAllCachedResponses];
         [[NSURLCache sharedURLCache] setDiskCapacity:0];
         [[NSURLCache sharedURLCache] setMemoryCapacity:0];
         [userDict_ removeObjectForKey:key];
         
         
         NSString* body = nil;
         if(!error)
         {
             body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
         }
         
         if (handler) {
             handler(!error,body,thread);
         }
     }];
    
    [userDict_ setObject:fetcher forKey:key];
}
-(void) cancelDownload:(ThreadSummary*)thread
{
    id key = [thread hashForDictionaryKey];
    GTMHTTPFetcher* fetcher = [userDict_ objectForKey:key];
    if(fetcher)
    {
        [fetcher stopFetching];
        [userDict_ removeObjectForKey:key];
    }
}


@end
