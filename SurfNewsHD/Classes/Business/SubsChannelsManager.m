//
//  SubsChannelsManager.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubsChannelsManager.h"
#import "SubsChannelsListResponse.h"
#import "PathUtil.h" 
#import "FileUtil.h"
#import "EzJsonParser.h"
#import "SurfRequestGenerator.h"
#import "GetSubsCateResponse.h"
#import "SubsChannelsListResponse.h"
#import "NSString+Extensions.h"
#import "AppSettings.h"
#import "MagazineManager.h"
#import "SubsChannelModelRequest.h"
#import "ThreadsManager.h"
#import "SubsChannelModelResponse.h"

@implementation SubsChannelsSortInfo
@end

@implementation SubsChannelsCommitTaskInfo
#ifdef ipad
#define kVisibleSubsMax 7
#else
#define kVisibleSubsMax 80
#endif
-(id)init
{
    if(self = [super init])
    {
        self.toSubs = [NSMutableArray new];
        self.toUnsubs = [NSMutableArray new];
        self.toMagazineSubs = [NSMutableArray new];
        self.toMagazineUnsubs = [NSMutableArray new];
    }
    return self;
}

-(BOOL) isEmpty
{
    return [self.toSubs count] == 0 && [self.toUnsubs count] == 0 &&
    [self.toMagazineSubs count] == 0 && [self.toMagazineUnsubs count] == 0;
}

@end


@implementation SubsChannelsManager
@synthesize invisibleSubsChannels;
@synthesize visibleSubsChannels;
@synthesize wapVisibleSubsChannels;

+(SubsChannelsManager*)sharedInstance
{
    static SubsChannelsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SubsChannelsManager alloc] init];
    });
    
    return sharedInstance;
}
-(id)init
{
    if(self = [super init])
    {
        observers_ = [NSMutableArray new];
        visibleSubsChannels = [NSMutableArray new];
        inShowSubsChannels = [NSMutableArray new];
        invisibleSubsChannels = [NSMutableArray new];
        wapVisibleSubsChannels = [NSMutableArray new];
        subsChannels_ = [NSMutableArray new];
        backupVisibleSubsChannels = [NSMutableArray new];
        
        isCommitChannels = NO;
        UserManager *um = [UserManager sharedInstance];
        [um addUserLoginObserver:self];
        [self loadSortInfoChannls];
    }
    return self;
}
-(BOOL)userSubsInfoUpSucesss
{
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    if (userInfo) {
        return YES;
    }else{
        return NO;
    }
}

//加载栏目订阅
-(void)loadSortInfoChannls
{
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    SubsChannelsSortInfo* sortInfo;
    if (userInfo)
    {
        sortInfo = userInfo.subsChannelsSortInfo;
    }
    else
    {
        //游客用户展示
        sortInfo = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfSubsChannelSortInfo]
                                                                                                     encoding:NSUTF8StringEncoding error:nil]
                                                                    AsType:[SubsChannelsSortInfo class]];
    }
    [visibleSubsChannels removeAllObjects];
    [invisibleSubsChannels removeAllObjects];
    [wapVisibleSubsChannels removeAllObjects];
    [subsChannels_ removeAllObjects];
    [backupVisibleSubsChannels removeAllObjects];
    
    //有排序信息
    NSMutableArray *arrCoids = [NSMutableArray new];
    
    for (NSNumber* cid in sortInfo.visibleIdsArray)
    {
        SubsChannel* channel = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfSubsChannelInfoWithChannelId:[cid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[SubsChannel class]];
        if (channel == nil) {
            continue;
        }
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld",channel.channelId]])
        {
            continue;
        }
        [arrCoids addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
        
        [visibleSubsChannels addObject:channel];
    }
    [backupVisibleSubsChannels addObjectsFromArray:visibleSubsChannels];
    
    for (NSNumber* cid in sortInfo.invisibleIdsArray)
    {
        SubsChannel* channel = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfSubsChannelInfoWithChannelId:[cid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[SubsChannel class]];
        if (channel == nil) {
            continue;
        }
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld",channel.channelId]])
        {
            continue;
        }
        [arrCoids addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
        
        [invisibleSubsChannels addObject:channel];
    }
    for (NSNumber* cid in sortInfo.wapVisibleSubsChannels)
    {
        SubsChannel* channel = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfSubsChannelInfoWithChannelId:[cid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[SubsChannel class]];
        if (channel == nil) {
            continue;
        }
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld",channel.channelId]])
        {
            continue;
        }
        [arrCoids addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
        
        [wapVisibleSubsChannels addObject:channel];
    }
    [subsChannels_ addObjectsFromArray:visibleSubsChannels];
    [subsChannels_ addObjectsFromArray:invisibleSubsChannels];
    
    arrCoids = nil;
    
    if (subsChannels_.count == 0) {
        [AppSettings setBool:YES forKey:BoolKeyShowSubsPrompt];
    }
}

-(void)notifyChannelAdded:(SubsChannel*)channel
{
    if ([visibleSubsChannels count]< kVisibleSubsMax)
    {
        [visibleSubsChannels addObject:channel];
        [backupVisibleSubsChannels addObject:channel];
    }
    else
    {
        [invisibleSubsChannels addObject:channel];
    }
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.img",channel.channelId]];
    UIImage *logo = [UIImage imageWithContentsOfFile:path];
    NSData *imageData =  UIImagePNGRepresentation(logo);
    [imageData writeToFile:[PathUtil pathOfSubsChannelLogo:channel] atomically:YES];
}

-(void)notifyChannelAddedToFirst:(SubsChannel*)channel
{
    if ([visibleSubsChannels count]< kVisibleSubsMax)
    {
        [visibleSubsChannels insertObject:channel atIndex:0];
        [backupVisibleSubsChannels insertObject:channel atIndex:0];
    }
    else
    {
        [invisibleSubsChannels addObject:channel];
    }
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.img",channel.channelId]];
    UIImage *logo = [UIImage imageWithContentsOfFile:path];
    NSData *imageData =  UIImagePNGRepresentation(logo);
    [imageData writeToFile:[PathUtil pathOfSubsChannelLogo:channel] atomically:YES];
}

-(void)notifyChannelRemoved:(SubsChannel*)channel
{
    if ([visibleSubsChannels containsObject:channel])
    {
        [visibleSubsChannels removeObject:channel];
        [backupVisibleSubsChannels removeObject:channel];
    }
    else
    {
        [invisibleSubsChannels removeObject:channel];
    }
}

//载入本地订阅关系
-(NSMutableArray*)loadLocalSubsChannels
{
    return subsChannels_;
}

// 取消订阅分类列表
-(void)cancelCategoriesLoad{
    if (categoriesFetcher) {
        [categoriesFetcher stopFetching];
        categoriesFetcher = nil;
    }
}

-(void)loadCategoriesWithCompletionHandler:(void(^)(NSArray* cates))handler
{
    if(catesCache_)
    {
        //分类缓存存在，则直接返回
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^(void)
                       {
                           handler(catesCache_);
                       });
    }
    else
    {
        //从网络获取
        id req = [SurfRequestGenerator getSubsCateRequest];
        [self cancelCategoriesLoad]; // 取消加载状态
        categoriesFetcher = [GTMHTTPFetcher fetcherWithRequest:req];
        [categoriesFetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* err)
         {
             [[NSURLCache sharedURLCache] removeAllCachedResponses];
             [[NSURLCache sharedURLCache] setDiskCapacity:0];
             [[NSURLCache sharedURLCache] setMemoryCapacity:0];
             if(!err)
             {
                 NSString* body = [[NSString alloc] initWithData:data encoding:[[[categoriesFetcher response] textEncodingName] convertToStringEncoding]];
                 GetSubsCateResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[GetSubsCateResponse class]];
                 if(resp && resp.item && [resp.item count] > 0)
                 {
                     ////有有效数据
                     
                     //改写各cateitem的imageUrl成完整形式
                     for (CategoryItem* cate in resp.item)
                     {
                         NSURL* url = [NSURL URLWithString:cate.imageUrl relativeToURL:[NSURL URLWithString:resp.apicPass]];
                         cate.imageUrl = [url absoluteString];
                     }
                     
                     catesCache_ = [NSMutableArray new];
                     [catesCache_ addObjectsFromArray:resp.item];
                     handler(catesCache_);
                 }
                 else
                 {
                     handler(nil);
                 }
             }
             else
             {
                 //网络出错
                 handler(nil);
             }
             categoriesFetcher = nil;
         }];
    }
}

-(void)refreshCategoriesWithCompletionHandler:(void(^)(NSArray* cates))handler
{
    //从网络获取
    id req = [SurfRequestGenerator getSubsCateRequest];
    [self cancelCategoriesLoad]; // 取消加载状态
    categoriesFetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [categoriesFetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* err)
     {
         [[NSURLCache sharedURLCache] removeAllCachedResponses];
         [[NSURLCache sharedURLCache] setDiskCapacity:0];
         [[NSURLCache sharedURLCache] setMemoryCapacity:0];
         if(!err) {
             NSString* body = [[NSString alloc] initWithData:data encoding:[[[categoriesFetcher response] textEncodingName] convertToStringEncoding]];
             GetSubsCateResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[GetSubsCateResponse class]];
             if(resp && resp.item && [resp.item count] > 0) {
                 //改写各cateitem的imageUrl成完整形式
                 for (CategoryItem* cate in resp.item) {
                     NSURL* url = [NSURL URLWithString:cate.imageUrl relativeToURL:[NSURL URLWithString:resp.apicPass]];
                     cate.imageUrl = [url absoluteString];
                 }
                 
                 if (catesCache_ == nil) {
                     catesCache_ = [NSMutableArray new];
                 }
                 [catesCache_ removeAllObjects];                
                 [catesCache_ addObjectsFromArray:resp.item];
                 handler(catesCache_);
             }
             else {
                 handler(nil);
             }
         }
         else {
             //网络出错
             handler(nil);
         }
         categoriesFetcher = nil;
     }];
}

-(CategoryItem*)getCateById:(long)cateId
{
    for (CategoryItem* cate in catesCache_)
    {
        if(cate.cateId == cateId)
            return cate;
    }
    return nil;
}

-(void)loadSubsChannelsOfCategory:(long)cateId page:(NSInteger)page withCompletionHandler:(void(^)(NSArray* channels))handler
{
        //从网络获取
        id req = [SurfRequestGenerator getSubsChannelsRequest:cateId page:page];
        GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
        [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* err)
         {
             [[NSURLCache sharedURLCache] removeAllCachedResponses];
             [[NSURLCache sharedURLCache] setDiskCapacity:0];
             [[NSURLCache sharedURLCache] setMemoryCapacity:0];
            if(err) {
                //网络出错
                handler(nil);
            }
            else {
                NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
                SubsChannelsListResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[SubsChannelsListResponse class]];
                if(resp && resp.item) {
                    //改写各channel的imageurl成完全形式
                    for (SubsChannel* ch in resp.item) {
                        NSURL* url = [NSURL URLWithString:ch.ImageUrl relativeToURL:[NSURL URLWithString:resp.apicPass]];
                        ch.ImageUrl = [url absoluteString];
                    }
                    
                    //给服务器端的bug擦屁股开始
                    NSMutableArray *array = [NSMutableArray new];
                    for (SubsChannel *channel in resp.item) {
                        if ([self getChannelById:channel.channelId fromArray:array]) {
                            continue;
                        }
                        [array addObject:channel];
                    }
                    //给服务器端的bug擦屁股结束
//                    [self getCateById:cateId].channels = array;
                    handler(array);
                }
                else {
                    handler(nil);
                }
            }
         }];
}

//获取该推荐订阅频道列表
-(void)loadRecommendSubsChannelsWithCompletionHandler:(void(^)(NSArray* channels))handler
{
    id req = [SurfRequestGenerator getRecommendSubsChannelsRequest];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* err) {
         [[NSURLCache sharedURLCache] removeAllCachedResponses];
         [[NSURLCache sharedURLCache] setDiskCapacity:0];
         [[NSURLCache sharedURLCache] setMemoryCapacity:0];
         if(err) {
             // 网络出错
             handler(nil);
         } else {
             NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
             RecommendSubsChannelResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[RecommendSubsChannelResponse class]];
             if(resp && resp.item) {
                 for (SubsChannel* ch in resp.item) {
                     NSURL* url = [NSURL URLWithString:ch.ImageUrl relativeToURL:[NSURL URLWithString:resp.apicPass]];
                     ch.ImageUrl = [url absoluteString];
                 }
                 NSArray *array = [resp.item sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                                              SubsChannel* t1 = (SubsChannel*)obj1;
                                              SubsChannel* t2 = (SubsChannel*)obj2;
                                              return ([t1.index longLongValue] <= [t2.index longLongValue]) ? NSOrderedAscending : NSOrderedDescending;
                                  }];
                 handler(array);
             } else {
                 handler(nil);
             }
         }
     }];
}

//获取搜索到的订阅频道列表
-(void)loadSearchedSubsChannels:(NSString *)name page:(int)page withCompletionHandler:(void(^)(BOOL success, NSArray* channels))handler
{
    id req = [SurfRequestGenerator getSearchSubsChannelRequestName:name with:page];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* err) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        if(err) {
            //网络出错
            handler(NO, nil);
        } else {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            RecommendSubsChannelResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[RecommendSubsChannelResponse class]];
            if(resp && [resp.item count] >0) {
                for (SubsChannel* ch in resp.item) {
                    NSURL* url = [NSURL URLWithString:ch.ImageUrl relativeToURL:[NSURL URLWithString:resp.apicPass]];
                    ch.ImageUrl = [url absoluteString];
                }
                NSArray *array = [resp.item sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    SubsChannel* t1 = (SubsChannel*)obj1;
                    SubsChannel* t2 = (SubsChannel*)obj2;
                    return ([t1.index longLongValue] <= [t2.index longLongValue]) ? NSOrderedAscending : NSOrderedDescending;
                }];
                handler(YES, array);
            } else {
                handler(YES, nil);
            }
        }
    }];
}

-(void)addChannelObserver:(id<SubsChannelChangedObserver>)observer
{
    if(![observers_ containsObject:observer])
        [observers_ addObject:observer];
}

-(void)removeChannelObserver:(id<SubsChannelChangedObserver>)observer
{
    [observers_ removeObject:observer];
}

-(BOOL)channelSubsStatus:(long)channelId               //检测某个频道的订阅状态,包括已订阅还是将要订阅
{
    if ([self isChannelReadyToSubscribed:channelId]) {
        return YES;
    } else if ([self isChannelReadyToUnsubscribed:channelId]) {
        return NO;
    }
    return [self isChannelSubscribed:channelId];
}

-(BOOL)isChannelSubscribed:(long)channelId             //检测某个频道是否被订阅
{
    for (SubsChannel* channel in subsChannels_)
    {
        if(channel.channelId == channelId)
            return YES;
    }
    return NO;
}

-(BOOL)isChannelReadyToSubscribed:(long)channelId      //检测某个频道是否将要被订阅
{
    for (SubsChannel *channel in commitTaskInfo_.toSubs) {
        if(channel.channelId == channelId)
            return YES;
    }
    return NO;
}

-(BOOL)isChannelReadyToUnsubscribed:(long)channelId    //检测某个频道是否将要被取消订阅
{
    for (NSNumber *subsId in commitTaskInfo_.toUnsubs) {
        if([subsId longLongValue] == channelId)
            return YES;
    }
    return NO;
}

-(BOOL)magazineSubsStatus:(long)magazineId               //检测某个期刊的订阅状态,包括已订阅还是将要订阅
{    
    if ([self isMagazineReadyToSubscribed:magazineId]) {
        return YES;
    } else if ([self isMagazineReadyToUnsubscribed:magazineId]) {
        return NO;
    }
    return [[MagazineManager sharedInstance] isMagazineSubscribed:magazineId];
}

-(BOOL)isMagazineReadyToSubscribed:(long)magazineId     //检测某个期刊是否将要被订阅
{
    for (MagazineSubsInfo *magazine in commitTaskInfo_.toMagazineSubs) {
        if(magazine.magazineId == magazineId)
            return YES;
    }
    return NO;
}

-(BOOL)isMagazineReadyToUnsubscribed:(long)magazineId   //检测某个期刊是否将要被取消订阅
{
    for (NSNumber *subsId in commitTaskInfo_.toMagazineUnsubs) {
        if([subsId longLongValue] == magazineId)
            return YES;
    }
    return NO;
}

-(SubsChannel*)getChannelById:(long)channelId          //根据频道id获取频道信息
{
    for (SubsChannel* channel in subsChannels_)
    {
        if(channel.channelId == channelId)
            return channel;
    }
    return nil;
}

-(SubsChannel*)getChannelById:(long)channelId fromArray:(NSArray*)array       //根据频道id获取频道信息
{
    for (SubsChannel* channel in array)
    {
        if(channel.channelId == channelId)
            return channel;
    }
    return nil;
}

-(void)addSubscription:(SubsChannel*)channel           //添加订阅
{
    if(!commitTaskInfo_) {
        commitTaskInfo_ = [SubsChannelsCommitTaskInfo new];
    }
    
    if (channel) {
        [commitTaskInfo_.toSubs addObject:channel];
    }
}

-(void)removeSubscription:(SubsChannel*)channel        //退订
{
    if(!commitTaskInfo_)
    {
        commitTaskInfo_ = [SubsChannelsCommitTaskInfo new];
    }
    
    // 只有一个订阅频道，是不能退订的
    if (subsChannels_.count > 1) {
        [commitTaskInfo_.toUnsubs addObject:[NSNumber numberWithLong:channel.channelId]];
    }
}

//要订阅的栏目的个数
- (NSInteger)countOfToSubs
{
    if (commitTaskInfo_) {
        return [commitTaskInfo_.toSubs count];
    }
    return 0;
}

//将刚加入的要订阅的栏目移除
- (void)removeChannelFromToSubs:(SubsChannel*)channel
{
    if(commitTaskInfo_) {
        for (int i = 0; i < [commitTaskInfo_.toSubs count]; i++) {
            SubsChannel *s = commitTaskInfo_.toSubs[i];
            if (s.channelId == channel.channelId) {
                [commitTaskInfo_.toSubs removeObject:s];
                break;
            }
        }
    }
}

//将刚加入的要被取消订阅的栏目移除
- (void)removeChannelFromToUnsubs:(SubsChannel*)channel
{
    if(commitTaskInfo_) {
        for (int i = 0; i < [commitTaskInfo_.toUnsubs count]; i++) {
            NSNumber *unsubsId = commitTaskInfo_.toUnsubs[i];
            if ([unsubsId longLongValue] == channel.channelId) {
                [commitTaskInfo_.toUnsubs removeObject:unsubsId];
                break;
            }
        }
    }
}

//增加期刊订阅
- (void)addMagazinze:(MagazineSubsInfo*)magazine
{
    if(!commitTaskInfo_)
    {
        commitTaskInfo_ = [SubsChannelsCommitTaskInfo new];
    }
    [commitTaskInfo_.toMagazineSubs addObject:magazine];
}

//退订期刊订阅
- (void)removeMagazine:(MagazineSubsInfo*)magazine
{
    if(!commitTaskInfo_)
    {
        commitTaskInfo_ = [SubsChannelsCommitTaskInfo new];
    }
    [commitTaskInfo_.toMagazineUnsubs addObject:[NSNumber numberWithLong:magazine.magazineId]];
}

//将刚加入的要订阅的期刊移除
- (void)removeMagazineFromToMagazineSubs:(MagazineSubsInfo*)magazine
{
    if(commitTaskInfo_) {
        for (int i = 0; i < [commitTaskInfo_.toMagazineSubs count]; i++) {
            MagazineSubsInfo *m = commitTaskInfo_.toMagazineSubs[i];
            if (m.magazineId == magazine.magazineId) {
                [commitTaskInfo_.toMagazineSubs removeObject:m];
                break;
            }
        }
    }
}

//将刚加入的要被取消订阅的期刊移除
- (void)removeMagazineFromToMagazineUnsubs:(MagazineSubsInfo*)magazine
{
    if(commitTaskInfo_) {
        for (int i = 0; i < [commitTaskInfo_.toMagazineUnsubs count]; i++) {
            NSNumber *unsubsId = commitTaskInfo_.toMagazineUnsubs[i];
            if ([unsubsId longLongValue] == magazine.magazineId) {
                [commitTaskInfo_.toMagazineUnsubs removeObject:unsubsId];
                break;
            }
        }
    }
}

-(BOOL)commitChangesWithHandler:(void(^)(BOOL succeeded))handler   //提交更改
{
    if([self isInCommitting]) {
        handler (NO);
        return NO;
    }
    
    NSMutableString *coids = [NSMutableString new];
    NSMutableArray *arrCoids = [NSMutableArray new];
    
//    if ([AppSettings boolForKey:BoolKeyShowSubsPrompt]) {
//        [visibleSubsChannels removeAllObjects];
//        [invisibleSubsChannels removeAllObjects];
//        [wapVisibleSubsChannels removeAllObjects];
//        [subsChannels_ removeAllObjects];
//    }
    
    //将新加的订阅排在前面
    if ([commitTaskInfo_.toSubs count] > 0)
    {
        for (SubsChannel* channel in commitTaskInfo_.toSubs)
        {
            if([arrCoids containsObject:[NSString stringWithFormat:@"%ld",channel.channelId]])
            {
                continue;
            }
            
            if(![subsChannels_ containsObject:channel])
            {
                [arrCoids addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
                DJLog(@"新增栏目：%ld %@",channel.channelId,channel.name);
            }
        }
    }
    for(SubsChannel *channel in visibleSubsChannels)
    {
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld",channel.channelId]])
        {
            continue;
        }
        [arrCoids addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
    }
    for(SubsChannel *channel in invisibleSubsChannels)
    {
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld",channel.channelId]])
        {
            continue;
        }

        [arrCoids addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
    }
    for(SubsChannel *channel in wapVisibleSubsChannels)
    {
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld",channel.channelId]])
        {
            continue;
        }

        [arrCoids addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
    }
    
    //增加的期刊
    if ([commitTaskInfo_.toMagazineSubs count] > 0) {
        for (MagazineSubsInfo *magazine in commitTaskInfo_.toMagazineSubs) {
            if([arrCoids containsObject:[NSString stringWithFormat:@"%ld", magazine.magazineId]]) {
                continue;
            }
            
            if(![[MagazineManager sharedInstance] isMagazineSubscribed:magazine.magazineId])
            {
                [arrCoids addObject:[NSString stringWithFormat:@"%ld",magazine.magazineId]];
                DJLog(@"新增期刊：%ld %@",magazine.magazineId,magazine.name);
            }
        }
    }
    
    //期刊
    for (MagazineSubsInfo *magazine in [MagazineManager sharedInstance].subsMagazines) {
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld", magazine.magazineId]]) {
            continue;
        }
        
        [arrCoids addObject:[NSString stringWithFormat:@"%ld", magazine.magazineId]];
    }
    
    for (MagazineSubsInfo *magazine in [MagazineManager sharedInstance].wapVisiableMagazines) {
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld", magazine.magazineId]]) {
            continue;
        }
        
        [arrCoids addObject:[NSString stringWithFormat:@"%ld", magazine.magazineId]];
    }
    
    //退订的栏目
    if (commitTaskInfo_.toUnsubs && [commitTaskInfo_.toUnsubs count] > 0)
    {
        for(NSNumber* channelRemoved in commitTaskInfo_.toUnsubs)
        {
            if([arrCoids containsObject:[channelRemoved stringValue]]) {
                [arrCoids removeObject:[channelRemoved stringValue]];
            }
        }
    }
    
    //退订的期刊
    if (commitTaskInfo_.toMagazineUnsubs && [commitTaskInfo_.toMagazineUnsubs count] > 0)
    {
        for(NSNumber* channelRemoved in commitTaskInfo_.toMagazineUnsubs)
        {
            if([arrCoids containsObject:[channelRemoved stringValue]]) {
                [arrCoids removeObject:[channelRemoved stringValue]];
            }
        }
    }
    
    for (NSString *subsId in arrCoids) {
        if (coids.length <= 0) {
            [coids appendFormat:@"%@",subsId];
        }else{
            [coids appendFormat:@",%@",subsId];
        }
    }
    
    //校验可视频道的数量是否符合要求
    //目前限制是：1<=x<=80
    if ([arrCoids count] < 1
        || [arrCoids count] > 80)
    {
        //---begin---是因为有了推荐订阅之后,在用户还没有栏目订阅的情况下未登录用户还是可以退定最后一个期刊
        UserInfo *info = [[UserManager sharedInstance] loginedUser];
        if (!info &&
            [arrCoids count] == 0 &&
            [commitTaskInfo_.toMagazineUnsubs count] == 1) {
            //不做操作
        }//---end---
        else {
            NSString *tip = @"您的订阅源已达上限，请退订一些栏目再订阅";
            if (0 == [arrCoids count]) {
                tip = @"您的订阅源不能为空";
            }
            
            
            [PhoneNotification autoHideWithText:tip];
            
            commitTaskInfo_ = nil;
            handler(NO);
            arrCoids = nil;
            return NO;
        }
    }
    arrCoids = nil;
    
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    if (userInfo)
    {
        isCommitChannels = YES;
        id req = [SurfRequestGenerator commitSubsRequestWithUserId:[userInfo.userID integerValue] coids:coids];
        GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
        [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            [[NSURLCache sharedURLCache] setDiskCapacity:0];
            [[NSURLCache sharedURLCache] setMemoryCapacity:0];
            isCommitChannels = NO;
            BOOL succeeded = NO;
            if (!error) {
                NSString* channelsListBody = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
                SurfJsonResponseBase* channelsResult = [EzJsonParser deserializeFromJson:channelsListBody
                                                                                    AsType:[SurfJsonResponseBase class]];
                if ([channelsResult.res.reCode isEqualToString:@"1"]) {
                    [self handleCommitSucceeded];
                    commitTaskInfo_ = nil;
                    
                    [backupVisibleSubsChannels removeAllObjects];
                    [backupVisibleSubsChannels addObjectsFromArray:visibleSubsChannels];
                    succeeded = YES;
                }
            }
            
            if (!succeeded) {
                [visibleSubsChannels removeAllObjects];
                [visibleSubsChannels addObjectsFromArray:backupVisibleSubsChannels];
            }
            
            if (handler != nil) {
                handler(succeeded);
            }
        }];
    }
    else
    {
        //游客用户，保存在本地
        [self handleCommitSucceeded];
        //清空task
        commitTaskInfo_ = nil;
        
        if (handler != nil) {
             handler(YES);
        }
    }
    
    return YES;
}

//清空所有要提交的订阅
-(void)removeAllToSubs
{
    if (commitTaskInfo_) {
        [commitTaskInfo_.toSubs removeAllObjects];
        [commitTaskInfo_.toUnsubs removeAllObjects];
        [commitTaskInfo_.toMagazineSubs removeAllObjects];
        [commitTaskInfo_.toMagazineUnsubs removeAllObjects];
        commitTaskInfo_ = nil;
    }
}

-(BOOL)isInCommitting                                  //当前是否正在提交更改
{
    return isCommitChannels;
}

-(BOOL)isChannel:(SubsChannel*)channel existsInArray:(NSArray*)array
{
    for(SubsChannel* chnl in array)
    {
        if (chnl.channelId == channel.channelId){
            return YES;
        }
    }
    return NO;
}

//完全覆盖本地的订阅关系
-(void)overwriteLocal:(SubsChannelsListResponse*)resp
{
    //将已失效的频道干掉
    for (int i = 0; i < [subsChannels_ count]; i++)
    {
        SubsChannel* localChannel = subsChannels_[i];
        if (![self isChannel:localChannel existsInArray:resp.item])
        {
            [visibleSubsChannels removeObject:localChannel];
            [invisibleSubsChannels removeObject:localChannel];
            [wapVisibleSubsChannels removeObject:localChannel];
            
            [subsChannels_ removeObject:localChannel];
            [self notifyChannelRemoved:localChannel];
            i--;
        }
    }
    //将新增的频道保存到本地
    for(SubsChannel* channel in resp.item)
    {
        if (channel.rssType == 6) {  //先忽略掉期刊
            continue;
        }
        if ([channel.isVisible isEqualToString:@"0"] && channel.rssType == 1) {
            if([wapVisibleSubsChannels containsObject:channel])
            {
                continue;
            }
            [wapVisibleSubsChannels addObject:channel];
            continue;
        }
        
        
        if([self isChannel:channel existsInArray:subsChannels_]){
            SubsChannel* oldSubs = [self getSubsChannelForArray:channel.channelId];
//            channel.threadsSummaryMaxTime = oldSubs.threadsSummaryMaxTime;            
            [visibleSubsChannels removeObject:oldSubs];
            [invisibleSubsChannels removeObject:oldSubs];
            [backupVisibleSubsChannels removeObject:oldSubs];
            [wapVisibleSubsChannels removeObject:oldSubs];
            [subsChannels_ removeObject:oldSubs];
        }
        
        //**重要**
        NSURL* url = [NSURL URLWithString:channel.ImageUrl relativeToURL:[NSURL URLWithString:resp.apicPass]];
        channel.ImageUrl = url.absoluteString;
        [[NSFileManager defaultManager]createDirectoryAtPath:[PathUtil pathOfSubsChannel:channel] withIntermediateDirectories:YES attributes:nil error:nil];
        [[EzJsonParser serializeObjectWithUtf8Encoding:channel] writeToFile:[PathUtil pathOfSubsChannelInfo:channel] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        [subsChannels_ addObject:channel];
        [self notifyChannelAdded:channel];
    }
    [self handleSubsChannelsResorted];

}

-(SubsChannel*)getSubsChannelForArray:(long)cid{
    for(SubsChannel* chnl in subsChannels_){
        if (chnl.channelId == cid){
            return chnl;
        }
    }
    return nil;
}

//跟本地订阅关系进行合并后再提交至服务端
-(void)mergeLocalAndCommitIfNecessary:(SubsChannelsListResponse*)resp
{
    for(SubsChannel* respChannel in resp.item)
    {
        bool found = NO;
        for(SubsChannel* localChannel in subsChannels_)
        {
            if (localChannel.channelId == respChannel.channelId)
            {
                found = YES;
                break;
            }
        }
        if (!found)
        {
            NSURL* url = [NSURL URLWithString:respChannel.ImageUrl relativeToURL:[NSURL URLWithString:resp.apicPass]];
            respChannel.ImageUrl = url.absoluteString;
            [self addSubscription:respChannel];
        }
    }
    
    [self commitChangesWithHandler:^(BOOL succeeded)
     {
         //TODO
     }];
}

-(void)handleCommitSucceeded
{
    //提交成功
    //修改_subsChannels
    //增加对应isostore目录和文件
    if (commitTaskInfo_.toSubs && [commitTaskInfo_.toSubs count] > 0)
    {
        //增加订阅提交成功
        for(SubsChannel* channelAdded in commitTaskInfo_.toSubs)
        {
            //创建对应的目录和文件
            NSString* channelDir = [PathUtil pathOfSubsChannel:channelAdded];
            [[NSFileManager defaultManager] createDirectoryAtPath:channelDir withIntermediateDirectories:YES attributes:nil error:nil];
            [[EzJsonParser serializeObjectWithUtf8Encoding:channelAdded] writeToFile:[PathUtil pathOfSubsChannelInfo:channelAdded] atomically:YES encoding:NSUTF8StringEncoding error:nil];
#ifdef ipad
            [subsChannels_ addObject:channelAdded];
            [self notifyChannelAdded:channelAdded];
#else
            [subsChannels_ insertObject:channelAdded atIndex:0];
            [self notifyChannelAddedToFirst:channelAdded];
#endif
        }
    }
    
    if (commitTaskInfo_.toUnsubs && [commitTaskInfo_.toUnsubs count] > 0)
    {
        //移除订阅提交成功
        for(NSNumber* channelRemoved in commitTaskInfo_.toUnsubs)
        {
            for (int i = 0; i < [subsChannels_ count]; i++)
            {
                SubsChannel* channel = (SubsChannel*)subsChannels_[i];
                if (channel.channelId == [channelRemoved longValue])
                {
                    [subsChannels_ removeObjectAtIndex:i];
                    [self notifyChannelRemoved:channel];
                   
                    break;
                }
            }
        }
    }
    [self handleSubsChannelsResorted];
    
    //提交成功
    //修改subsMagazine
    //增加对应isostore目录和文件
    if (commitTaskInfo_.toMagazineSubs && [commitTaskInfo_.toMagazineSubs count] > 0)
    {
        //增加订阅提交成功
        for(MagazineSubsInfo* magazineAdd in commitTaskInfo_.toMagazineSubs)
        {
            magazineAdd.refreshPeridical = YES;
            //创建对应的目录和文件
            NSString* magazineDir = [PathUtil pathOfMagazine:magazineAdd];
            [[NSFileManager defaultManager] createDirectoryAtPath:magazineDir withIntermediateDirectories:YES attributes:nil error:nil];
            [[EzJsonParser serializeObjectWithUtf8Encoding:magazineAdd] writeToFile:[PathUtil pathOfMagazineInfo:magazineAdd] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            
            [[MagazineManager sharedInstance].subsMagazines insertObject:magazineAdd atIndex:0];
//            [self notifyChannelAdded:channelAdded];
        }
    }
    
    if (commitTaskInfo_.toMagazineUnsubs && [commitTaskInfo_.toMagazineUnsubs count] > 0)
    {
        //移除订阅提交成功
        for(NSNumber* magazineRemoved in commitTaskInfo_.toMagazineUnsubs)
        {
            for (int i = 0; i < [[MagazineManager sharedInstance].subsMagazines count]; i++)
            {
                MagazineSubsInfo* magazine = (MagazineSubsInfo*)[MagazineManager sharedInstance].subsMagazines[i];
                if (magazine.magazineId == [magazineRemoved longValue])
                {
                    [[MagazineManager sharedInstance].subsMagazines removeObjectAtIndex:i];
//                    [self notifyChannelRemoved:channel];
                    
                    break;
                }
            }
        }
    }
    [[MagazineManager sharedInstance] handleMagazinesResorted];
}

-(BOOL)isLocalSubsChannelsDifferFromFirstGot
{
    NSString* firstGot = [AppSettings stringForKey:STRINGKEY_SubsChannelsIdsFirstGot];
    if ([firstGot isEmptyOrBlank] || [subsChannels_ count] == 0)
        return NO;
    NSMutableArray* ids = [NSMutableArray arrayWithArray:[firstGot componentsSeparatedByString:@","]];
    NSMutableArray* currentIds = [NSMutableArray new];
    for (SubsChannel* channel in subsChannels_)
    {
        [currentIds addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
    }
    
    NSSortDescriptor* sortOrder = [NSSortDescriptor sortDescriptorWithKey: @"self" ascending: YES];
    [ids sortUsingDescriptors:[NSArray arrayWithObject: sortOrder]];
    [currentIds sortUsingDescriptors:[NSArray arrayWithObject: sortOrder]];
    
    return ![ids isEqualToArray:currentIds];
}
#pragma mark - 
//保存栏目订阅信息
-(void)handleSubsChannelsResorted
{    
    SubsChannelsSortInfo* sortInfo = [[SubsChannelsSortInfo alloc]init];
    sortInfo.visibleIdsArray = [NSMutableArray new];
    sortInfo.invisibleIdsArray = [NSMutableArray new];
    sortInfo.wapVisibleSubsChannels = [NSMutableArray new];
    for (SubsChannel* channel in visibleSubsChannels)
    {
        [sortInfo.visibleIdsArray addObject:[NSNumber numberWithLong:channel.channelId]];
    }
    for (SubsChannel* channel in invisibleSubsChannels)
    {
        [sortInfo.invisibleIdsArray addObject:[NSNumber numberWithLong:channel.channelId]];
    }
    for (SubsChannel* channel in wapVisibleSubsChannels)
    {
        [sortInfo.wapVisibleSubsChannels addObject:[NSNumber numberWithLong:channel.channelId]];
    }
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    if (userInfo) {
        userInfo.subsChannelsSortInfo = sortInfo;
        [[UserManager sharedInstance] savePathOfUserInfo];
    }
    else
    {
        [[EzJsonParser serializeObjectWithUtf8Encoding:sortInfo] writeToFile:[PathUtil pathOfSubsChannelSortInfo]
                                                                  atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    [self NotifySusbChannelChanged];
}

#pragma mark - UserManagerObserver
-(void)currentUserLoginChanged
{
    UserManager *um = [UserManager sharedInstance];
    UserInfo *info = [um loginedUser];

    if (!info) {
        //退出登陆展示游客用户
        commitTaskInfo_ = nil;
        [self loadSortInfoChannls];
        
#ifndef ipad
        //游客状态下删除无关的订阅数据
        NSArray *fileArr = [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfSubsChannels]];
        for (NSString *fileName in fileArr)
        {
            if (![self getChannelById:[fileName integerValue]]) {
                [FileUtil deleteDirAndContents:[[PathUtil rootPathOfSubsChannels]
                                                stringByAppendingPathComponent:fileName]];
            }
        }
#endif
        [self performSelector:@selector(NotifySusbChannelChanged) withObject:nil afterDelay:0.2];
    }
}

// 刷新订阅列表
- (void)refreshSubsChannelListWithUser:(UserInfo*)userInfo handler:(void(^)(BOOL succeeded))handler
{
    if (isCommitChannels) {
        if (handler) {
            handler(NO);
        }
    }
    
    if (!userInfo){
        if (handler) {
            handler(NO);
        }
        [self performSelector:@selector(NotifySusbChannelChanged) withObject:nil afterDelay:0.2];
    }
    
    if (userInfo) {
        //新登录用户
//        if ([AppSettings boolForKey:BoolKeyShowSubsPrompt]) {
//            [visibleSubsChannels removeAllObjects];
//            [invisibleSubsChannels removeAllObjects];
//            [wapVisibleSubsChannels removeAllObjects];
//            [subsChannels_ removeAllObjects];
//            [self NotifySusbChannelChanged];
//            if (handler) handler(YES);
//        
//            return;
//        }
        
        //坑爹的服务起返回
        //栏目订阅和期刊订阅是放在一起返回的
        //搞得这个类的代码会很乱
        //所以将一部分期刊的逻辑放到MagazineManager.m类中实现
        isCommitChannels = YES;
        id channelReq = [SurfRequestGenerator getUserSubsChannelsListRequestByUserId:[userInfo.userID integerValue]];
        GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:channelReq];
        [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
         {
             [[NSURLCache sharedURLCache] removeAllCachedResponses];
             [[NSURLCache sharedURLCache] setDiskCapacity:0];
             [[NSURLCache sharedURLCache] setMemoryCapacity:0];
             if (!error)
             {
                 //将服务器返回的订阅关系存在本地
                 isCommitChannels = NO;
                 NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
                 
                 //栏目订阅
                 Class classType = [SubsChannelsListResponse class];
                 SubsChannelsListResponse* channelsList =
                 [EzJsonParser deserializeFromJson:body
                                            AsType:classType];
                 
                 if(channelsList) {
                     channelsList.userId = userInfo.userID;
                     if ([channelsList.item count] > 0) {
                         [self overwriteLocal:channelsList];
                         [self NotifySusbChannelChanged];
                     }
                     if (handler) {
                         handler(YES);
                     }
                 }
             }
             else {
                 //获取订阅列表失败
                 if (handler) {
                     handler(NO);
                 }
             }
             
         }];
    }
}

-(void)NotifySusbChannelChanged{
    for (id<SubsChannelChangedObserver> observer in observers_){
        [observer subsChannelChanged];
    }
}

-(void)loadUserSubsChannels{
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    
    if (!userInfo) {
        return;
    }
    
    // 加载用户的订阅信息
    SubsChannelsSortInfo* sortInfo;
    NSString *path = [PathUtil pathOfUserSubsChannelSortInfo:userInfo.userID];
    if (path) { //和以前版本兼容，讲订阅关系整合到userinfo里
        NSString *json = [NSString stringWithContentsOfFile:path
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
        sortInfo = [EzJsonParser deserializeFromJson:json
                                                                    AsType:[SubsChannelsSortInfo class]];
        userInfo.subsChannelsSortInfo = sortInfo;
        [[EzJsonParser serializeObjectWithUtf8Encoding:userInfo] writeToFile:[PathUtil pathOfUserInfo]
                                                                     atomically:YES encoding:NSUTF8StringEncoding
                                                                          error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:[PathUtil pathOfUserSubsChannelSortInfo:userInfo.userID] error:nil];
    } else {
        sortInfo = userInfo.subsChannelsSortInfo;
    }
    
    [visibleSubsChannels removeAllObjects];
    [invisibleSubsChannels removeAllObjects];
    [wapVisibleSubsChannels removeAllObjects];
    [subsChannels_ removeAllObjects];
    [backupVisibleSubsChannels removeAllObjects];
    
    //有排序信息
    NSMutableArray *arrCoids = [NSMutableArray new];
    
    for (NSNumber* cid in sortInfo.visibleIdsArray)
    {
        SubsChannel* channel = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfSubsChannelInfoWithChannelId:[cid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[SubsChannel class]];
        if (channel == nil)
        {
            continue;
        }
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld",channel.channelId]])
        {
            continue;
        }
        [arrCoids addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
        
        [visibleSubsChannels addObject:channel];
    }
    [backupVisibleSubsChannels addObjectsFromArray:visibleSubsChannels];
    
    for (NSNumber* cid in sortInfo.invisibleIdsArray)
    {
        SubsChannel* channel = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfSubsChannelInfoWithChannelId:[cid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[SubsChannel class]];
        if (channel == nil)
        {
            continue;
        }
        if([arrCoids containsObject:[NSString stringWithFormat:@"%ld",channel.channelId]])
        {
            continue;
        }
        [arrCoids addObject:[NSString stringWithFormat:@"%ld",channel.channelId]];
        
        [invisibleSubsChannels addObject:channel];
    }

    [subsChannels_ addObjectsFromArray:visibleSubsChannels];
    [subsChannels_ addObjectsFromArray:invisibleSubsChannels];
    
    arrCoids = nil;
}
//是否有栏目订阅要提交
- (BOOL)hasChannelToSubs
{
    if (commitTaskInfo_ &&
        ([commitTaskInfo_.toSubs count] > 0 || [commitTaskInfo_.toUnsubs count] > 0)) {
        return YES;
    }
    
    [self removeAllToSubs];
    return NO;
}

//是否有期刊订阅要提交
- (BOOL)hasMagazineToSubs
{
    if (commitTaskInfo_ &&
        ([commitTaskInfo_.toMagazineSubs count] > 0 || [commitTaskInfo_.toMagazineUnsubs count] > 0)) {
        return YES;
    }
    
    [self removeAllToSubs];
    return NO;
}

//是否是最后一个栏目订阅
- (BOOL)alreadyLastChannel
{
    if ([visibleSubsChannels count] + [invisibleSubsChannels count] == 1) {
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    UserManager *manager = [UserManager sharedInstance];
    [manager removeUserLoginObserver:self];
}




@end
