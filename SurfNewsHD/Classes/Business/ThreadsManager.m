//
//  ThreadsManager.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-15.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ThreadsManager.h"
#import "SurfRequestGenerator.h"
#import "HotChannelsListResponse.h"
#import "SubsChannelsListResponse.h"
#import "HotChannelsThreadsResponse.h"
#import "SubsChannelThreadsResponse.h"
#import "NSObject+Extensions.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "EzJsonParser.h"
#import "SurfDbManager.h"
#import "PathUtil.h"
#import "FileUtil.h"

#import "HotChannelsManager.h"
#import "SubsChannelsManager.h"
#import "SubsChannelModelRequest.h"
#import "SubsChannelModelResponse.h"
#import "ThreadDownloadTask.h"
#import "PhotoCollectionData.h"
#import "PhotoCollectionManager.h"
#import "ThreadSummary.h"

#import "NotificationManager.h"

typedef NS_ENUM(NSInteger, HTTPTaskType) {
    kHotChannelRefresh = 0,
    kHotChannelGetMore,
    kSubsChannelRefresh,
    kSubsChannelGetMore,
    kSubsChannelsLastNews,  //订阅频道的最新新闻
    kPcChannelRefresh,
};

////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ThreadsFetchingTask : NSObject{
    NSMutableArray *_subsTask;
}

@property(nonatomic,readonly) HTTPTaskType taskType;
@property(nonatomic,strong) HotChannel* hotChannel;     //valid if isHotChannel==YES
@property(nonatomic,strong) SubsChannel* subsChannel;   //valid if isHotChannel==NO
@property(nonatomic,strong)PhotoCollectionChannel *pcChannel;
@property(nonatomic,strong) GTMHTTPFetcher* httpFecther;
//@property(nonatomic,strong) void(^completionHandler)(ThreadsFetchingResult*);
@property(nonatomic,strong,readonly) id threadsResp;
@end

@implementation ThreadsFetchingTask

-(id)initWithRefreshHotChannel:(HotChannelDownloadTask*)task{
    if (self = [super init]) {
        _taskType = kHotChannelRefresh;
        _hotChannel = task.hotChannel;
        _subsTask = [NSMutableArray new];
        [_subsTask addObject:task];
    }
    return self;
}

-(id)initWithMoreHotChannel:(HotChannelDownloadTask*)task
{
    if (self = [super init]) {
        _taskType = kHotChannelGetMore;
        _hotChannel = task.hotChannel;
        _subsTask = [NSMutableArray new];
        [_subsTask addObject:task];
    }
    return self;
}
-(id)initWithRefreshPhotoCollectionChannel:(ImageGalleryDownLoadTask*)task{
    if (self = [super init]) {
        _taskType = kPcChannelRefresh;
        _pcChannel = task.pcc;
        _subsTask = [NSMutableArray new];
        [_subsTask addObject:task];
    }
    return self;
}

-(id)initWithRefreshSubChannel:(SubsChannelDownloadTask*)task{
    if (self = [super init]) {
        _taskType = kSubsChannelRefresh;
        _subsChannel = task.subsChannel;
        _subsTask = [NSMutableArray new];
        [_subsTask addObject:task];
    }
    return self;
}

-(id)initWithGetMoreSubChannel:(SubsChannelDownloadTask*)task{
    if (self = [super init]) {
        _taskType = kSubsChannelGetMore;
        _subsChannel = task.subsChannel;
        _subsTask = [NSMutableArray new];
        [_subsTask addObject:task];
    }
    return self;
}

-(id)initWithLastNewsForSubsChannels:(LastNewsForSubsChannelsTask*)task{
    if (self = [super init]) {
        _taskType = kSubsChannelsLastNews;
        _subsTask = [NSMutableArray new];
        [_subsTask addObject:task];
    }
    return self;
}

//刷新ImageGalleryChannel
-(void)httpImageGalleryChannelRequest:(void(^)(BOOL succeeded, ThreadsFetchingTask*))handler
//-(void)httpImageGalleryChannelRequest:(void(^)(BOOL succeeded, PhotoCollection*))handler
{
    ImageGalleryDownLoadTask* task = _subsTask[0];
    NSURLRequest *request = [task requestUrl];
    if (!request) {
        if (handler) {
            handler(NO, self);
        }
        return;
    }
    
    
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:request];
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error){
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        if (!error){
            NSStringEncoding encoding = [[[_httpFecther response] textEncodingName] convertToStringEncoding];
            NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
            
            Class classType = nil;
            if (_taskType == kHotChannelRefresh || _taskType == kHotChannelGetMore) {
                classType = [HotChannelsThreadsResponse class];
            }
            else if(_taskType == kSubsChannelGetMore || _taskType == kSubsChannelRefresh){
                classType = [SubsChannelThreadsResponse class];
            }
            else if(_taskType == kSubsChannelsLastNews){
                classType = [UpdateSubsChannelsLastNewsResponse class];
            }
            else if(_taskType == kPcChannelRefresh){
                classType=[ImageGalleryThreadsResponse class];
            }
            
            if (classType) {
                _threadsResp = [EzJsonParser deserializeFromJson:body AsType:classType];
            }
        }
        handler(!error,self);
    }];
}

// 刷新Hotchannel
-(void)httpRequest:(void(^)(BOOL succeeded, ThreadsFetchingTask*))handler
{
    HotChannelDownloadTask* task = _subsTask[0];
    NSURLRequest *request = [task requestUrl];
    if (!request) {
        if (handler) {
            handler(NO, self);
        }
        return;
    }
    
    
    _httpFecther = [GTMHTTPFetcher fetcherWithRequest:request];
    [_httpFecther beginFetchWithCompletionHandler:^(NSData *data, NSError *error){
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        if (!error){
            NSStringEncoding encoding = [[[_httpFecther response] textEncodingName] convertToStringEncoding];
            NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
            
            Class classType = nil;
            if (_taskType == kHotChannelRefresh || _taskType == kHotChannelGetMore) {
                classType = [HotChannelsThreadsResponse class];
            }
            else if(_taskType == kSubsChannelGetMore || _taskType == kSubsChannelRefresh){
                classType = [SubsChannelThreadsResponse class];
            }
            else if(_taskType == kSubsChannelsLastNews){
                classType = [UpdateSubsChannelsLastNewsResponse class];
            }
            else if(_taskType == kPcChannelRefresh){
                classType=[ImageGalleryThreadsResponse class];
            }
            
            if (classType) {
                _threadsResp = [EzJsonParser deserializeFromJson:body AsType:classType];
            }
        }
        handler(!error,self);
    }];
}


-(void)notifyRequestComplete:(BOOL)succeeded
                  addedCount:(NSInteger)count
                     threads:(NSArray*)threads
{
    ThreadsFetchingResult* result = [ThreadsFetchingResult new];
    [result setSucceeded:succeeded];
    [result setNoChanges:(count == 0 ? YES : NO)];
    result.addedThreadsCount = count;
    result.threads = threads;
    
    if (_taskType == kHotChannelRefresh || _taskType == kHotChannelGetMore)
        result.channelId = _hotChannel.channelId;
    else if(_taskType == kSubsChannelGetMore || _taskType == kSubsChannelRefresh)
        result.channelId = _subsChannel.channelId;
    else
        result.channelId = 0;
    
    
    for (NSInteger i=_subsTask.count-1; i>=0; --i) {
        SNThreadTaskBase* t = _subsTask[i];
        if (t.target && t.completionHandler) {
            t.completionHandler(result);
        }
        else{
            [_subsTask removeObject:t];
        }
    }
}


// 处理完成时间
-(void)notifyRequestComplete:(BOOL)succeeded
                   noChanges:(BOOL)noChanges
                     threads:(NSArray*)threads
{
    ThreadsFetchingResult* result = [ThreadsFetchingResult new];
    [result setSucceeded:succeeded];
    [result setNoChanges:noChanges];
    result.threads = threads;
    
    if (_taskType == kHotChannelRefresh || _taskType == kHotChannelGetMore)
        result.channelId = _hotChannel.channelId;
    else if(_taskType == kSubsChannelGetMore || _taskType == kSubsChannelRefresh)
        result.channelId = _subsChannel.channelId;
    else
        result.channelId = 0;
    
    
    for (NSInteger i=_subsTask.count-1; i>=0; --i) {
        SNThreadTaskBase* t = _subsTask[i];
        if (t.target && t.completionHandler) {
            t.completionHandler(result);
        }
        else{
            [_subsTask removeObject:t];
        }
    }
}

- (void)addSubsTask:(SNThreadTaskBase*)task{
    if (task.target && ![self isExistTarget:task.target]) {
        [_subsTask addObject:task];
    }
}

-(void)removeSubsTask:(id)target{
    if (target) {
        for (HotChannelDownloadTask* t in _subsTask) {
            if ([t.target isEqual:target]) {
                [_subsTask removeObject:t];
                break;
            }
        }
    }
}

-(BOOL)isExistTarget:(id)target{
    if (target) {
        for (HotChannelDownloadTask* t in _subsTask) {
            if ([t.target isEqual:target]) {
                return YES;
            }
        }
    }
    return NO;
}

-(NSUInteger)subsTaskCount{
    return _subsTask.count;
}
@end

@implementation ThreadsFetchingResult

+(ThreadsFetchingResult *)sharedInstance
{
    static ThreadsFetchingResult *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ThreadsFetchingResult alloc] init];
    });
    
    return sharedInstance;
}

@end

@implementation ThreadsManager(private)

-(id)init
{
    if(self = [super init])
    {
        hotChannelsRefreshDateDict_ = [NSMutableDictionary new];
        subsChannelsRefreshDateDict_ = [NSMutableDictionary new];
        hotChannelsGetMoreDateDict_ = [NSMutableDictionary new];
        subsChannelsGetMoreDateDict_ = [NSMutableDictionary new];
        hotChannelThreadsCache_ = [NSMutableDictionary new];
        subsChannelThreadsCache_ = [NSMutableDictionary new];
        fetchingTasks_ = [NSMutableArray new];
        //
        readThreadIdsCache_ = [NSMutableArray new];
        unreadThreadIdsCache_ = [NSMutableArray new];
        ratedThreadIdsCache_ = [NSMutableArray new];
        unratedThreadIdsCache_ = [NSMutableArray new];
        //
        threadReadChangedHandler = [NSMutableArray new];
        hotChannelsPageNumDict_ = [NSMutableDictionary new];
        subsChannelsPageNumDict_ = [NSMutableDictionary new];
        //
        lockedThreads_ = [NSMutableArray new];
#ifdef ipad
        getAboutHotChannelArr = [NSMutableArray new];
        NSString * path =[[NSBundle mainBundle] pathForResource:@"channelsHotInfo" ofType:@"txt"];
        NSArray *arr = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:path
                                                                                   encoding:NSUTF8StringEncoding error:nil]
                                                  AsType:[NSArray class]];
        
        
        for(NSDictionary *dict in arr)
        {
            SubsChannel *channel = [SubsChannel new];
            channel.cateId = [[dict objectForKey:@"cateId"] longLongValue];
            channel.hotChannelID = [[dict objectForKey:@"hotChannelID"] longLongValue];
            channel.channelId = [[dict objectForKey:@"id"] longLongValue];
            channel.imageUrl = [dict objectForKey:@"imageUrl"];
            channel.index = [dict objectForKey:@"index"];
            channel.isVisible = [dict objectForKey:@"isVisible"];
            channel.name = [dict objectForKey:@"name"];
            channel.ssCount = [[dict objectForKey:@"ssCount"] longLongValue];
            [getAboutHotChannelArr addObject:channel];
        }
#endif
    }
    return self;
}

//判断帖子是否精确存在
-(BOOL)isThreadExist:(ThreadSummary*)thread
             inArray:(NSArray*)threadsArray;
{
    for (ThreadSummary* t in threadsArray)
    {
        //判断isTop和isPicThread字段，使得某帖子的置顶、大图帖属性被编辑改动后
        //程序可以实时刷新
        if(t.threadId == thread.threadId && t.isTop == thread.isTop
           && t.time == thread.time
           && t.type == thread.type
           && [NSString isString:t.title logicallEqualsToString:thread.title]
           && [NSString isString:t.source logicallEqualsToString:thread.source]
           && [NSString isString:t.desc logicallEqualsToString:thread.desc]
           && [NSString isString:t.newsUrl logicallEqualsToString:thread.newsUrl]
           && [NSString isString:t.imgUrl logicallEqualsToString:thread.imgUrl]
           && [NSString isString:t.iconPath logicallEqualsToString:thread.iconPath]
           && [t.multiImgUrl count] == [thread.multiImgUrl count]
           && t.isPicThread == thread.isPicThread)
            return YES;
    }
    return NO;
}
//
-(BOOL)isPhotoCollectionExist:(PhotoCollection*)thread
             inArray:(NSArray*)threadsArray;
{
    for (PhotoCollection* t in threadsArray)
    {
        //判断isTop和isPicThread字段，使得某帖子的置顶、大图帖属性被编辑改动后
        //程序可以实时刷新
        if(t.pcId == thread.pcId && t.coid == thread.coid)
            return YES;
    }
    return NO;
}

// 判断帖子是否模糊存在
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

-(BOOL)isDuplicatedPhotoCollectionExist:(PhotoCollection*)thread
                       inArray:(NSArray*)threadsArray
{
    for (PhotoCollection* t in threadsArray)
    {
        if(t.pcId == thread.pcId
           || [t.title isEqualToString:thread.title])
            return YES;
    }
    return NO;
}

//-(ThreadsFetchingTask*)taskForFetcher:(GTMHTTPFetcher*)fetcher
//{
//    for (ThreadsFetchingTask* task in fetchingTasks_)
//    {
//        if(task.httpFecther == fetcher)
//            return task;
//    }
//    return nil;
//}

-(NSMutableArray*)getCachedThreadsForHotChannel:(long)channelId
{
    for (NSNumber* chnid in hotChannelThreadsCache_)
    {
        if([chnid isEqualToNumber:[NSNumber numberWithLong:channelId]])
            return [hotChannelThreadsCache_ objectForKey:chnid];
    }
    return nil;
}

-(NSMutableArray*)getCachedThreadsForSubsChannel:(long)channelId
{
    for (NSNumber* chnid in subsChannelThreadsCache_)
    {
        if([chnid isEqualToNumber:[NSNumber numberWithLong:channelId]])
            return [subsChannelThreadsCache_ objectForKey:chnid];
    }
    return nil;
}

-(NSMutableArray*)getCachedThreadsForImageGallerysChannel:(long)channelId
{
    for (NSNumber* chnid in imageGalleryThreadsCache_)
    {
        if([chnid isEqualToNumber:[NSNumber numberWithLong:channelId]])
            return [imageGalleryThreadsCache_ objectForKey:chnid];
    }
    return nil;
}
-(ThreadSummary*)getThread:(NSMutableArray*)threads withId:(long)tid
{
    for (ThreadSummary* t in threads) {
        if (t.threadId == tid) {
            return t;
        }
    }
    return nil;
}
-(void)sortThreads:(NSMutableArray*)threads
{
    return; // modefied by xuxg 2015.5.20.孙猛说我们不需要排序，顺序会和服务端不一致。
    [threads sortUsingComparator:^NSComparisonResult(id obj1,id obj2)
     {
         ThreadSummary* t1 = (ThreadSummary*)obj1;
         ThreadSummary* t2 = (ThreadSummary*)obj2;
         
         /*
          modified by yuleiming 2014年04月29日
          排序优先级：isPicThread > isTop > time
          
          2014.8.14 排序优先级更改 增加了rss新闻和T+订阅新闻：
          isPicThread > referer >isTop > time
          */
         if(t1.isPicThread && t2.isPicThread) {
             //同是图片帖，则根据picThreadOrder排序，数值越小，越靠前
             if(t1.picThreadOrder > t2.picThreadOrder) {
                 return NSOrderedDescending;
             } else if(t1.picThreadOrder < t2.picThreadOrder) {
                 return NSOrderedAscending;
             } else {
                 if(t1.isTop ^ t2.isTop) {
                     //比isTop
                     return t1.isTop > 0 ? NSOrderedAscending : NSOrderedDescending;
                 } else {
                     //比time
                     return t1.time < t2.time ? NSOrderedDescending : NSOrderedAscending;
                 }
             }
         } else if(!t1.isPicThread && !t2.isPicThread) {
             
             // 2014.8.14 add by xuxg
             // RSS新闻和T+订阅新闻需要排列在图片新闻之后，新闻之前
             if (t1.referer != nil &&  t2.referer != nil) {
                 return NSOrderedSame;
             }
             else {
                 if (t1.referer != nil) {
                     return NSOrderedAscending;
                 }
                 else if(t2.referer != nil){
                     return NSOrderedDescending;
                 }
             }
             
             
             
             //都不是图片帖
             if(t1.isTop ^ t2.isTop) {
                 //比isTop
                 return t1.isTop > 0 ? NSOrderedAscending : NSOrderedDescending;
             } else {
                 //比time
                 return t1.time < t2.time ? NSOrderedDescending : NSOrderedAscending;
             }
         } else {
             //其中一个是图片帖
             return t1.isPicThread ? NSOrderedAscending : NSOrderedDescending;
         }
         
     }];
}

-(ThreadSummary*)getFirstThreadWithPreviewImage:(NSArray*)threads
{
    for (ThreadSummary* thread in threads)
    {
        if(thread.imgUrl && ![thread.imgUrl isEmptyOrBlank])
            return thread;
    }
    return nil;
}

//删除帖子所属的所有数据
-(void)deleteRelatedDataOfThread:(ThreadSummary *)thread
                usingFileManager:(NSFileManager*)fm
{
    NSString* threadDir = [PathUtil pathOfThread:thread];
    [FileUtil deleteContentsOfDir:threadDir];
    [fm removeItemAtPath:threadDir error:nil];
}

-(void)deleteRelatedDataOfPhotoCollection:(PhotoCollection *)thread
                usingFileManager:(NSFileManager*)fm
{
    NSString* threadDir = [PathUtil pathOfPhotoCollection:thread];
    [FileUtil deleteContentsOfDir:threadDir];
    [fm removeItemAtPath:threadDir error:nil];
}


@end


@implementation ThreadsManager

+(ThreadsManager *)sharedInstance
{
    static ThreadsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ThreadsManager alloc] init];
    });
    
    return sharedInstance;
}

-(NSArray*)getLocalThreadsForImageGallery:(PhotoCollectionChannel*)pcc{
    NSMutableArray* cachedThreads = [self getCachedThreadsForImageGallerysChannel:pcc.cid];
    if(cachedThreads)
    {
        [self sortThreads:cachedThreads];
        return cachedThreads;
    }
    cachedThreads = [NSMutableArray new];
    //从文件载入
    NSArray* dirs = [FileUtil getSubdirNamesOfDir:[PathUtil pathOfPhotoCollectionChannel:pcc]];
    for (NSString* threadId in dirs)
    {
        NSString* threadInfoPath = [PathUtil pathOfPhotoCollectionInfoWithId:pcc.cid photoCollectionId:[threadId integerValue]];
        ThreadSummary* t = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:threadInfoPath encoding:NSUTF8StringEncoding error:nil] AsType:[ThreadSummary class]];
        
        if (!t || t.threadId == 0)
        {
            NSString* threadDir = [threadInfoPath stringByDeletingLastPathComponent];
            [FileUtil deleteDirAndContents:threadDir];
        }
        else
        {
            [cachedThreads addObject:t];
        }
    }
    [self sortThreads:cachedThreads];
    
    [imageGalleryThreadsCache_ setObject:cachedThreads forKey:[NSNumber numberWithLong:pcc.cid]];
    
    return cachedThreads;
    
}
-(ThreadSummary*)getThreadSummaryForCoid:(u_long)coid threadId:(u_long)cid
{
    NSMutableArray* cachedThreads = [self getCachedThreadsForHotChannel:coid];
    if (cachedThreads) {
        for (ThreadSummary *t in cachedThreads) {
            if (t.threadId == cid) {
                return t;
            }
        }
    }
    return nil;
}

-(NSArray*)getLocalThreadsForHotChannelId:(u_long)coid
{
    HotChannel *hc = nil;
    NSArray *channels = [[HotChannelsManager sharedInstance] visibleHotChannels];
    for (HotChannel* c in channels) {
        if (c.channelId == coid) {
            hc = c;
            break;
        }
    }
    
    if (hc != nil) {
        return [self getLocalThreadsForHotChannel:hc];
    }
    return nil;
}
-(NSArray*)getLocalThreadsForHotChannel:(HotChannel*)hotChannel
{
    NSMutableArray* cachedThreads = [self getCachedThreadsForHotChannel:hotChannel.channelId];
    if(cachedThreads)   
    {
        [self sortThreads:cachedThreads];
        return cachedThreads;
    }
    cachedThreads = [NSMutableArray new];
    
    //从文件载入
    NSArray* dirs = [FileUtil getSubdirNamesOfDir:[PathUtil pathOfHotChannel:hotChannel]];
    for (NSString* threadId in dirs)
    {
        NSString* threadInfoPath = [PathUtil pathOfThreadInfoWithThreadId:[threadId integerValue] inHotChannel:hotChannel];
        ThreadSummary* t = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:threadInfoPath encoding:NSUTF8StringEncoding error:nil] AsType:[ThreadSummary class]];
        
        //删除无效帖子数据
        //尽管代码中找不出为何会出这种状况，但实际使用中
        //还是会发现有这种现象。
        if (!t || t.threadId == 0 || ![t isSupportShowType])
        {
            NSString* threadDir = [threadInfoPath stringByDeletingLastPathComponent];
            [FileUtil deleteDirAndContents:threadDir];
        }
        else
        {
            [cachedThreads addObject:t];
        }
    }
    [self sortThreads:cachedThreads];
    
    [hotChannelThreadsCache_ setObject:cachedThreads forKey:[NSNumber numberWithLong:hotChannel.channelId]];
    
    return cachedThreads;
}
-(NSArray*)getLocalThreadsForSubsChannel:(SubsChannel*)subsChannel
{
    NSMutableArray* cachedThreads = [self getCachedThreadsForSubsChannel:subsChannel.channelId];
    if(cachedThreads)
    {
        [self sortThreads:cachedThreads];
        return cachedThreads;
    }
    cachedThreads = [NSMutableArray new];
    
    //从文件载入
    NSArray* dirs = [FileUtil getSubdirNamesOfDir:[PathUtil pathOfSubsChannel:subsChannel]];
    for (NSString* threadId in dirs)
    {
        NSString* threadInfoPath = [PathUtil pathOfThreadInfoWithThreadId:[threadId integerValue] inSubsChannel:subsChannel];
        ThreadSummary* t = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:threadInfoPath encoding:NSUTF8StringEncoding error:nil] AsType:[ThreadSummary class]];
        
        //删除无效帖子数据
        if(!t || t.threadId == 0)
        {
            NSString* threadDir = [threadInfoPath stringByDeletingLastPathComponent];
            [FileUtil deleteDirAndContents:threadDir];
        }
        else
        {
            [cachedThreads addObject:t];
        }
        
        if (t.source.length <=0) {
            t.source = subsChannel.name;
        }
    }
    [self sortThreads:cachedThreads];
    
    [subsChannelThreadsCache_ setObject:cachedThreads forKey:[NSNumber numberWithLong:subsChannel.channelId]];
    
    return cachedThreads;
}
-(NSArray *)getLocalThreadsForSubsChannelID:(long)channelId
{
    NSMutableArray* cachedThreads = [self getCachedThreadsForSubsChannel:channelId];
    if(cachedThreads)
    {
        [self sortThreads:cachedThreads];
        return cachedThreads;
    }
    cachedThreads = [NSMutableArray new];
    
    //从文件载入
    NSArray* dirs = [FileUtil getSubdirNamesOfDir:[PathUtil pathOfSubsChannelInfoWithChannelId:channelId]];
    for (NSString* threadId in dirs)
    {
        NSString* threadInfoPath = [PathUtil pathOfThreadInfoWithThreadId:[threadId integerValue] inChannelId:channelId];
        ThreadSummary* t = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:threadInfoPath encoding:NSUTF8StringEncoding error:nil] AsType:[ThreadSummary class]];
        
        //删除无效帖子数据
        if(!t || t.threadId == 0)
        {
            NSString* threadDir = [threadInfoPath stringByDeletingLastPathComponent];
            [FileUtil deleteDirAndContents:threadDir];
        }
        else
        {
            [cachedThreads addObject:t];
        }
        
        if (t.source.length <=0) {
            SubsChannel* sc = [[SubsChannelsManager sharedInstance] getChannelById:channelId];
            if (sc) {
                t.source = sc.name;
            }
        }
    }
    [self sortThreads:cachedThreads];
    
    [subsChannelThreadsCache_ setObject:cachedThreads forKey:[NSNumber numberWithLong:channelId]];
    
    return cachedThreads;
}


// 清除新闻频道的缓存帖子
-(void)clearCachedThreadsForHotChannel:(HotChannel*)hotChannel
{
    NSNumber *key = [NSNumber numberWithLong:hotChannel.channelId];    
    [hotChannelThreadsCache_ removeObjectForKey:key];
    [hotChannelsRefreshDateDict_ removeObjectForKey:key];// 删除刷新时间
}

#pragma mark Hot
-(void)refreshHotChannel:(id)target
              hotChannel:(HotChannel*)hotChannel
   withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler
{
    if (!target || !hotChannel ||!handler) {
        return;
    }
    
    hotChannel.refresh = YES;
    HotChannelDownloadTask* t = [HotChannelDownloadTask new];
    t.target = target;
    t.pageNumber = 1;
    t.hotChannel = hotChannel;
    t.completionHandler = handler;
    
    [self refreshHotChannel:t];     // 请求数据
}

-(void)refreshHotChannel:(HotChannelDownloadTask*)task
{
    if (!task) {
        return;
    }
    
    task.pageNumber = 1;
    HotChannel *hotChannel = task.hotChannel;
    [self getLocalThreadsForHotChannel:hotChannel];//确保本地缓存已经被载入
    ThreadsFetchingTask* internalTask = [self findHotChannelTask:hotChannel taskType:kHotChannelRefresh];
    if (!internalTask) {
        internalTask = [[ThreadsFetchingTask alloc] initWithRefreshHotChannel:task];
        [internalTask httpRequest:^(BOOL succeeded, ThreadsFetchingTask *tempTask) {
            HotChannel *hotChannel = tempTask.hotChannel;
            hotChannel.refresh = NO;
            if (succeeded) { 
                long cid = hotChannel.channelId;
                
                //更新该热推频道的当前帖子页码
                [hotChannelsPageNumDict_ setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithLong:cid]];
                
                //更新刷新时间
                hotChannel.updateTime = @([[NSDate date] timeIntervalSince1970]);
                [[EzJsonParser serializeObjectWithUtf8Encoding:hotChannel] writeToFile:[PathUtil pathOfHotChannelInfo:hotChannel] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                HotChannelsThreadsResponse *threadsResp = tempTask.threadsResp;
                //将普通帖子列表和图片帖子列表合并
                NSMutableArray* univeralThreads = [NSMutableArray new];
                [univeralThreads addObjectsFromArray:threadsResp.news];
                if (threadsResp.picNews){
                    for (ThreadSummary* t in threadsResp.picNews) {
                        t.isPicThread = YES;
                    }
                    [univeralThreads addObjectsFromArray:threadsResp.picNews];
                }
                
                // 删除失效的本地缓存帖子
                NSFileManager* fm = [NSFileManager defaultManager];
                NSMutableArray* localThreads = [self getCachedThreadsForHotChannel:hotChannel.channelId];
                for (NSInteger i = 0; i < [localThreads count]; i++)
                {
                    ThreadSummary* localThread = [localThreads objectAtIndex:i];
                    if (![self isThreadExist:localThread inArray:univeralThreads])
                    {
                        //被锁定资源的帖子数据不予删除
                        if([self isThreadResourceLocked:localThread])
                            continue;
                        [self deleteRelatedDataOfThread:localThread usingFileManager:fm];
                        [localThreads removeObject:localThread];
                        i--;
                    }
                }
                
                
                // 过滤掉不认识的帖子类型
                for(NSInteger i = [univeralThreads count]-1; i >=0; --i){
                    ThreadSummary* ts = univeralThreads[i];
                    if(![ts isSupportShowType] && !ts.isPicThread){
                        [univeralThreads removeObject:ts];
                    }
                }
                
                
                // 计算新增新闻数
                NSInteger addedCount = 0;
                for (ThreadSummary *ts in univeralThreads) {
                    // 判断是否是新增新闻
                    if (![self isDuplicatedThreadExist:ts inArray:localThreads]) {
                        ++addedCount;
                    }
                }
                
                // 删除本地缓存，因编辑同志会随意修改帖子内容
                for (NSInteger i = [localThreads count] - 1; i >= 0; --i) {
                    ThreadSummary *ts = [localThreads objectAtIndex:i];
                    if ([self isThreadResourceLocked:ts]) {
                        continue;
                    }
                    [localThreads removeObject:ts];
                }
                
                //创建帖子缓存
                for(ThreadSummary* thread in univeralThreads)
                {
                    // 判断帖子是否模糊存在
                    if ([self isDuplicatedThreadExist:thread inArray:localThreads]) {
                        continue;
                    }
                
                    
                    [localThreads addObject:thread];
                    
                    //**重要**
                    thread.channelId = hotChannel.channelId;
                    if(hotChannel.type)
                        thread.channelType = hotChannel.type;
                    thread.threadM=HotChannelThread;
                    
                    //存到本地
                    [fm createDirectoryAtPath:[PathUtil pathOfThread:thread] withIntermediateDirectories:YES attributes:nil error:nil];
                    [[EzJsonParser serializeObjectWithUtf8Encoding:thread] writeToFile:[PathUtil pathOfThreadInfo:thread] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                }
                
                //added by yuleiming 2014年04月29日
                //将localThreads中的图片帖的picThreadOrder重新赋值
                //顺序以刚刷下来的picNews数组中的元素顺序为准
                NSInteger picThreadIdx = 0;
                for (ThreadSummary* t in threadsResp.picNews) {
                    
                    //找到该thread
                    ThreadSummary* localT = [self getThread:localThreads withId:t.threadId];
                    
                    //如果该thread的picThreadOrder不符合要求，则修改并写到文件
                    if(localT.picThreadOrder != picThreadIdx) {
                        localT.picThreadOrder = picThreadIdx;
                        [[EzJsonParser serializeObjectWithUtf8Encoding:localT] writeToFile:[PathUtil pathOfThreadInfo:localT] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    }
                    picThreadIdx++;
                }
                
                [self sortThreads:localThreads]; // 本地帖子重新排序
                
                //刷新成功
                [tempTask notifyRequestComplete:YES addedCount:addedCount threads:localThreads];
            }
            else{
                [tempTask notifyRequestComplete:NO noChanges:NO threads:nil];
            }
            [fetchingTasks_ removeObject:tempTask];
        }];
        
        [fetchingTasks_ addObject:internalTask];
        [hotChannelsRefreshDateDict_ setObject:[NSDate date] forKey:[NSNumber numberWithLong:hotChannel.channelId]];
    }
    else{
        [internalTask addSubsTask:task];
    }
}
-(ThreadsFetchingTask*)findImageGalleryTask:(PhotoCollectionChannel*)pcChannel taskType:(HTTPTaskType)type{
    for (ThreadsFetchingTask* task in fetchingTasks_) {
        if (task.taskType == type && task.pcChannel.cid == pcChannel.cid) {
            return task;
        }
    }
    return nil;
}

-(ThreadsFetchingTask*)findHotChannelTask:(HotChannel*)hotChannel taskType:(HTTPTaskType)type{
    for (ThreadsFetchingTask* task in fetchingTasks_) {
        if (task.taskType == type && task.hotChannel.channelId == hotChannel.channelId) {
            return task;
        }
    }
    return nil;
}
-(ThreadsFetchingTask*)findSubsChannelTask:(SubsChannel*)subsChannel taskType:(HTTPTaskType)type{
    for (ThreadsFetchingTask* task in fetchingTasks_) {
        if (task.taskType == type && task.subsChannel.channelId == subsChannel.channelId) {
            return task;
        }
    }
    return nil;
}
-(ThreadsFetchingTask*)findSubsChennelLastNewsTask{
    for (ThreadsFetchingTask* task in fetchingTasks_) {
        if (task.taskType == kSubsChannelsLastNews)
            return task;
    }
    return nil;
}

-(void)refreshSubsChannel:(id)target subsChannel:(SubsChannel*)subsChannel
    withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler
{
    if (!target || !subsChannel || !handler) {
        return;
    }
    SubsChannelDownloadTask* subsTask = [SubsChannelDownloadTask new];
    subsTask.target = target;
    subsTask.pageNumber = 1;
    subsTask.subsChannel = subsChannel;
    subsTask.completionHandler = handler;
    [self refreshSubsChannel:subsTask];
}

-(void)refreshSubsChannel:(SubsChannelDownloadTask*)task
{
    if (!task || !task.subsChannel) {
        return;
    }
    
    //确保本地缓存已经被载入
    SubsChannel *subsChannel = task.subsChannel;
    [self getLocalThreadsForSubsChannel:subsChannel];
    ThreadsFetchingTask *internalTask = [self findSubsChannelTask:subsChannel taskType:kSubsChannelRefresh];
    if (!internalTask) {
        
        internalTask = [[ThreadsFetchingTask alloc] initWithRefreshSubChannel:task];
        [internalTask httpRequest:^(BOOL succeeded, ThreadsFetchingTask *tempTask) {
            if (succeeded)
            {
                SubsChannel* subsChannel = tempTask.subsChannel;
                SubsChannelThreadsResponse *threadsResp = tempTask.threadsResp;
                if(!threadsResp.item || [threadsResp.item count] == 0)
                {
                    //无有效帖子
                    [tempTask notifyRequestComplete:YES noChanges:YES threads:nil];
                }
                else
                {
                    NSFileManager *fm = [NSFileManager defaultManager];
                    
                    //更新该频道的当前帖子页码
                    [subsChannelsPageNumDict_ setObject:[NSNumber numberWithInt:1] forKey:[NSNumber numberWithLong:subsChannel.channelId]];
                    
                    NSMutableArray* threadsActuallyAdded = [NSMutableArray new];
                    
                    //删除失效的本地缓存帖子
                    NSMutableArray* localThreads = [self getCachedThreadsForSubsChannel:subsChannel.channelId];
                    for (NSInteger i = 0; i < [localThreads count]; i++)
                    {
                        ThreadSummary* localThread = localThreads[i];
                        if (![self isThreadExist:localThread inArray:threadsResp.item])
                        {
                            //被锁定资源的帖子不予删除
                            if([self isThreadResourceLocked:localThread])
                                continue;
                            [self deleteRelatedDataOfThread:localThread usingFileManager:fm];
                            [localThreads removeObject:localThread];
                            i--;
                        }
                    }
                    
                    //更新刷新时间
                    NSDate *date = [NSDate date];
                    subsChannel.time = [date timeIntervalSince1970];
                    
                    
                    
//                    2015.11.18 订阅频道没有showType概念，只能我们自己修改了
                    for(NSInteger i = [threadsResp.item count]-1; i >=0; --i){
                        ThreadSummary* ts = threadsResp.item[i];
                        ts.showType = TSShowType_Image_None;
                        if(ts.imgUrl && ![ts.imgUrl isEmptyOrBlank]){
                            ts.showType = TSShowType_Image_Only;
                        }
                    }
                    
                    
                    // 找到帖子中最大的更新时间，保存到订阅频道中，在刷新中心使用（by xuxg add ）
                    BOOL isSave = NO;
                    for(ThreadSummary* thread in threadsResp.item) {
                        if (subsChannel.threadsSummaryMaxTime < thread.time) {
                            isSave = YES;
                            subsChannel.threadsSummaryMaxTime = thread.time;
                        }
                    }
                    if (isSave) {
                        [[EzJsonParser serializeObjectWithUtf8Encoding:subsChannel] writeToFile:[PathUtil pathOfSubsChannelInfo:subsChannel] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    }
                    
                    
                    //创建帖子缓存
                    for(ThreadSummary* thread in threadsResp.item)
                    {
                        if ([self isDuplicatedThreadExist:thread inArray:localThreads])
                            continue;
                        
                        [threadsActuallyAdded addObject:thread];
                        [localThreads addObject:thread];
                        
                        //**重要**
                        thread.channelId = subsChannel.channelId;
                        thread.threadM = SubChannelThread;
                        
                        //保存文件
                        [fm createDirectoryAtPath:[PathUtil pathOfThread:thread] withIntermediateDirectories:YES attributes:nil error:nil];
                        [[EzJsonParser serializeObjectWithUtf8Encoding:thread] writeToFile:[PathUtil pathOfThreadInfo:thread] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    }
                    
                    
                    // 刷新成功
                    BOOL noChanges = NO;
                    if ([threadsActuallyAdded count] == 0) {
                        noChanges = YES;
                    }
                    else{
                        [self sortThreads:localThreads];
                    }
                    [tempTask notifyRequestComplete:YES noChanges:noChanges threads:localThreads];
                }
            }
            else
            {
                //刷新失败
                [tempTask notifyRequestComplete:NO noChanges:YES threads:nil];
            }
            
            [fetchingTasks_ removeObject:tempTask];
            
        }];
        
        [fetchingTasks_ addObject:internalTask];
        [subsChannelsRefreshDateDict_ setObject:[NSDate date] forKey:[NSNumber numberWithLong:subsChannel.channelId]];
    }
    else{
        [internalTask addSubsTask:task];
    }
}


-(void)cancelRefreshHotChannel:(id)target hotChannel:(HotChannel*)hotChannel
{
    if (!target || !hotChannel) {
        return;
    }
    
    ThreadsFetchingTask* task = [self findHotChannelTask:hotChannel taskType:kHotChannelRefresh];
    if(task)
    {
        [task removeSubsTask:target];
        hotChannel.refresh = NO;
        if (task.subsTaskCount == 0) {
            [task.httpFecther stopFetching];
            [fetchingTasks_ removeObject:task];
        }
    }
}

-(void)cancelPhotoCollectionChannel:(id)target pcChannel:(PhotoCollectionChannel*)pcChannel
{
    if (!target || !pcChannel) {
        return;
    }
    
    ThreadsFetchingTask* task = [self findImageGalleryTask:pcChannel taskType:kHotChannelRefresh];
    if(task)
    {
        [task removeSubsTask:target];
//        pcChannel.refresh = NO;
        if (task.subsTaskCount == 0) {
            [task.httpFecther stopFetching];
            [fetchingTasks_ removeObject:task];
        }
    }
}

-(void)cancelRefreshSubsChannel:(id)target subsChannel:(SubsChannel*)subsChannel
{
    if (!target || !subsChannel) {
        return;
    }
    
    ThreadsFetchingTask* task = [self findSubsChannelTask:subsChannel taskType:kSubsChannelRefresh];
    if(task)
    {
        [task removeSubsTask:target];
        if (task.subsTaskCount == 0) {
            [task.httpFecther stopFetching];
            [fetchingTasks_ removeObject:task];
        }
    }
}

-(void)getMoreForHotChannel:(id)target hotChannel:(HotChannel*)hotChannel
      withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler
{
    if (!target || !hotChannel || !handler) {
        return;
    }
    
    HotChannelDownloadTask* task = [HotChannelDownloadTask new];
    task.target = target;
    task.hotChannel = hotChannel;
    task.completionHandler = handler;
    [self getMoreForHotChannel:task];
}

-(void)getMoreForHotChannel:(HotChannelDownloadTask*)task
{
    if (!task.hotChannel) {
        return;
    }
    
    HotChannel *hotChannel = task.hotChannel;
    ThreadsFetchingTask* internalTask = [self findHotChannelTask:hotChannel taskType:kHotChannelGetMore];
    if (internalTask == nil) {
        
        NSNumber* curPageNo = [hotChannelsPageNumDict_ objectForKey:[NSNumber numberWithLong:hotChannel.channelId]];
        if(!curPageNo){
            curPageNo = [NSNumber numberWithInt:1]; //从未刷新成功过，认为此次加载更多操作是从第2页开始加载
            [hotChannelsPageNumDict_ setObject:curPageNo forKey:[NSNumber numberWithLong:hotChannel.channelId]];
        }
        task.pageNumber = [curPageNo intValue] + 1;
        
        
        
        internalTask = [[ThreadsFetchingTask alloc] initWithMoreHotChannel:task];
        [internalTask httpRequest:^(BOOL succeeded, ThreadsFetchingTask *tempTask)
         {
             HotChannel* hotChannel = tempTask.hotChannel;
             if (succeeded) {
                 HotChannelsThreadsResponse *threadsResp = tempTask.threadsResp;
                 if(!threadsResp.news || threadsResp.news.count == 0){
                     [tempTask notifyRequestComplete:YES noChanges:YES threads:nil];//无有效的帖子
                 }
                 else {
                     //更新该热推频道的当前帖子页码
                     NSNumber* curPageNo = [hotChannelsPageNumDict_ objectForKey:[NSNumber numberWithLong:hotChannel.channelId]];
                     [hotChannelsPageNumDict_ setObject:[NSNumber numberWithInt:[curPageNo intValue] + 1] forKey:[NSNumber numberWithLong:hotChannel.channelId]];
                     
                     NSMutableArray* threadsActuallyAdded = [NSMutableArray new];
                     NSMutableArray* threadsCache = [self getCachedThreadsForHotChannel:hotChannel.channelId];
                     
                     // 存储帖子缓存
                     for(ThreadSummary* thread in threadsResp.news){
                         // 假如帖子模糊存在，则跳过
                         if ([self isDuplicatedThreadExist:thread inArray:threadsCache])
                             continue;
                         // 不支持的类型
                         if (![thread isSupportShowType]) {
                             continue;
                         }
                         
                         [threadsActuallyAdded addObject:thread];
                         [threadsCache addObject:thread];
                         
                         //**重要**
                         thread.channelId = hotChannel.channelId;
                         if(hotChannel.type)
                             thread.channelType = hotChannel.type;
                         thread.threadM=HotChannelThread;
                         
                         //保存到文件
                         NSFileManager *fm = [NSFileManager defaultManager];
                         [fm createDirectoryAtPath:[PathUtil pathOfThread:thread] withIntermediateDirectories:YES attributes:nil error:nil];
                     }
                     
                     // 通知请求完成
                     [tempTask notifyRequestComplete:YES
                                           noChanges:threadsActuallyAdded.count ? NO : YES
                                             threads:threadsActuallyAdded];
                     
                 }
             }
             else
             {
                 // 通知请求完成
                 [tempTask notifyRequestComplete:NO noChanges:YES threads:nil];
             }
             
             [fetchingTasks_ removeObject:tempTask];
         }];
        
        [fetchingTasks_ addObject:internalTask];
        [hotChannelsGetMoreDateDict_ setObject:[NSDate date] forKey:[NSNumber numberWithLong:hotChannel.channelId]];
    }
    else{
        [internalTask addSubsTask:task];
    }
}

-(void)getMoreForSubsChannel:(id)target subsChannel:(SubsChannel*)subsChannel
       withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler{
    if (!target || !subsChannel || !handler) {
        if (handler) {
            ThreadsFetchingResult *result = [ThreadsFetchingResult new];
            result.succeeded = NO;
            result.noChanges = YES;
            result.threads = nil;
            handler(result);
        }
        return;
    }
    
    SubsChannelDownloadTask* task = [SubsChannelDownloadTask new];
    task.target = target;
    task.subsChannel = subsChannel;
    task.completionHandler = handler;
    [self getMoreForSubsChannel:task];
}

-(void)getMoreForSubsChannel:(SubsChannelDownloadTask*)task
{
    if (!task || !task.subsChannel) {
        return;
    }
    
    SubsChannel *subsChannel = task.subsChannel;
    ThreadsFetchingTask* internalTask = [self findSubsChannelTask:subsChannel taskType:kSubsChannelGetMore];
    if (!internalTask) {
        
        NSNumber* curPageNo = [subsChannelsPageNumDict_ objectForKey:[NSNumber numberWithLong:subsChannel.channelId]];
        if(!curPageNo){
            curPageNo = [NSNumber numberWithInt:1]; //从未刷新成功过，认为此次加载更多操作是从第2页开始加载
            [subsChannelsPageNumDict_ setObject:curPageNo forKey:[NSNumber numberWithLong:subsChannel.channelId]];
        }
        task.pageNumber = [curPageNo intValue] + 1;
        
        
        internalTask = [[ThreadsFetchingTask alloc] initWithGetMoreSubChannel:task];
        [internalTask httpRequest:^(BOOL succeeded, ThreadsFetchingTask *tempTask) {
            if (succeeded)
            {
                SubsChannel* subsChannel = tempTask.subsChannel;
                SubsChannelThreadsResponse* threadsResp = tempTask.threadsResp;
                if(!threadsResp.item || [threadsResp.item count] == 0)
                {
                    //无有效帖子
                    [tempTask notifyRequestComplete:YES noChanges:YES threads:nil];
                }
                else
                {
                    //更新该热推频道的当前帖子页码
                    NSNumber* curPageNo = [subsChannelsPageNumDict_ objectForKey:[NSNumber numberWithLong:subsChannel.channelId]];
                    [subsChannelsPageNumDict_ setObject:[NSNumber numberWithInt:[curPageNo intValue] + 1] forKey:[NSNumber numberWithLong:subsChannel.channelId]];
                    
                    NSMutableArray* threadsActuallyAdded = [NSMutableArray new];
                    NSMutableArray* threadsCache = [self getCachedThreadsForSubsChannel:subsChannel.channelId];
                    
                    
                    // 2015.11.18 订阅频道没有showType概念，只能我们自己修改了
                    for(NSInteger i = [threadsResp.item count]-1; i >=0; --i){
                        ThreadSummary* ts = threadsResp.item[i];
                        ts.showType = TSShowType_Image_None;
                        if(ts.imgUrl && ![ts.imgUrl isEmptyOrBlank]){
                            ts.showType = TSShowType_Image_Only;
                        }
                    }
                    
                    
                    
                    //存储帖子缓存
                    for(ThreadSummary* thread in threadsResp.item)
                    {
                        //假如帖子模糊存在，则跳过
                        if ([self isDuplicatedThreadExist:thread inArray:threadsCache])
                            continue;
                        
                        if (thread.source.length <=0) {
                            thread.source = subsChannel.name;
                        }
                        
                        [threadsActuallyAdded addObject:thread];
                        [threadsCache addObject:thread];
                        
                        //**重要**
                        thread.channelId = subsChannel.channelId;
                        thread.threadM = SubChannelThread;
                        
                        //保存到文件
                        NSFileManager *fm = [NSFileManager defaultManager];
                        [fm createDirectoryAtPath:[PathUtil pathOfThread:thread] withIntermediateDirectories:YES attributes:nil error:nil];
                        /*
                         [[EzJsonParser serializeObjectWithUtf8Encoding:thread] writeToFile:[PathUtil pathOfThreadInfo:thread] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                         */
                    }
                    
                    [tempTask notifyRequestComplete:YES
                                          noChanges:threadsActuallyAdded.count==0?YES:NO
                                            threads:threadsActuallyAdded];
                }
            }
            else
            {
                //网络异常
                [tempTask notifyRequestComplete:NO noChanges:YES threads:nil];
            }
            
            [fetchingTasks_ removeObject:tempTask];
        }];
        
        
        [fetchingTasks_ addObject:internalTask];
        [subsChannelsGetMoreDateDict_ setObject:[NSDate date] forKey:[NSNumber numberWithLong:subsChannel.channelId]];
    }
    else{
        [internalTask addSubsTask:task];
    }
}


-(void)cancelGetMoreForHotChannel:(id)target hotChannel:(HotChannel*)hotChannel
{
    ThreadsFetchingTask* task = [self findHotChannelTask:hotChannel taskType:kHotChannelGetMore];
    if (task) {
        [task removeSubsTask:target];
        
        if ([task subsTaskCount] == 0) {
            [task.httpFecther stopFetching];
            [fetchingTasks_ removeObject:task];
        }
    }
}

// 取消更新订阅频道新闻
-(void)cancelUpdateSubsChannelsNews:(id)target{
    
    ThreadsFetchingTask* task = [self findSubsChennelLastNewsTask];
    if (task) {
        [task removeSubsTask:target];
        if ([task subsTaskCount] == 0) {
            [task.httpFecther stopFetching];
            [fetchingTasks_ removeObject:task];
        }
    }
}

-(NSDate*)lastRefreshDateOfHotChannel:(HotChannel*)hotChannel
{
    NSDate *date = [hotChannelsRefreshDateDict_ objectForKey:[NSNumber numberWithLong:hotChannel.channelId]];
    if (date == nil && [hotChannel updateTime].doubleValue > 0.f) {
        date = [NSDate dateWithTimeIntervalSince1970:[hotChannel updateTime].doubleValue];
    }
    return date;
}
-(NSDate*)lastRefreshDateOfSubsChannel:(SubsChannel*)subsChannel
{
    NSDate *date = [subsChannelsRefreshDateDict_ objectForKey:[NSNumber numberWithLong:subsChannel.channelId]];
    if (date == nil && [subsChannel time] > 0.f) {
        date = [NSDate dateWithTimeIntervalSince1970:[subsChannel time]];
    }
    return date;
}
-(NSDate*)lastGetMoreDateOfHotChannel:(HotChannel*)hotChannel
{
    return [hotChannelsGetMoreDateDict_ objectForKey:[NSNumber numberWithLong:hotChannel.channelId]];
}
-(NSDate*)lastGetMoreDateOfSubsChannel:(SubsChannel*)subsChannel
{
    return [subsChannelsGetMoreDateDict_ objectForKey:[NSNumber numberWithLong:subsChannel.channelId]];
}
-(NSDate*)LastUpdateSubsChannelNews{
    return updateSubschennelLastNewsDate_;
}
-(BOOL)isHotChannelInRefreshing:(id)target hotChannel:(HotChannel*)hotChannel
{
    for (ThreadsFetchingTask* task in fetchingTasks_) {
        if (task.taskType == kHotChannelRefresh && task.hotChannel.channelId == hotChannel.channelId) {
            if ([task isExistTarget:target]) {
                return YES;
            }
        }
    }
    return NO;
}
-(BOOL)isSubsChannelInRefreshing:(SubsChannel*)subsChannel
{
    for (ThreadsFetchingTask* task in fetchingTasks_){
        if(task.taskType == kSubsChannelRefresh &&
           task.subsChannel.channelId == subsChannel.channelId){
            return YES;
        }
    }
    return NO;
}
-(BOOL)isHotChannelInGettingMore:(id)target hotChannel:(HotChannel*)hotChannel
{
    for (ThreadsFetchingTask* task in fetchingTasks_) {
        if (task.taskType == kHotChannelGetMore &&
            task.hotChannel.channelId == hotChannel.channelId) {
            if ([task isExistTarget:target]) {
                return YES;
            }
        }
    }
    return NO;
}
-(BOOL)isSubsChannelInGettingMore:(SubsChannel*)subsChannel
{
    for (ThreadsFetchingTask* task in fetchingTasks_){
        if(task.taskType == kSubsChannelGetMore && task.subsChannel.channelId == subsChannel.channelId){
            return YES;
        }
    }
    return NO;
}

//是否更新订阅频道新闻
-(BOOL)isUpdateSubsChannelsLastNews{
    for (ThreadsFetchingTask* task in fetchingTasks_){
        if(task.taskType == kSubsChannelsLastNews){
            return YES;
        }
    }
    return NO;
}

-(void)markThreadAsRead:(ThreadSummary*)thread
{
    id threadId = [NSNumber numberWithLong:thread.threadId];
    
    //已经在已读id缓存中，直接返回
    // modify by xuxg (thread.threadId == 0)
    // 从活动广场那里跳转过来的id==0，不能对数据库操作
    if(thread.threadId == 0 ||
       [readThreadIdsCache_ containsObject:threadId])
        return;
    
    //从未读id缓存中清除
    [unreadThreadIdsCache_ removeObject:threadId];
    
    //修改数据库
    [[SurfDbManager sharedInstance] addReadingHistory:thread];
    
    //添加到已读id缓存
    [readThreadIdsCache_ addObject:threadId];
    
    //分发通知
    for (ThreadReadChangedHandler handler in threadReadChangedHandler)
    {
        handler(thread,YES);
    }
}

-(BOOL)isThreadRead:(ThreadSummary*)thread
{
    id threadId = [NSNumber numberWithLong:thread.threadId];
    if([readThreadIdsCache_ containsObject:threadId])
        return YES;
    if([unreadThreadIdsCache_ containsObject:threadId])
        return NO;
    
    //不在缓存中，则从数据库实时查询
    BOOL read = [[SurfDbManager sharedInstance] isThreadRead:thread];
    if(read)
    {
        [readThreadIdsCache_ addObject:threadId];
    }
    else
    {
        [unreadThreadIdsCache_ addObject:threadId];
    }
    return read;
}

-(void)markThreadAsRated:(ThreadSummary*)thread
{
    id threadId = [NSNumber numberWithLong:thread.threadId];
    
    //已经在已赞id缓存中，直接返回
    if([ratedThreadIdsCache_ containsObject:threadId])
        return;
    
    //从未赞id缓存中清除
    [unratedThreadIdsCache_ removeObject:threadId];
    
    //修改数据库
    [[SurfDbManager sharedInstance] addRatingHistory:thread];
    
    //添加到已赞id缓存
    [ratedThreadIdsCache_ addObject:threadId];
}

-(BOOL)isThreadRated:(ThreadSummary *)thread
{
    id threadId = [NSNumber numberWithLong:thread.threadId];
    if([ratedThreadIdsCache_ containsObject:threadId])
        return YES;
    if([unratedThreadIdsCache_ containsObject:threadId])
        return NO;
    
    //不在缓存中，则从数据库实时查询
    BOOL rated = [[SurfDbManager sharedInstance] isThreadRated:thread];
    if(rated)
    {
        [ratedThreadIdsCache_ addObject:threadId];
    }
    else
    {
        [unratedThreadIdsCache_ addObject:threadId];
    }
    return rated;
}

#pragma mark - 段子赞、踩状态 存取

// 标记段子某个帖子为已赞
- (void)markJokeThreadAsUpedOrDowned:(ThreadSummary *)thread {
    // 存储到数据库
    [[SurfDbManager sharedInstance] addUpedOrDownedHistory:thread];
}

// 查询段子某个帖子 赞或踩
- (int)isJokeThreadUpedOrDowned:(ThreadSummary *)thread {
    return [[SurfDbManager sharedInstance] isThreadUpedOrDowned:thread];
}

#pragma mark -----

-(void)lockThreadResource:(ThreadSummary *)thread
{
    if(thread && ![lockedThreads_ containsObject:thread])
        [lockedThreads_ addObject:thread];
}

-(void)unlockThreadResource:(ThreadSummary *)thread
{
    if(thread)
        [lockedThreads_ removeObject:thread];
}

-(BOOL)isThreadResourceLocked:(ThreadSummary *)thread
{
    return [lockedThreads_ containsObject:thread];
}

-(void)setLastReadThread:(ThreadSummary*)thread
{
    lastReadThread_ = thread;
}

-(ThreadSummary*)getLastReadThread
{
    return lastReadThread_;
}

-(void)registerThreadReadChangedHandler:(ThreadReadChangedHandler)handler
{
    if([threadReadChangedHandler containsObject:handler])
        return;
    [threadReadChangedHandler addObject:handler];
}

-(void)unregisterThreadReadChangedHandler:(ThreadReadChangedHandler)handler
{
    [threadReadChangedHandler removeObject:handler];
}

-(void)deleteThreadsAndDataOfHotChannel:(HotChannel*)hotChannel
{
    NSString* channelDir = [PathUtil pathOfHotChannel:hotChannel];
    [FileUtil deleteContentsOfDir:channelDir];
}

-(void)deleteThreadsAndDataOfSubsChannel:(SubsChannel *)subsChannel
{
    NSString* channelDir = [PathUtil pathOfSubsChannel:subsChannel];
    [FileUtil deleteContentsOfDir:channelDir];
}
#ifdef ipad
#pragma mark - 获取相关热门资讯
-(SubsChannel *)getAboutHotChannel:(HotChannel*)hotChannel
{
    for(SubsChannel *channel in getAboutHotChannelArr)
    {
        if (channel.hotChannelID  == hotChannel.channelId) {
            return channel;
            break;
        }
    }
    return [getAboutHotChannelArr objectAtIndex:0];
}
-(HotChannel*)getAboutSubsChannel:(SubsChannel*)subsChannel
{
    HotChannelsManager *hm = [HotChannelsManager sharedInstance];
    if ([hm.visibleHotChannels count]<=0) {
        return nil;
    }
    return [hm.visibleHotChannels objectAtIndex:0];
}
#endif


// 添加频道的详情(by xuxg)
-(void)addThreadSummaries:(SubsChannel*)sc threadSummaries:(NSArray*)sums{
    if (sc == nil && [sums count] > 0) {
        return;
    }
    
    NSMutableArray *summaries = [NSMutableArray arrayWithArray:sums];
    NSMutableArray *mArray = (NSMutableArray*)[self getLocalThreadsForSubsChannel:sc];
    
    // 过滤掉相同ID的帖子
    if ([mArray count]>0) {
        for (NSInteger i = [summaries count]-1; i >= 0; --i) {
            id threadSummary = [summaries objectAtIndex:i];
            if ([threadSummary isKindOfClass:[ThreadSummary class]]) {
                long threadID = ((ThreadSummary*)threadSummary).threadId;
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"threadId == %ld",threadID];
                NSArray *array = [mArray filteredArrayUsingPredicate:predicate];
                
                if ([array count] > 0) {
                    [summaries removeObject:threadSummary];
                }
            }
        }
    }
    
    
    // 添加新频道内容
    if ([summaries count] > 0) {
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [summaries count])];
        [mArray insertObjects:summaries atIndexes:set];
        [self sortThreads:mArray]; // 对内容排序
        // 改变刷新时间，暂时关闭。
        //        [subsChannelsRefreshDateDict_ setObject:[NSDate date] forKey:[NSNumber numberWithLong:sc.channelId]];
    }
}

// 更新订阅频道的最新新闻列表
// 注：暂用于iphone需求
- (void)updateSubsChannelsLastNews:(id)target
                      subsChannels:(NSArray*)subschannels
                        completion:(void(^)(ThreadsFetchingResult*))handler{
    
    if (!target || subschannels.count == 0) {
        if (handler){
            ThreadsFetchingResult *result = [ThreadsFetchingResult new];
            result.succeeded = NO;
            result.noChanges = YES;
            result.threads = nil;
            handler(result);
        }
        return;
    }
    
    
    
    // 没有订阅频道就返回，基本是没有可能
    if (subschannels.count == 0) {
        if (handler){
            ThreadsFetchingResult *result = [ThreadsFetchingResult new];
            result.succeeded = NO;
            result.noChanges = YES;
            result.threads = nil;
            handler(result);
        }
        return;
    }
    
    
    LastNewsForSubsChannelsTask*task = [[LastNewsForSubsChannelsTask alloc] initWithSubsChannels:subschannels];
    task.target = target;
    task.completionHandler = handler;
    
    
    
    ThreadsFetchingTask *internalTask = [self findSubsChennelLastNewsTask];
    if (!internalTask) {
        
        internalTask = [[ThreadsFetchingTask alloc] initWithLastNewsForSubsChannels:task];
        [internalTask httpRequest:^(BOOL succeeded, ThreadsFetchingTask *blockTask)
         {
             if (succeeded && blockTask.threadsResp) {
                 NSFileManager *fm = [NSFileManager defaultManager];
                 UpdateSubsChannelsLastNewsResponse *newsResponse = blockTask.threadsResp;
                 NSUInteger itemCount = newsResponse.item.count;
                 NSMutableArray* threadsActuallyAdded = [NSMutableArray new];
                 
                 if (itemCount > 0) {
                     // 过滤没有更新的订阅频道新闻
                     NSMutableArray *subsArray = [NSMutableArray arrayWithCapacity:itemCount];
                     for (NSInteger i = 0; i < itemCount; ++i) {
                         UpdateSubsChannelInfo *info = [newsResponse.item objectAtIndex:i];
                         if (info.hasN == 1 && info.news.count > 0) {
                             [subsArray addObject:info];
                         }
                     }
                     
                     SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
                     
                     // 更新下来的数据进行本地保存
                     for (NSInteger i = 0; i < subsArray.count; ++i) {
                         UpdateSubsChannelInfo *info = [subsArray objectAtIndex:i];
                         if (info.news.count > 0) {
                             // 通过订阅频道id找到订阅频道,并修改它的帖子中最大的发布时间
                             SubsChannel *subsCha = [scm getChannelById:info.cid];
                             if (subsCha) {
                                 BOOL isChanged = NO;
                                 for(ThreadSummary* thread in info.news){
                                     if (subsCha.threadsSummaryMaxTime < thread.time) {
                                         isChanged = YES;
                                         subsCha.threadsSummaryMaxTime = thread.time;
                                     }
                                     
                                     // 有些帖子没有来源，没有来源就给频道的名称
                                     if (thread.source.length <=0) {
                                         thread.source = subsCha.name;
                                     }
                                 }
                                 
                                 // 保存更新的时间
                                 if (isChanged) {
                                     [[EzJsonParser serializeObjectWithUtf8Encoding:subsCha] writeToFile:[PathUtil pathOfSubsChannelInfo:subsCha] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                                 }
                             }
                             
                             
                             //创建帖子缓存
                             NSMutableArray* localThreads = [self getCachedThreadsForSubsChannel:info.cid];
                             if (localThreads == nil) {
                                 // 确保本地缓存存在
                                 [self getLocalThreadsForSubsChannelID:info.cid];
                                 localThreads = [self getCachedThreadsForSubsChannel:info.cid];
                             }
                             
                             for(ThreadSummary* thread in info.news)
                             {
                                 if (![thread isKindOfClass:[ThreadSummary class]])
                                     continue;
                                 // 缓存存在，就不在保存了
                                 if ([self isDuplicatedThreadExist:thread inArray:localThreads])
                                     continue;
                                 
                                 [threadsActuallyAdded addObject:thread];
                                 [localThreads addObject:thread];// 加入到本地缓存中
                                 
                                 //**重要**
                                 thread.channelId = info.cid;
                                 thread.threadM=SubChannelThread;
                                 
                                 //保存文件
                                 [fm createDirectoryAtPath:[PathUtil pathOfThread:thread] withIntermediateDirectories:YES attributes:nil error:nil];
                                 [[EzJsonParser serializeObjectWithUtf8Encoding:thread] writeToFile:[PathUtil pathOfThreadInfo:thread] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                             }
                         }
                     }
                 }
                 
                 
                 [blockTask notifyRequestComplete:YES
                                        noChanges:threadsActuallyAdded.count==0?YES:NO
                                          threads:threadsActuallyAdded];
                 
             }
             else{
                 [blockTask notifyRequestComplete:NO noChanges:YES threads:nil];
             }
             [fetchingTasks_ removeObject:blockTask];
         }];
        
        [fetchingTasks_ addObject:internalTask];
        updateSubschennelLastNewsDate_ = [NSDate date];
    }
    else{
        [internalTask addSubsTask:task];
    }
    
}


//清除缓存
- (void)cleanAllCaches
{
    //热推
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfHotChannels]]) {
        NSString *path = [[PathUtil rootPathOfHotChannels] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            [FileUtil deleteContentsOfDir:subPath without:@"info.txt"];
        }
    }
    //订阅
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfSubsChannels]]) {
        NSString *path = [[PathUtil rootPathOfSubsChannels] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            [FileUtil deleteContentsOfDir:subPath without:@"info.txt"];
        }
    }
    //期刊
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfMagazines]]) {
        NSString *path = [[PathUtil rootPathOfMagazines] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            [FileUtil deleteContentsOfDir:subPath without:@"info.txt"];
        }
    }
    //最新
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfNewest]]) {
        NSString *path = [[PathUtil rootPathOfNewest] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            [FileUtil deleteContentsOfDir:subPath without:@"info.txt"];
        }
    }
    //图集
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfPhotoCollection]]) {
        NSString *path = [[PathUtil rootPathOfPhotoCollection] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            [FileUtil deleteContentsOfDir:subPath without:@"info.txt"];
        }
    }
    
    //推送目录
    [[NotificationManager sharedInstance] clearRootPathOfNotiFidir];
}

-(void)asynCleanAllCachesWithCompletionHandler:(void(^)(BOOL))handler
{
    if(handler) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^(void) {
            [self cleanAllCaches];
            dispatch_sync(dispatch_get_main_queue(), ^(void) {
                handler(YES);
            });
        });
    } else {
        [self cleanAllCaches];
    }
}

//计算缓存大小
-(double)calculateCachesSize
{
    __block double cachesSize = 0;
    
    //热推
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfHotChannels]]) {
        NSString *path = [[PathUtil rootPathOfHotChannels] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            cachesSize += [FileUtil calcContentsSizeOfDir:subPath without:@"info.txt"];
        }
    }
    //订阅
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfSubsChannels]]) {
        NSString *path = [[PathUtil rootPathOfSubsChannels] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            cachesSize += [FileUtil calcContentsSizeOfDir:subPath without:@"info.txt"];
        }
    }
    //期刊
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfMagazines]]) {
        NSString *path = [[PathUtil rootPathOfMagazines] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            cachesSize += [FileUtil calcContentsSizeOfDir:subPath without:@"info.txt"];
        }
    }
    //最新
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfNewest]]) {
        NSString *path = [[PathUtil rootPathOfNewest] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            cachesSize += [FileUtil calcContentsSizeOfDir:subPath without:@"info.txt"];
        }
    }
    //图集
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfPhotoCollection]]) {
        NSString *path = [[PathUtil rootPathOfPhotoCollection] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            cachesSize += [FileUtil calcContentsSizeOfDir:subPath without:@"info.txt"];
        }
    }
    //推送
    for (NSString *dirName in [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfNotiFidir]]) {
        NSString *path = [[PathUtil rootPathOfNotiFidir] stringByAppendingPathComponent:dirName];
        for (NSString *subDirName in [FileUtil getSubdirNamesOfDir:path]) {
            NSString *subPath = [path stringByAppendingPathComponent:subDirName];
            cachesSize += [FileUtil calcContentsSizeOfDir:subPath without:@"info.txt"];
        }
    }
    
    return cachesSize;
}

@end
