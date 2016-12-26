//
//  ImageCollectionManager.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoCollectionManager.h"
#import "EzJsonParser.h"
#import "GTMHTTPFetcher.h"
#import "PhotoCollectionRequest.h"
#import "NSString+Extensions.h"
#import "PhotoCollectionResponse.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "PhotoCollectionData.h"
#import "SurfRequestGenerator.h"
#import "ThreadsManager.h"




// 任务类型
@interface PCFetchingTask : NSObject

@property(nonatomic,strong) PhotoCollectionChannel *pcc;
//@property(nonatomic,strong) GTMHTTPFetcher* httpFecther;
//@property(nonatomic,strong,readonly) id threadsResp;
@end

@implementation PCFetchingTask


@end





@implementation PhotoCollectionManager
@synthesize photoCollecChannelList = _pcChannelList;

+ (PhotoCollectionManager*)sharedInstance
{
    static PhotoCollectionManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PhotoCollectionManager alloc] init];
    });
    return sharedInstance;
}


// 请求图集频道列表
- (void)refreshPhotoCollectionChannelList:(void (^)(BOOL succeeded, BOOL noChanges))handle
{    
    NSURLRequest *request = [SurfRequestGenerator photoCollectionChannelList];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
    {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        
        BOOL result = NO ,isChanged = NO;
        if (!error) {
            NSStringEncoding encoding = [[[fetcher response] textEncodingName] convertToStringEncoding];
            NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
            PhotoCollectionListResponse* resp;
            resp = [EzJsonParser deserializeFromJson:body AsType:[PhotoCollectionListResponse class]];
            
            if (resp && resp.item.count > 0) {
                // 排序
                NSArray *sortChannelCollection;
                sortChannelCollection = [resp.item sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                {                    
                    PhotoCollectionChannel* t1 = (PhotoCollectionChannel*)obj1;
                    PhotoCollectionChannel* t2 = (PhotoCollectionChannel*)obj2;
                    return (t1.index <= t2.index) ? NSOrderedAscending : NSOrderedDescending;
                }];

                
                // 过滤掉不存在的图集频道并删除它的资源
                [self filterNotExistPCChannels:sortChannelCollection];
                
                // 创建新增加的图集频道目录
                for (int i = 0; i < sortChannelCollection.count; ++i) {
                    PhotoCollectionChannel* newInfo = sortChannelCollection[i];
                    PhotoCollectionChannel* oldInfo = [self findPCChannelWithId:newInfo.cid inArray:_pcChannelList];                    
                    
                    // 所有新来的数据都覆盖本地数据，避免里面的属性值发生改变。                    
                    NSString* channelDir = [PathUtil pathOfPhotoCollectionChannel:newInfo];
                    if (![[NSFileManager defaultManager] fileExistsAtPath:channelDir]) {
                        // 创建新增加的图集频道目录
                        [[NSFileManager defaultManager] createDirectoryAtPath:channelDir
                                                  withIntermediateDirectories:YES attributes:nil error:nil];
                        
                        // 创建频道的临时文件夹
                        NSString *tempFileDir = [PathUtil pathOfPhotoCollectionTempFolderWithId:newInfo.cid];
                        [[NSFileManager defaultManager] createDirectoryAtPath:tempFileDir
                                                  withIntermediateDirectories:YES attributes:nil error:nil];
                    }
                    
                    // 保存本地属性
                    NSNumber *numKey = [NSNumber numberWithUnsignedLong:newInfo.cid];
                    PCCLocalInfo *localInfo = [_pccLocalDict objectForKey:numKey];
                    if (localInfo == nil) {
                        localInfo = [[PCCLocalInfo alloc] initWithPCChannel:newInfo];
                        [_pccLocalDict setObject:localInfo forKey:numKey];
                    }
                    [localInfo saveToFile]; // 保存到文件中
                    
                    
                    // 添加到图集频道列表中
                    if(oldInfo == nil)
                    {
                        isChanged = YES;                        
                        [_pcChannelList addObject:newInfo];// 新来的就添加到最后面
                    }
                }
                
              
                
                // 图集频道列表发生改变，覆盖掉本地文件。
                if (isChanged) {
                    // 保存图集列表信息
                    NSString *infoTxt = [PathUtil pathOfPhotoCollectionChannelListInfo];
                    [body writeToFile:infoTxt atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    
                    // 保存图集频道顺序
                    NSArray *copyArray = [NSArray arrayWithArray:_pcChannelList];
                    [self changePhotoCollectionChannelListOrder:copyArray];
                }

                result = YES;
            }
        }
        
        // 通知图集列表刷新完成
        if (handle) {
            handle (result, isChanged);
        }
    }];
    
}


// 改变图集列表的顺序
- (BOOL)changePhotoCollectionChannelListOrder:(NSArray*)orderArray{
    if (orderArray.count == 0 || orderArray.count != _pcChannelList.count)
        return NO;
    
    NSString *sortPath = [PathUtil pathOfPhotoCollectionChannelSortInfo];
    NSMutableArray *sortArray = [NSMutableArray arrayWithCapacity:orderArray.count];
    for (PhotoCollectionChannel *pcc in orderArray) {
        if ([pcc isKindOfClass:[PhotoCollectionChannel class]]) {
            [sortArray addObject:[[NSNumber alloc] initWithUnsignedLong:pcc.cid]];
        }
    }
    
    if (sortArray.count > 0) {
        NSString *sortContent = [EzJsonParser serializeObjectWithUtf8Encoding:sortArray];
        [sortContent writeToFile:sortPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [sortArray removeAllObjects];
        
        // 改变图集列表顺序
        [_pcChannelList removeAllObjects];
        [_pcChannelList addObjectsFromArray:orderArray];
        return YES;
    }
    return NO;
}


// 刷新图集列表
- (void)refreshPhotoCollectionList:(PhotoCollectionChannel*)pcChannel
             withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler{
    if (pcChannel == nil) {
        if (handler) {            
            dispatch_async(dispatch_get_main_queue(), ^{
                ThreadsFetchingResult *result = [ThreadsFetchingResult new];
                handler(result);
            });
        }
        return;
    }
    
    // 这个任务在请求，就不做任何处理
    if ([self isExistTask:pcChannel]) {
        return;
    }
    
    PCFetchingTask *task = [PCFetchingTask new];
    task.pcc = pcChannel;
    [_fetchingTasks addObject:task];
    
    // 刷新图片列表
    NSURLRequest *request = [SurfRequestGenerator photoCollectionList:pcChannel];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error){
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        ThreadsFetchingResult *result = [ThreadsFetchingResult new];
        result.noChanges = YES;
        result.channelId = pcChannel.cid;
        
        if (!error) {
            NSStringEncoding encoding = [[[fetcher response] textEncodingName] convertToStringEncoding];
            NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
            PhotoCollectionResponse* resp;
            resp = [EzJsonParser deserializeFromJson:body AsType:[PhotoCollectionResponse class]];
            
             
            if ([resp.res.reCode intValue] == 1 && resp.news.count) {
                u_long pccId = pcChannel.cid;                
                NSNumber *numKey = [NSNumber numberWithUnsignedLong:pccId];
                [_pccPageNumDict setObject:[NSNumber numberWithInt:1]
                                                       forKey:numKey];
                
                
                //更新刷新时间
                PCCLocalInfo *localInfo = [_pccLocalDict objectForKey:numKey];
                if (localInfo) {
                    localInfo.refreshTimeInterval = [[NSDate date] timeIntervalSince1970];
                    [localInfo saveToFile];
                }
                else{
                    localInfo = [[PCCLocalInfo alloc] initWithPCChannel:pcChannel];
                    localInfo.refreshTimeInterval = [[NSDate date] timeIntervalSince1970];
                    [localInfo saveToFile];
                }
                [_pccLocalDict setObject:localInfo forKey:numKey];
                
                // 删除失效的本地缓存帖子
                NSMutableArray* localPCList = [self getCachedOfPhotoCollectionList:pccId];
                for (int i = 0; i < [localPCList count]; i++)
                {
                    PhotoCollection* oldPcc = localPCList[i];
                    PhotoCollection* newPcc = [self findPCWithId:oldPcc.pcId inArray:resp.news];
                    
                    if (newPcc == nil) {
                        // 说明图集列表不存在了,需要图集数据
                        [self deleteRelatedDataOfPC:oldPcc];
                        [localPCList removeObject:oldPcc];
                        i--;
                    }
                }
                
                
                [localPCList removeAllObjects];
                [localPCList addObjectsFromArray:resp.news];
                [localPCList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    if ([obj isKindOfClass:[PhotoCollection class]]) {
                        NSString *pcDir = [PathUtil pathOfPhotoCollection:obj];     
                        [[NSFileManager defaultManager] createDirectoryAtPath:pcDir
                                                  withIntermediateDirectories:YES
                                                                   attributes:nil
                                                                        error:nil];
                        
                        // 保存图集到本地文件中
                        NSString *content = [EzJsonParser serializeObjectWithUtf8Encoding:obj];
                        NSString *infoPath = [PathUtil pathOfPhotoCollectionInfo:obj];
                        [content writeToFile:infoPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    }
                }];
                
                result.noChanges = NO;
                result.succeeded = YES;
                result.threads = localPCList;
                if (localPCList) {
                    [_photoCollectionListCache setObject:localPCList forKey:numKey]; // 替换缓存中的数据
                }
            }
        }
        
        // 删除任务
        [_fetchingTasks removeObject:task];
        
        if (handler) {
            handler(result);
        }
    }];
}

- (void)getMorePhotoCollectionList:(PhotoCollectionChannel*)pcChannel
             withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler
{
    if (pcChannel == nil) {
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ThreadsFetchingResult *result = [ThreadsFetchingResult new];
                handler(result);
            });
        }
        return;
    }
    
    
    // 如果任务存在，就不能继续请求
    if ([self isExistTask:pcChannel]) {
        return;
    }
    
    PCFetchingTask *task = [PCFetchingTask new];
    task.pcc = pcChannel;
    [_fetchingTasks addObject:task];
    
    
    // 加载更多图片列表    
    NSNumber* curPageNo = [_pccPageNumDict objectForKey:[NSNumber numberWithUnsignedLong:pcChannel.cid]];
    if(!curPageNo){
        curPageNo = [NSNumber numberWithInt:1]; // 从未刷新成功过，认为此次加载更多操作是从第2页开始加载
        [_pccPageNumDict setObject:curPageNo forKey:[NSNumber numberWithUnsignedLong:pcChannel.cid]];
    }

    NSURLRequest *request = [SurfRequestGenerator getMorephotoCollectionList:pcChannel page:[curPageNo intValue] + 1];
    GTMHTTPFetcher* fecther = [GTMHTTPFetcher fetcherWithRequest:request];
    [fecther beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
    {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        ThreadsFetchingResult *result = [ThreadsFetchingResult new];
        result.noChanges = YES;
        result.channelId = pcChannel.cid;
        
        if (!error) {
            
            NSStringEncoding encoding = [[[fecther response] textEncodingName] convertToStringEncoding];
            NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
            PhotoCollectionResponse* resp;
            resp = [EzJsonParser deserializeFromJson:body AsType:[PhotoCollectionResponse class]];
            
            result.succeeded = [resp.res.reCode intValue] == 1 ? YES : NO;
            if (resp.news.count) {
                //更新该热推频道的当前帖子页码
                NSNumber* curPageNo = [_pccPageNumDict objectForKey:[NSNumber numberWithLong:pcChannel.cid]];
                [_pccPageNumDict setObject:[NSNumber numberWithInt:[curPageNo intValue] + 1]
                                    forKey:[NSNumber numberWithLong:pcChannel.cid]];
                
                // 加载更多刷新时间
                NSNumber *numKey = [NSNumber numberWithUnsignedLong:pcChannel.cid];
                PCCLocalInfo *localInfo = [_pccLocalDict objectForKey:numKey];
                if (localInfo) {
                    localInfo.getMoreTimeInterval = [[NSDate date] timeIntervalSince1970];
                    [localInfo saveToFile];
                }
                else{
                    localInfo = [[PCCLocalInfo alloc] initWithPCChannel:pcChannel];
                    localInfo.getMoreTimeInterval = [[NSDate date] timeIntervalSince1970];
                    [localInfo saveToFile];                    
                }
                [_pccLocalDict setObject:localInfo forKey:numKey];
                
                
                NSMutableArray* photoCollectionActuallyAdded = [NSMutableArray new];
                NSMutableArray* photoCollectionCache =  [self getCachedOfPhotoCollectionList:pcChannel.cid];
                
                //存储帖子缓存
                for(PhotoCollection* pc in resp.news){
                    //假如帖子重复存在，则跳过                    
                    if ([self isDuplicatedPhotoCollectionExist:pc inArray:photoCollectionCache])
                        continue;
                    
                    pc.isTempData = YES;
                    result.noChanges = NO;
                    [photoCollectionActuallyAdded addObject:pc];
                    [photoCollectionCache addObject:pc];
                }
                result.threads = photoCollectionActuallyAdded;            
            }
        }
        
        // 删除这个请求任务
        [_fetchingTasks removeObject:task];
        // 通知请求完成
        if (handler) { handler(result); }
      
    }];        
}

// 获取图集频道的刷新时间
- (NSDate*)lastRefreshDateOfPhotoCollectionChannel:(PhotoCollectionChannel*)pcc
{    
    PCCLocalInfo *localInfo = [_pccLocalDict objectForKey:[NSNumber numberWithUnsignedLong:pcc.cid]];
    if (localInfo && localInfo.refreshTimeInterval > 0) {
        return [NSDate dateWithTimeIntervalSince1970:localInfo.refreshTimeInterval];
    }
    return nil;
}
// 获取最后加载更多请求时间
- (NSDate*)lastMoreDateOfPhotoCollectionChannel:(PhotoCollectionChannel*)pcc
{
    PCCLocalInfo *localInfo = [_pccLocalDict objectForKey:[NSNumber numberWithUnsignedLong:pcc.cid]];
    if (localInfo && localInfo.refreshTimeInterval > 0) {
        return [NSDate dateWithTimeIntervalSince1970:localInfo.getMoreTimeInterval];
    }
    return nil;
}

// 加载图集列表
-(NSArray*)loadLocalPhotoCollectionListForPCC:(PhotoCollectionChannel*)pcc
{
    NSMutableArray* cached =  [self getCachedOfPhotoCollectionList:pcc.cid];
    if(cached){
        return cached;
    }
    
    // 不存在，就从本地数据中加载
    cached = [NSMutableArray new];
    
    //从文件载入
    NSArray* dirs = [FileUtil getSubdirNamesOfDir:[PathUtil pathOfPhotoCollectionChannel:pcc]];
    for (NSString* pcidStr in dirs)
    {
        u_long pcId = [pcidStr integerValue];
        NSString *infoPath = [PathUtil pathOfPhotoCollectionInfoWithId:pcc.cid photoCollectionId:pcId];
        NSString *content = [NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
        PhotoCollection *photoColl = [EzJsonParser deserializeFromJson:content AsType:[PhotoCollection class]];
        
        
        //删除无效帖子数据
        //尽管代码中找不出为何会出这种状况，但实际使用中
        //还是会发现有这种现象。
        if (!photoColl || photoColl.pcId == 0)
        {
            NSString* threadDir = [infoPath stringByDeletingLastPathComponent];
            [FileUtil deleteDirAndContents:threadDir];
        }
        else
        {
            [cached addObject:photoColl];
        }
    }

    NSNumber *numKey = [NSNumber numberWithUnsignedLong:pcc.cid];
    [_photoCollectionListCache setObject:cached forKey:numKey];
    return cached;
}

// 通过图集频道id获取图集频道
- (PhotoCollectionChannel*)getPhotoCollectionChannelWithId:(u_long)ppcId
{
    for (PhotoCollectionChannel* pcc in _pcChannelList) {
        if (pcc.cid == ppcId) {
            return pcc;
        }
    }
    return nil;
}

// 获取本地的图集的图片信息列表，没有就返回nil;
-(NSArray*)getPhotoInfoListWithPhotoCollection:(PhotoCollection *)pc
{
    if (pc == nil) {
        return nil;
    }
    
    NSNumber *key = [NSNumber numberWithUnsignedLong:pc.pcId];
    NSArray *photoList = [_pcpListCache objectForKey:key];
    if (photoList == nil) {        
        // 获取本地缓存
        NSString *contentPath = [PathUtil pathOfPhotoCollectionContentInfo:pc];
        if ([FileUtil fileExists:contentPath]) {
            PhotoCollectionContentResponse *resp;
            NSString *fileContent = [NSString stringWithContentsOfFile:contentPath
                                                              encoding:NSUTF8StringEncoding error:nil];
            resp = [EzJsonParser deserializeFromJson:fileContent AsType:[PhotoCollectionContentResponse class]];
            if (resp != nil && resp.item != nil && resp.item.count > 0) {            
                photoList = resp.item;
                [_pcpListCache setObject:resp.item forKey:key];
            }
        }
    }
    return photoList;
}


// 获取图集内容
- (void)requestPhotoCollectionContent:(PhotoCollection*)pc
            withCompletionHandler:(void(^)(ThreadsFetchingResult*))handler
{
    if (!pc)  return;
    
    NSURLRequest *request = [SurfRequestGenerator photoCollectionContent:pc];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
    {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        
        ThreadsFetchingResult *tfr = [ThreadsFetchingResult new];
        tfr.noChanges = YES;
        tfr.channelId = pc.pcId;
        if (!error) {
            NSStringEncoding encoding = [[[fetcher response] textEncodingName] convertToStringEncoding];
            NSString* body = [[NSString alloc] initWithData:data encoding:encoding];
            PhotoCollectionContentResponse* resp;
            resp = [EzJsonParser deserializeFromJson:body AsType:[PhotoCollectionContentResponse class]];
            
            if (resp.item.count > 0) {
                tfr.succeeded = YES;
                tfr.noChanges = NO;
                tfr.threads = resp.item;
                [_pcpListCache setObject:resp.item forKey:[NSNumber numberWithUnsignedLong:pc.pcId]];
                
                
                // 保存到本地文件中,程序跑到这里，逻辑上来说已经建立好目录了，除非Bug
                // 2014.9.3 这里有可能没有目录，原因是如果来自“热推新闻”跳转过来，
                // 接口中只有图集ID没有图集频道ID，路径就会有问题,
                // 调试发现，图片信息会带图集频道ID，就用这个来创建目录。
                if (pc.coid == 0) {
                    [resp.item enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop )
                    {
                        // 从新闻频道跳转过来的图集，图片信息保存到临时文件夹中。
                        ((PhotoData*)obj).isCacheData = YES;
                    }];
                    
                    PhotoData *pd = [resp.item lastObject];
                    NSString *imgPath = [PathUtil pathOfPhotoDataImage:pd];
                    [FileUtil ensureSuperPathExists:imgPath];                    
                    if (pd.cover_id == pc.pcId) {
                        pc.coid = pd.coid;
                    }
                }
              
                
                NSString *path = [PathUtil pathOfPhotoCollectionContentInfo:pc];
                [body writeToFile:path atomically:YES
                         encoding:NSUTF8StringEncoding
                            error:nil];
   
             
            }
        }
         
        if (handler) {
            handler(tfr);
        }
    }];
}

// 图集列表正在加载
- (BOOL)photoCollectionListIsLoading:(PhotoCollectionChannel*)pcc{
    return [self isExistTask:pcc];
}

#pragma mark private method
- (id)init
{
    if (self = [super init]) {
        
        _pccLocalDict = [NSMutableDictionary new];
        _pccPageNumDict = [NSMutableDictionary new];
        _photoCollectionListCache = [NSMutableDictionary new];
        _pcpListCache = [NSMutableDictionary new];
        _pcChannelList = [NSMutableArray arrayWithCapacity:10];
        NSMutableArray *pcchannelSource = [NSMutableArray arrayWithCapacity:10];
        
        // 加载本地图集频道列表
        PhotoCollectionListResponse* resp = nil;
        NSString *infoTxt = [PathUtil pathOfPhotoCollectionChannelListInfo];
        if ([FileUtil fileExists:infoTxt]) {
            NSString *fileContent = [NSString stringWithContentsOfFile:infoTxt encoding:NSUTF8StringEncoding error:nil];
            resp = [EzJsonParser deserializeFromJson:fileContent AsType:[PhotoCollectionListResponse class]];
            NSArray *array = [resp.item sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                PhotoCollectionChannel *pcc1 = (PhotoCollectionChannel*)obj1;
                PhotoCollectionChannel *pcc2 = (PhotoCollectionChannel*)obj2;
                return (pcc1.index <= pcc2.index) ? NSOrderedAscending : NSOrderedDescending;
            }];
            
            if (array.count > 0) {
                [pcchannelSource addObjectsFromArray:array];
            }
        }
        
        // 对图集频道进行排序操作
        if (pcchannelSource.count > 0) {
            NSMutableArray *sortArray = nil;
            NSString *sortPath = [PathUtil pathOfPhotoCollectionChannelSortInfo];
            if ([FileUtil fileExists:sortPath]) {
                NSString *sortContent = [NSString stringWithContentsOfFile:sortPath encoding:NSUTF8StringEncoding error:nil];
                sortArray = [EzJsonParser deserializeFromJson:sortContent AsType:[NSMutableArray class]];
            }

            // 排序操作
            if (sortArray && sortArray.count > 0)
            {
                for (NSNumber *num in sortArray)
                {
                    u_long cid = [num unsignedLongValue];
                    for (PhotoCollectionChannel *pcc in pcchannelSource) {
                        if (pcc.cid == cid) {
                            [_pcChannelList addObject:pcc];
                            break;
                        }
                    }
                }
                // 对不在排序队列中的频道加到最后面
                [pcchannelSource removeObjectsInArray:_pcChannelList];
                if (pcchannelSource.count > 0) {
                    [pcchannelSource sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        PhotoCollectionChannel *pcc1 = obj1;
                        PhotoCollectionChannel *pcc2 = obj2;
                        return pcc1.index <= pcc2.index ? NSOrderedAscending : NSOrderedDescending;
                    }];
                    
                    [_pcChannelList addObjectsFromArray:pcchannelSource];
                }
            }
            else{
                [_pcChannelList addObjectsFromArray:pcchannelSource];
            }
            
            
            // 加载图集频道的永久数据
            for (PhotoCollectionChannel *pcc in _pcChannelList) {
                PCCLocalInfo *localInfo = [[PCCLocalInfo alloc] initWithPCChannel:pcc];
                [localInfo loadDateFromFile];                
                NSNumber *numKey = [NSNumber numberWithUnsignedLong:pcc.cid];
                [_pccLocalDict setObject:localInfo forKey:numKey];
            }
            
            
            // 删除临时文件夹中的文件
            for (PhotoCollectionChannel *pcc in _pcChannelList) {
                NSString *tempFileDir = [PathUtil pathOfPhotoCollectionTempFolderWithId:pcc.cid];
                if ([FileUtil dirExists:tempFileDir]) {
                    [FileUtil deleteContentsOfDir:tempFileDir];
                }
            }
            
        }
    }
    return self;
}


// 过滤掉不存在的图集频道并删除它的资源
- (void)filterNotExistPCChannels:(NSArray*)newPCChannels
{
    for(int i = 0; i < _pcChannelList.count; i++)
    {
        PhotoCollectionChannel* oldInfo = _pcChannelList[i];
        PhotoCollectionChannel* newInfo = [self findPCChannelWithId:oldInfo.cid inArray:newPCChannels];
        if (newInfo == nil)
        {
            --i;
            // 找不到，说明这个图集频道在新的图集频道中已经删除
            [_pcChannelList removeObject:oldInfo];
            
            //删除该图集频道的所有本地数据
            [FileUtil deleteDirAndContents:[PathUtil pathOfPhotoCollectionChannel:oldInfo]];            
        }
    }
}

// 从数组中找到图集频道
- (PhotoCollectionChannel*)findPCChannelWithId:(u_long)cid inArray:(NSArray*)array
{
    for (PhotoCollectionChannel* ch in array)
    {
        if(ch.cid == cid)
            return ch;
    }
    return nil;
}

// 从数组中找到图集
- (PhotoCollection*)findPCWithId:(u_long)pcid inArray:(NSArray*)array
{
    for (PhotoCollection* ch in array)
    {
        if(ch.pcId == pcid)
            return ch;
    }
    return nil;
}
//删除图集所属的所有数据
-(void)deleteRelatedDataOfPC:(PhotoCollection *)pc
{
    NSString* pcDir = [PathUtil pathOfPhotoCollection:pc];
    [FileUtil deleteDirAndContents:pcDir];
}

// 获取图集频道的缓存数据
-(NSMutableArray*)getCachedOfPhotoCollectionList:(u_long)pccid
{
    return [_photoCollectionListCache objectForKey:[NSNumber numberWithUnsignedLong:pccid]];
}

// 图集列表排序
//- (void)sortPhotoCollectionList:(NSMutableArray*)pcList {
//    // 图集按热点排序
//    [pcList sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        PhotoCollection *pc1 = obj1;
//        PhotoCollection *pc2 = obj2;
//        if(pc1.isTop == pc2.isTop) {
//            return pc2.time < pc2.time ? NSOrderedDescending : NSOrderedAscending;
//        }
//        else if (pc1.isTop) {
//            return NSOrderedAscending;
//        }
//        return NSOrderedDescending;
//    }];
//}

// 是否存在相同的图集
- (Boolean)isDuplicatedPhotoCollectionExist:(PhotoCollection*)pc inArray:(NSArray*)PhotoCollectionArray
{
    for (PhotoCollection* t in PhotoCollectionArray)
    {
        if(t.pcId == pc.pcId || [t.title isEqualToString:pc.title])
            return YES;
    }
    return NO;
}

// 是否存在这样的任务
-(BOOL)isExistTask:(PhotoCollectionChannel*)pcc{
    for (PCFetchingTask *task in _fetchingTasks) {
        if (task.pcc.cid == pcc.cid) {
            return YES;
        }
    }
    return NO;
}
@end
