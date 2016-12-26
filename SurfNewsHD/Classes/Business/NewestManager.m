//
//  NewestManager.m
//  SurfNewsHD
//
//  Created by apple on 13-3-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "NewestManager.h"
#import "FileUtil.h"
#import "PathUtil.h"
#import "SubsChannelsListResponse.h"
#import "EzJsonParser.h"
#import "GTMHTTPFetcher.h"
#import "SubsChannelsManager.h"
#import "NSString+Extensions.h"
#import "SubsChannelThreadsResponse.h"
#import "AppSettings.h"
#import "ThreadsManager.h"

@implementation NewestManagerResult
@end
@implementation NewestManager

#define kThreadId @"threadId"
#define kChannelId @"channelId"


+(NewestManager*)sharedInstance
{
    static NewestManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NewestManager alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        currentPage = 1;
        networkState = NewestNetworkStateNone;
        isNewestChannel = YES;
        threadsDirNames_ = [NSMutableArray new];
    }
    return self;
}

-(NSArray*)loadLocalNewestChannels
{
    if (threadsDirNames_) return threadsDirNames_;
    threadsDirNames_ = [NSMutableArray new];

    SubsChannelsManager *subsMgr = [SubsChannelsManager sharedInstance];
    NSArray *tempArray = [subsMgr loadLocalSubsChannels];
    if ([tempArray count]<=0) {
        return nil;
    }
    if ([tempArray count]== 1 ) {
        if (isNewestChannel) {
            isNewestChannel = NO;
            SubsChannel *subsCnl = [tempArray objectAtIndex:0];
            NSArray *subs = [[ThreadsManager sharedInstance] getLocalThreadsForSubsChannel:subsCnl];
            [threadsDirNames_ addObjectsFromArray:subs];
            return threadsDirNames_; // 后加代码
        }else
        {
            return threadsDirNames_;
        }
    }
    isNewestChannel = NO;

    NSMutableArray *loadLocalArr;    
    NSString *jsonString = [NSString stringWithContentsOfFile:[PathUtil listPathOfNewestList]
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    loadLocalArr = [jsonString objectFromJSONString];    
    for (NSDictionary* threadDict in loadLocalArr)
    {
        long threadId = [[threadDict objectForKey:kThreadId] integerValue];
        long channelId = [[threadDict objectForKey:kChannelId] integerValue];
        NSString* threadInfoPath = [PathUtil pathOfThreadInfoWithThreadId:threadId
                                                              inChannelId:channelId];
        if (![FileUtil fileExists:threadInfoPath]) {
            continue;
        }
        ThreadSummary* t = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:threadInfoPath encoding:NSUTF8StringEncoding error:nil] AsType:[ThreadSummary class]];
        if ([self isDuplicatedThreadExist:t inArray:threadsDirNames_])
            continue;
        [threadsDirNames_ addObject:t];
    }
    
    return threadsDirNames_;
}

// 最后更新时间
-(NSDate*)lastUpdateTime{
    SubsChannelsManager *subsMgr = [SubsChannelsManager sharedInstance];
    NSArray *tempArray = [subsMgr loadLocalSubsChannels];
    if ([tempArray count]<=0) {
        return nil;
    }
    if ([tempArray count] == 1) {
        SubsChannel *subsCnl = [tempArray objectAtIndex:0];
        return [[ThreadsManager sharedInstance] lastRefreshDateOfSubsChannel:subsCnl];// 后加代码
    }
    
    
    return [AppSettings dateForKey:DateKey_NewestNews];
}

// 设置更新时间
-(void)setUpdateTime{    
    [AppSettings setDate:[NSDate date] forkey:DateKey_NewestNews];
}

-(void)refreshNewestCompletionHandler:(void(^)(NewestManagerResult*))handler
{
    // 后加代码
    SubsChannelsManager *subsMgr = [SubsChannelsManager sharedInstance];
    NSArray *tempArray = [subsMgr loadLocalSubsChannels];
    if ([tempArray count]<=0) {
        NewestManagerResult* result = [NewestManagerResult new];
        result.succeeded = NO;
        result.threads = nil;
        handler(result);
        completionHandler = nil;
        return;
    }
    if ([tempArray count] == 1) {
        completionHandler = handler;
        SubsChannel *subsCnl = [tempArray objectAtIndex:0];
        if ([[ThreadsManager sharedInstance] isSubsChannelInRefreshing:subsCnl] ||
            [[ThreadsManager sharedInstance] isSubsChannelInGettingMore:subsCnl] )
        {
            NewestManagerResult* result = [NewestManagerResult new];
            result.succeeded = NO;
            result.threads = nil;
            completionHandler(result);
            completionHandler = nil;
        }
        else
        {
            [[ThreadsManager sharedInstance] refreshSubsChannel:self subsChannel:subsCnl withCompletionHandler:^(ThreadsFetchingResult *result) {
                NewestManagerResult* nmResult = [NewestManagerResult new];
                nmResult.succeeded = [result succeeded];
                if ([result succeeded]) {
                    isNewestChannel = NO;
                    nmResult.threads = [result threads];
                    [threadsDirNames_ removeAllObjects];
                    [threadsDirNames_ addObjectsFromArray:[result threads]];
                }
                completionHandler(nmResult);
                completionHandler = nil;
            }];
        }
        
        return ; // 后加代码
    }

    
    
    
    if (networkState != NewestNetworkStateNone) {
        NewestManagerResult* result = [NewestManagerResult new];
        result.succeeded = NO;
        result.threads = nil;
        handler(result);
        return;
    }
    completionHandler = handler;
    networkState = NewestNetworkStateRefresh;
    if (currentPage == 0) {
        currentPage = 1;
    }
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    
    NSArray*arr =  [manager loadLocalSubsChannels];
    NSMutableString *scids = [NSMutableString string];
    for (SubsChannel *channel in arr) {
        [scids appendFormat:@"%ld,",channel.channelId];
    }
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:[SurfRequestGenerator getSubsChannelNewsRequestScids:scids with:1]];
    [myFetcher beginFetchWithDelegate:self
                    didFinishSelector:@selector(myFetcher:finishedWithData:error:)];
  
}
-(void)getMoreForNewestCompletionHandler:(void(^)(NewestManagerResult*))handler
{
    // 后加代码
    SubsChannelsManager *subsMgr = [SubsChannelsManager sharedInstance];
    NSArray *tempArray = [subsMgr loadLocalSubsChannels];
    if ([tempArray count] <=0 ) {
        NewestManagerResult* result = [NewestManagerResult new];
        result.succeeded = NO;
        result.threads = nil;
        handler(result);
        completionHandler = nil;
        return;
    }
    else if ([tempArray count] == 1) {
        SubsChannel *subsCnl = [tempArray objectAtIndex:0];
        if ([[ThreadsManager sharedInstance] isSubsChannelInRefreshing:subsCnl] ||
            [[ThreadsManager sharedInstance] isSubsChannelInGettingMore:subsCnl] ) {
            NewestManagerResult* result = [NewestManagerResult new];
            result.succeeded = NO;
            result.threads = nil;
            completionHandler(result);
            completionHandler = nil;
        }
        else
        {
            completionHandler = handler;
            [[ThreadsManager sharedInstance] getMoreForSubsChannel:self
                                                       subsChannel:subsCnl
                                             withCompletionHandler:^(ThreadsFetchingResult *result) {
                NewestManagerResult* nmResult = [NewestManagerResult new];
                nmResult.succeeded = [result succeeded];
                if ([result succeeded] && ![result noChanges]) {
                    nmResult.threads = [result threads];
                    //                [threadsDirNames_ removeAllObjects];
                    //                [threadsDirNames_ addObjectsFromArray:[result threads]];
                }
                completionHandler(nmResult);
                completionHandler = nil;
            }];
        }
        
        return ; // 后加代码
    }
    
    
    
    if (networkState != NewestNetworkStateNone) {
        NewestManagerResult* result = [NewestManagerResult new];
        result.succeeded = NO;
        result.threads = nil;
        handler(result);
        return;
    }
    completionHandler = handler;
    networkState = NewestNetworkStateMore;
    
    SubsChannelsManager *manager = [SubsChannelsManager sharedInstance];
    
    NSArray*arr =  [manager loadLocalSubsChannels];
    NSMutableString *scids = [NSMutableString string];
    for (SubsChannel *channel in arr) {
        [scids appendFormat:@"%ld,",channel.channelId];
    }
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:[SurfRequestGenerator getSubsChannelNewsRequestScids:scids with:currentPage+1]];
    [myFetcher beginFetchWithDelegate:self
                    didFinishSelector:@selector(myFetcher:finishedWithData:error:)];
}
- (void)myFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error
{
    if (error != nil) {
        NewestManagerResult* result = [NewestManagerResult new];
        result.succeeded = NO;
        result.threads = nil;
        completionHandler(result);
        completionHandler = nil;
    } else {
        isNewestChannel = YES;
        NSFileManager* fm = [NSFileManager defaultManager];
        NSString* body = [[NSString alloc] initWithData:retrievedData encoding:
                          [[[fetcher response] textEncodingName] convertToStringEncoding]];
        
        SubsChannelThreadsResponse* threadsResp = [EzJsonParser deserializeFromJson:body
                                                                             AsType:[SubsChannelThreadsResponse class]];

        if(!threadsResp.item || [threadsResp.item count] == 0)
        {
            //无有效帖子
            NewestManagerResult* result = [NewestManagerResult new];
            result.succeeded = NO;
            result.threads = nil;
            completionHandler(result);
            completionHandler = nil;
        }
        else
        {

            NSMutableArray *loadLocalArr = [NSMutableArray new];
            for(ThreadSummary *thread in threadsResp.item)
            {
                NSMutableDictionary *dict = [NSMutableDictionary new];
                [dict setObject:[NSString stringWithFormat:@"%ld",thread.channelId]
                         forKey:kChannelId];
                [dict setObject:[NSString stringWithFormat:@"%@",@(thread.threadId)]
                         forKey:kThreadId];
             
                if ([self isDuplicatedThreadExist:thread inArray:threadsDirNames_])
                    continue;
                [loadLocalArr addObject:dict];
                NSString *path = [PathUtil pathOfThread:thread];
                [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
                [[EzJsonParser serializeObjectWithUtf8Encoding:thread] writeToFile:[PathUtil pathOfThreadInfo:thread] atomically:YES encoding:NSUTF8StringEncoding error:nil];

            }

            if ([loadLocalArr count]>0) {
                [[loadLocalArr JSONString] writeToFile:[PathUtil listPathOfNewestList]
                                            atomically:YES
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
            }
            if (networkState == NewestNetworkStateRefresh) {
                [threadsDirNames_ removeAllObjects];
                currentPage = 1;

            }else if (networkState == NewestNetworkStateMore)
            {
                currentPage ++;
            }
            networkState = NewestNetworkStateNone;

            [threadsDirNames_ addObjectsFromArray:threadsResp.item];
            
            [self setUpdateTime]; // 修改更新时间
            NewestManagerResult* result = [NewestManagerResult new];
            result.succeeded = YES;

            result.threads = threadsResp.item;
            completionHandler(result);
            completionHandler = nil;
        }        
    }
}
//判断帖子是否模糊存在
-(BOOL)isDuplicatedThreadExist:(ThreadSummary*)thread
                       inArray:(NSArray*)threadsArray
{
    for (ThreadSummary* t in threadsArray)
    {
        if(t.threadId == thread.threadId
           || [t.title isEqualToString:thread.title])
            return YES;
    }
    return NO;
}

@end
