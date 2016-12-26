//
//  HotChannelsManager.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotChannelsManager.h"
#import "HotChannelsListResponse.h"
#import "SurfDbManager.h"
#import "SurfRequestGenerator.h"
#import "GTMHTTPFetcher.h"
#import "NSString+Extensions.h"
#import "EzJsonParser.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "ThreadsManager.h"
#import "CityManager.h"
#import "SurfFlagsManager.h"
#import "RssSourceData.h"




@interface HotChannelsSortInfo : NSObject
@property NSMutableArray* visibleIdsArray;
@property NSMutableArray* invisibleIdsArray;
@end

@implementation HotChannelsSortInfo
@end

@implementation HotChannelsManager(private)

-(id)init
{
    if(self = [super init])
    {
        //载入本地热推频道列表
        if(!invisibleHotChannels_ || !visibleHotChannels_)
        {
            visibleHotChannels_ = [NSMutableArray new];
            invisibleHotChannels_ = [NSMutableArray new];
            
            NSString* rootPath = [PathUtil rootPathOfHotChannels];
            NSArray* channelIds = [FileUtil getSubdirNamesOfDir:rootPath];
            HotChannelsSortInfo* sortInfo = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfHotChannelSortInfo] encoding:NSUTF8StringEncoding error:nil] AsType:[HotChannelsSortInfo class]];
            BOOL sortInfoPresent = (sortInfo.visibleIdsArray && sortInfo.invisibleIdsArray && [sortInfo.visibleIdsArray count]);
            isSortChannels_ = sortInfoPresent;
            if(sortInfoPresent)
            {
                //有排序信息
                for (NSNumber* cid in sortInfo.visibleIdsArray)
                {
                    NSUInteger channelID = [cid longValue];
                    NSString *jsonPath =
                    [PathUtil pathOfHotChannelInfoWithChannelId:channelID];
                    NSString *jsonStr =
                    [NSString stringWithContentsOfFile:jsonPath
                                              encoding:NSUTF8StringEncoding error:nil];
                    HotChannel* channel =
                    [EzJsonParser deserializeFromJson:jsonStr
                                               AsType:[HotChannel class]];
                    if (!channel ||
                        [self getChannelWithSameId:channel inArray:visibleHotChannels_] ||
                        [self getChannelWithSameId:channel inArray:invisibleHotChannels_] ||
                        [self isFilterHotChannel:channel] ||
                        [self isFilterBeautifulChannel:channel]) {
                        continue;
                    }
                    
                    if ([channel.channelName isEqualToString:@"热推"]) {
                        [visibleHotChannels_ insertObject:channel atIndex:0];
                    }
                    else {
                        [visibleHotChannels_ addObject:channel];
                    }
                }
                
                for (NSNumber* cid in sortInfo.invisibleIdsArray)
                {
                    HotChannel* channel = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfHotChannelInfoWithChannelId:[cid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[HotChannel class]];
                    if (!channel ||
                        [self getChannelWithSameId:channel inArray:visibleHotChannels_]||
                        [self getChannelWithSameId:channel inArray:invisibleHotChannels_] ||
                        [self isFilterHotChannel:channel] ||
                        [self isFilterBeautifulChannel:channel]) {
                        continue;
                    }
                    [invisibleHotChannels_ addObject:channel];
                }
            }
            else
            {
                //无排序信息，表示应用第一次请求
                for(NSString* cid in channelIds)
                {
                    HotChannel* channel = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfHotChannelInfoWithChannelId:[cid integerValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[HotChannel class]];
                    // 过滤图集频道
                    if (channel &&
                        ![self isFilterHotChannel:channel] &&
                        ![self isFilterBeautifulChannel:channel]) {
                        [visibleHotChannels_ addObject:channel];
                    }
                }
                
                // 按服务器给的顺序排序
                if ([visibleHotChannels_ count] > 1) {
                    
                    [visibleHotChannels_ sortUsingComparator:^NSComparisonResult(id obj1,id obj2) {
                        HotChannel* t1 = (HotChannel*)obj1;
                        HotChannel* t2 = (HotChannel*)obj2;
                        if(t1.channelIndex <= t2.channelIndex) {
                            return NSOrderedAscending;
                        }
                        else {
                            return NSOrderedDescending;
                        }
                    }];
                }
            }
            
            // 对新的新闻频道进行标记检查
            [[SurfFlagsManager sharedInstance] checkNewsChannels:visibleHotChannels_];
        }
    }
    return self;
}




// 是否需要过滤这个频道
- (BOOL)isFilterHotChannel:(HotChannel*)hotchannel
{
    // 这个可以扩展其他过滤的频道（55093是图集的频道id,呵呵余雷鸣让我只过滤channelId）
    if ([hotchannel.channelName isEqualToString:@"图集"] ||
        hotchannel.channelId == 55093) {
        return YES;
    }
    return NO;
}

// 过滤美女频道
-(BOOL)isFilterBeautifulChannel:(HotChannel*)hc
{
#if JAILBREAK || ENTERPRISE
    return NO;
#else
    return [hc isBeautifulChannel];
#endif
}

@end


@implementation HotChannelsManager

@synthesize visibleHotChannels = visibleHotChannels_;
@synthesize invisibleHotChannels = invisibleHotChannels_;

+(HotChannelsManager *)sharedInstance
{
    static HotChannelsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HotChannelsManager alloc] init];
    });
    
    return sharedInstance;
}
-(void)refreshWithCompletionHandler:(HotChannelsRefreshResultHandler)handler
{
    id req = [SurfRequestGenerator getHotChannelsListRequest];      // 查询自有新闻栏目
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
    {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
         
        if(!error)
        {
             NSStringEncoding strEncoding = kCFStringEncodingGB_18030_2000;
             NSString *encStr = [[fetcher response] textEncodingName];
             if (encStr && ![encStr isEmptyOrBlank]) {
                 strEncoding = [encStr convertToStringEncoding];
             }
             
             NSString* body = [[NSString alloc] initWithData:data encoding:strEncoding];

             // 保存城市列表到本地
             [self saveCityRssListData:body];
             
             HotChannelsListResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[HotChannelsListResponse class]];
            
            // 获取CSS订阅源
            [[RssSourceManager sharedInstance] setRssList:resp.rec];
            
             [resp.channelList sortUsingComparator:^NSComparisonResult(id obj1,id obj2)
              {
                  HotChannel* t1 = (HotChannel*)obj1;
                  HotChannel* t2 = (HotChannel*)obj2;
                  if(t1.channelIndex <= t2.channelIndex) {
                      return NSOrderedAscending;
                  }
                  else {
                      return NSOrderedDescending;
                  }
              }];
             
             NSFileManager* fm = [NSFileManager defaultManager];
             
             //去除已下线频道
             for(NSInteger i=0;i<[visibleHotChannels_ count];i++)
             {
                 HotChannel* hc = visibleHotChannels_[i];
                 HotChannel* hc1 = [self getChannelWithSameId:hc inArray:resp.channelList];
                 if(hc1)
                 {
                     // 2013.11.1 之后改版
                     // 刷热推频道列表时对本地数据的覆盖策略。之前仅对频道的上线/下线、频道名的修改进行了处理，现在改成完全覆盖本地数据。
                     //（主要原因是之前热推13个频道有些type为0有些为1，现在改成了全都是type0）
                     
                     //以防万一频道id未变，但其他发生变化
                     [visibleHotChannels_ replaceObjectAtIndex:i withObject:hc1];
                 }
                 else
                 {
                     //该频道遭遇下线
                     [visibleHotChannels_ removeObject:hc];
                     i--;
                     
                     //删除该频道的所有数据
                     NSString* channelDir = [PathUtil pathOfHotChannel:hc];
                     [FileUtil deleteContentsOfDir:channelDir];
                     [fm removeItemAtPath:channelDir error:nil];
                 }
             }
             for(NSInteger i=0;i<[invisibleHotChannels_ count];i++)
             {
                 HotChannel* hc = invisibleHotChannels_[i];
                 HotChannel* hc1 = [self getChannelWithSameId:hc inArray:resp.channelList];
                 if(hc1)
                 {
                     //以防万一频道id未变，但其他发生变化
                     [invisibleHotChannels_ replaceObjectAtIndex:i withObject:hc1];
                 }
                 else
                 {
                     //该频道遭遇下线
                     [invisibleHotChannels_ removeObject:hc];
                     i--;
                     
                     //删除该频道的所有数据
                     NSString* channelDir = [PathUtil pathOfHotChannel:hc];
                     [FileUtil deleteContentsOfDir:channelDir];
                     [fm removeItemAtPath:channelDir error:nil];
                 }
             }
             
             // 新增新上线频道
             NSMutableArray *newChannels = [NSMutableArray array];
             for (HotChannel* hc in resp.channelList)
             {
                 // 因版本问题，需要过滤到图集频道
                 if ([self isFilterHotChannel:hc]) continue;
                 
                 // 过滤美女pind
                 if ([self isFilterBeautifulChannel:hc]) continue;
                 
                 HotChannel* hc1 = [self getChannelWithSameId:hc inArray:visibleHotChannels_];
                 HotChannel* hc2 = [self getChannelWithSameId:hc inArray:invisibleHotChannels_];
                 if(!hc1 && !hc2) {
                     //热推置顶
                     if ([hc.channelName isEqualToString:@"热推"]) {
                         [newChannels insertObject:hc atIndex:0];
                     }
                     else {
                         [newChannels addObject:hc];
                     }
                   
                     //保存到各频道文件
                     NSString* channelDir = [PathUtil pathOfHotChannel:hc];
                     DJLog(@"%@", channelDir);
                     [fm createDirectoryAtPath:channelDir withIntermediateDirectories:YES attributes:nil error:nil];
                     [[EzJsonParser serializeObjectWithUtf8Encoding:hc] writeToFile:[PathUtil pathOfHotChannelInfo:hc] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                 }
             }
             
            // 把新增频道添加到频道列表中
            if ([newChannels count] > 0) {
                NSUInteger idx = [visibleHotChannels_ count];
                if (isSortChannels_) {
                    // 用户排序操作过
                    NSRange range = NSMakeRange(idx, [newChannels count]);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    [visibleHotChannels_ insertObjects:newChannels atIndexes:indexSet];
                }
                else {
                    // 用户没有排序操作
                    if ([visibleHotChannels_ count] == 0) {
                        [visibleHotChannels_ addObjectsFromArray:newChannels];
                    }
                    else {
                        for(NSUInteger i=0; i<[newChannels count]; ++i){
                            HotChannel *newHC = newChannels[i];
                            if ([newHC isKindOfClass:[HotChannel class]]) {
                                for (NSUInteger j=0; j<[visibleHotChannels_ count]; ++j) {
                                    HotChannel *tHc = visibleHotChannels_[j];
                                    if (tHc.channelId > newHC.channelIndex) {
                                        [visibleHotChannels_ insertObject:newHC atIndex:j];
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
             }
             
             //最后调整下“本地”频道的的位置
             for (HotChannel *h in visibleHotChannels_) {
                 if (h.channelId == 0 &&
                     [visibleHotChannels_ indexOfObject:h] > 1) {
                     [visibleHotChannels_ removeObject:h];
                     [visibleHotChannels_ insertObject:h atIndex:1];
                     break;
                 }
             }

             
             // 对新的新闻频道进行标记检查
             [[SurfFlagsManager sharedInstance] checkNewsChannels:visibleHotChannels_];
             
             handler(YES,NO);
         }
         else
         {
             handler(NO,YES);
         }
     }];
}

- (void)saveCityRssListData:(NSString*)body
{
    [[CityManager sharedInstance] saveCityRssDataWithBodyStr:body];
}

-(void)handleHotChannelsResorted
{
    isSortChannels_ = YES;
    HotChannelsSortInfo* sortInfo = [[HotChannelsSortInfo alloc]init];
    sortInfo.visibleIdsArray = [NSMutableArray new];
    sortInfo.invisibleIdsArray = [NSMutableArray new];
    for (HotChannel* channel in visibleHotChannels_)
    {
        [sortInfo.visibleIdsArray addObject:[NSNumber numberWithLong:channel.channelId]];
    }
    for (HotChannel* channel in invisibleHotChannels_)
    {
        [sortInfo.invisibleIdsArray addObject:[NSNumber numberWithLong:channel.channelId]];
    }
    [[EzJsonParser serializeObjectWithUtf8Encoding:sortInfo] writeToFile:[PathUtil pathOfHotChannelSortInfo] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(HotChannel*)getChannelWithSameId:(HotChannel*)channel inArray:(NSArray*)array
{
    for (HotChannel* ch in array)
    {
        if(ch.channelId == channel.channelId)
            return ch;
    }
    return nil;
}
-(HotChannel*)hotChannelWithId:(NSUInteger)channelId
{
    for (HotChannel *ch in visibleHotChannels_) {
        if (ch.channelId == channelId) {
            return ch;
        }
    }
    return nil;
}


//- (BOOL)handleHotChannelsUpdate
//{
//    BOOL showUpdate = NO;
//    isNewArray = [self readFileArrayIsNew];
//    selectedArray = [self readFileArraySelected];
//    
//    if ([isNewArray count] > 0 && [selectedArray count] > 0) {
//        //数组isNewArray 包含于 selectedArray
//        //情景：最新新闻都被选中过
//        for (NSInteger i = 0; i< [isNewArray count]; i++) {
//            id obj = [isNewArray objectAtIndex:i];
//            
//            //isNewArray的元素在selectedArray存在
//            BOOL exist = [selectedArray containsObject:obj];
//            if (i == [isNewArray count] -1) {
//                //isNewArray末项元素
//                id lastObj = [isNewArray lastObject];
//                if (exist && [selectedArray containsObject:lastObj]) {
//                    showUpdate = NO;
//                }
//                else{
//                    showUpdate = YES;
//                }
//            }
//        }
//    }
//    else if([isNewArray count] > 0 && [selectedArray count] == 0){
//        showUpdate = YES;
//    }
//    return showUpdate;
//}
//
//- (void)handleHotChannelsIsNew:(HotChannel*)hc
//{
//    NSString * new = [NSString stringWithFormat:@"%@", hc.name];
//    if(!isNewArray){
//        isNewArray = [[NSMutableArray alloc] init];
//    }
//    [isNewArray addObject:new];
//    [self writeToArrayIsNew];
//}
//
//
//-(void)handleHotChannelsSelected:(HotChannel*)hc
//{
//    NSString * sel = [NSString stringWithFormat:@"%@",  hc.name];
//    if(!selectedArray){
//        selectedArray = [[NSMutableArray alloc] init];
//    }
//    [selectedArray addObject:sel];
//    [self writeToArraySelected];
//}
//
//-(BOOL)handleHotChannelsShow:(HotChannel*)hc{
//    
//    BOOL show = NO;
//    if (selectedArray == nil) {
//        selectedArray = [[NSMutableArray alloc] init];
//    }
//
//    
//    selectedArray = [self readFileArraySelected];
//    
//    if ([selectedArray count] > 0) {
//        for (NSInteger i = 0; i< [selectedArray count]; i++) {
//            id obj = [selectedArray objectAtIndex:i];
//            if ([obj isKindOfClass:[NSString class]]) {
//                NSString * str = [NSString stringWithFormat:@"%@",hc.name];
//                if ([selectedArray containsObject:str]) {
//                    show = YES;
//                }
//                else{
//                    show = NO;
//                }
//            }
//        }
//    }
//    return show;
//}
//
//- (void)writeToArrayIsNew
//{
//    NSString *path = [PathUtil pathOfHotChannelIsNew];
//    //新建selectArr数组用来存一些信息
//    NSArray *arr = [isNewArray mutableCopy];
//    NSSet *set = [NSSet setWithArray:arr];
//    NSArray *isNewArr = [set allObjects];
//    //把selectArr这个数组存入程序指定的一个文件里
//    [isNewArr writeToFile:path atomically:YES];
//}


@end
