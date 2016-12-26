//
//  MagazineManager.m
//  SurfNewsHD
//
//  Created by SYZ on 13-5-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "MagazineManager.h"
#import "GTMHTTPFetcher.h"
#import "GetMagazineSubsResponse.h"
#import "GetPeriodicalListResponse.h"
#import "GetMagazineListResponse.h"
#import "NSString+Extensions.h"
#import "EzJsonParser.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "UserManager.h"

#import "XmlResolve.h"

@interface PeriodicalFetchingTask : NSObject

@property(nonatomic,strong) GTMHTTPFetcher* httpFecther;
@property BOOL isContentInfo;    //YES-for ContentInfo;NO-for LinkInfo
//期刊索引页
@property(nonatomic,strong) PeriodicalInfo* contentInfo;
@property(nonatomic,strong) void(^completionHandler)(BOOL, PeriodicalHtmlResolvingResult*);
//期刊正文
@property(nonatomic,strong) PeriodicalLinkInfo*linkInfo;
@property(nonatomic,strong) void(^linkCompletionHandler)(BOOL, PeriodicalHtmlResolvingResult*);

@end

@implementation PeriodicalFetchingTask
@end

//******************************************************************************

@implementation MagazinesSortInfo

@end

//******************************************************************************

@interface PeriodicalServerTime : NSObject

@property long long serverTime;

@end

@implementation PeriodicalServerTime

@end

//******************************************************************************

@implementation MagazineManager(private)

- (id)init
{
    if(self = [super init]) {
        observers = [NSMutableArray new];
        subsMagazines = [NSMutableArray new];
        wapVisiableMagazines = [NSMutableArray new];
        fetchingTasks_ = [NSMutableArray new];
        
        UserManager *um = [UserManager sharedInstance];
        [um addUserLoginObserver:self];
    }
    return self;
}

//请求下来的数据包括订阅的栏目和期刊,要过滤订阅的期刊rssType = 6
- (void)filterMagazins:(NSArray*)array
{
    [subsMagazines removeAllObjects];
    
    for (MagazineSubsInfo *magazine in array) {
        if (magazine.rssType == 6) {
            [subsMagazines addObject:magazine];
        }
    }
}

//用id查找magazine
- (MagazineSubsInfo*)getMagazineWithId:(long)magazineId
{
    for (MagazineSubsInfo *ma in subsMagazines) {
        if(ma.magazineId == magazineId)
            return ma;
    }
    return nil;
}

//用id找出magazine
- (MagazineSubsInfo*)getMagazineWithSameId:(MagazineSubsInfo*)magazine inArray:(NSArray*)array
{
    for (MagazineSubsInfo *ma in array) {
        if(ma.magazineId == magazine.magazineId)
            return ma;
    }
    return nil;
}

//用id找出periodical
- (PeriodicalInfo*)getPeriodicalWithSameId:(PeriodicalInfo*)periodical inArray:(NSArray*)array
{
    for (PeriodicalInfo *pe in array) {
        if(pe.periodicalId == periodical.periodicalId)
            return pe;
    }
    return nil;
}

//用id找出periodical是否有更新
- (BOOL)getUpdatePeriodicalWithSameId:(UpdatePeriodicalInfo*)periodical
{
    for (MagazineSubsInfo *m in subsMagazines) {
        if(m.magazineId == periodical.magazineId) {
            if (m.lastUpdatePeriodicalInfo &&
                m.lastUpdatePeriodicalInfo.lastPeriodLongDate == periodical.lastPeriodLongDate &&
                m.lastUpdatePeriodicalInfo.periods.count == periodical.periods.count) {
                return NO;
            } else {
                //更新期刊数据
                [[EzJsonParser serializeObjectWithUtf8Encoding:periodical] writeToFile:[PathUtil pathOfUpdatePeriodicalInfo:periodical] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                m.lastUpdatePeriodicalInfo = periodical;
                return YES;
            }
        }
    }
    return YES;
}

//加载本地期刊订阅缓存
- (void)loadLocalMagazinesSortInfo
{
    UserInfo *info = [UserManager sharedInstance].loginedUser;
    if (info) {
        //已登录用户
        MagazinesSortInfo* sortInfo;
        NSString *path = [PathUtil pathOfUserMagazineSortInfo:info.userID];
        if (path) { //和以前版本兼容，讲订阅关系整合到userinfo里
            NSString *json = [NSString stringWithContentsOfFile:path
                                                       encoding:NSUTF8StringEncoding
                                                          error:nil];
            sortInfo = [EzJsonParser deserializeFromJson:json
                                                  AsType:[MagazinesSortInfo class]];
            info.magazinesSortInfo = sortInfo;
            
            [[EzJsonParser serializeObjectWithUtf8Encoding:info] writeToFile:[PathUtil pathOfUserInfo]
                                                                          atomically:YES encoding:NSUTF8StringEncoding
                                                                               error:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[PathUtil pathOfUserMagazineSortInfo:info.userID] error:nil];
        } else {
            sortInfo = info.magazinesSortInfo;
        }
        
        [subsMagazines removeAllObjects];
        
        for (NSNumber* mid in sortInfo.magazineIdsArray) {
            MagazineSubsInfo *magazine = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfMagazineInfoWithMagazineId:[mid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[MagazineSubsInfo class]];
            if (magazine == nil) {
                continue;
            }
            for (NSString *pid in [FileUtil getSubdirNamesOfDir:[PathUtil pathOfMagazineId:[mid longValue]]]) {
                PeriodicalInfo *info = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfPeriodicalInfoWithPeriodicalId:[pid integerValue] inMagazineId:[mid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[PeriodicalInfo class]];
                if (info) {
                    [magazine.periodicalArray addObject:info];
                }
            }
            
            //降序排列,最新的排在最前面
            [magazine.periodicalArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                PeriodicalInfo* t1 = (PeriodicalInfo*)obj1;
                PeriodicalInfo* t2 = (PeriodicalInfo*)obj2;
                if(t1.periodicalId <= t2.periodicalId) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            
            [subsMagazines addObject:magazine];
        }
    } else {
        [wapVisiableMagazines removeAllObjects];
        
        //游客用户展示
        MagazinesSortInfo* sortInfo = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfMagazineSortInfo] encoding:NSUTF8StringEncoding error:nil] AsType:[MagazinesSortInfo class]];
        [subsMagazines removeAllObjects];
        
        for (NSNumber* mid in sortInfo.magazineIdsArray) {
            MagazineSubsInfo* magazine = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfMagazineInfoWithMagazineId:[mid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[MagazineSubsInfo class]];
            if (magazine == nil) {
                continue;
            }
            [magazine.periodicalArray removeAllObjects];
            for (NSString *pid in [FileUtil getSubdirNamesOfDir:[PathUtil pathOfMagazineId:[mid longValue]]])
            {
                PeriodicalInfo *info = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfPeriodicalInfoWithPeriodicalId:[pid integerValue] inMagazineId:[mid longValue]] encoding:NSUTF8StringEncoding error:nil] AsType:[PeriodicalInfo class]];
                if (info) {
                    [magazine.periodicalArray addObject:info];
                }
            }
            
            //降序排列,最新的排在最前面
            [magazine.periodicalArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                PeriodicalInfo* t1 = (PeriodicalInfo*)obj1;
                PeriodicalInfo* t2 = (PeriodicalInfo*)obj2;
                if(t1.periodicalId <= t2.periodicalId) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            
            magazine.refreshPeridical = YES;  //要刷新期刊下面的每期列表
            [subsMagazines addObject:magazine];
        }
    }
}

@end


@implementation MagazineManager

#define DEFAULT_SERVERTIME         -1

@synthesize subsMagazines;
@synthesize wapVisiableMagazines;

+ (MagazineManager*)sharedInstance
{
    static MagazineManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MagazineManager alloc] init];
    });
    
    return sharedInstance;
}

//检测某个期刊是否被订阅
- (BOOL)isMagazineSubscribed:(long)magazineId
{
    for (MagazineSubsInfo *magazine in subsMagazines) {
        if(magazine.magazineId == magazineId)
            return YES;
    }
    return NO;
}

//返回期刊
- (MagazineSubsInfo *)getMagazineWithMagazineId:(long)magazineId
{
    for (MagazineSubsInfo *magazine in subsMagazines) {
        if(magazine.magazineId == magazineId)
            return magazine;
    }
    return nil;
}

//查询期刊的介绍
- (NSString *)getMagazineDescWithMagazineId:(long)magazineId
{
    for (MagazineSubsInfo *magazine in subsMagazines) {
        if(magazine.magazineId == magazineId)
            return magazine.desc;
    }
    return nil;
}

//返回期刊下标
- (NSInteger)getMagazineIndexWithMagazineId:(long)magazineId
{
    for (NSInteger i = 0; i < subsMagazines.count; i++) {
        MagazineSubsInfo *magazine = subsMagazines[i];
        if(magazine.magazineId == magazineId) {
            return i;
        }
    }
    return NSNotFound;
}

//载入本地订阅关系
- (NSArray*)loadLocalMagazineSubs
{
    return subsMagazines;
}

//返回更新期刊列表的时间
- (NSDate*)lastDateOfMagazineUpdate
{
    return updateMagazineLastDate;
}

//完全覆盖本地的期刊订阅关系
- (void)overwriteLocalMagazines:(GetMagazineSubsResponse*)resp
{
    if (!resp) {
        [self handleMagazinesResorted];
        return;
    }
    
    [subsMagazines removeAllObjects];
//    //将已失效的期刊干掉
//    for (NSInteger i = 0; i < [subsMagazines count]; i++) {
//        MagazineSubsInfo* magazineSubs = subsMagazines[i];
//        if (![self getMagazineWithSameId:magazineSubs inArray:resp.item]) {
//            [subsMagazines removeObject:magazineSubs];
//            i--;
//        }
//    }
    //将新增的期刊保存到本地
    for(MagazineSubsInfo* magazineSubs in resp.item) {
        if (magazineSubs.rssType != 6) {  //先判断订阅的是栏目还是期刊, 1为栏目, 6为期刊
            continue;
        }
        
        //是否在客户端显示
        if (magazineSubs.isVisible == 1) {
            if([wapVisiableMagazines containsObject:magazineSubs]) {
                continue;
            }
            [wapVisiableMagazines addObject:magazineSubs];
            continue;
        }
        
//        if ([self getMagazineWithSameId:magazineSubs inArray:subsMagazines]) {
//            //更新期刊info.txt,因为MagazinInfo和MagazineSubsInfo不一样
//            [[EzJsonParser serializeObjectWithUtf8Encoding:magazineSubs] writeToFile:[PathUtil pathOfMagazineInfo:magazineSubs] atomically:YES encoding:NSUTF8StringEncoding error:nil];
//            continue;
//        }
        
        NSURL* url = [NSURL URLWithString:magazineSubs.imageUrl relativeToURL:[NSURL URLWithString:resp.apicPass]];
        magazineSubs.imageUrl = url.absoluteString;
        [[NSFileManager defaultManager] createDirectoryAtPath:[PathUtil pathOfMagazine:magazineSubs] withIntermediateDirectories:YES attributes:nil error:nil];
        [[EzJsonParser serializeObjectWithUtf8Encoding:magazineSubs] writeToFile:[PathUtil pathOfMagazineInfo:magazineSubs] atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
        magazineSubs.refreshPeridical = YES; //要刷新期刊下面的每期列表
        [subsMagazines addObject:magazineSubs];
    }
    
    for (MagazineSubsInfo *magazine in subsMagazines) {
        [magazine.periodicalArray removeAllObjects];
        
        for (NSString *pid in [FileUtil getSubdirNamesOfDir:[PathUtil pathOfMagazineId:magazine.magazineId]]) {
            PeriodicalInfo *info = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfPeriodicalInfoWithPeriodicalId:[pid integerValue] inMagazineId:magazine.magazineId] encoding:NSUTF8StringEncoding error:nil] AsType:[PeriodicalInfo class]];
            if (info) {
                [magazine.periodicalArray addObject:info];
            }
        }
        
        //降序排列,最新的排在最前面
        [magazine.periodicalArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            PeriodicalInfo* t1 = (PeriodicalInfo*)obj1;
            PeriodicalInfo* t2 = (PeriodicalInfo*)obj2;
            if(t1.periodicalId <= t2.periodicalId) {
                return NSOrderedDescending;
            } else {
                return NSOrderedAscending;
            }
        }];
    }
    
    [self handleMagazinesResorted];
}

//保存期刊订阅信息
- (void)handleMagazinesResorted
{
    MagazinesSortInfo* sortInfo = [[MagazinesSortInfo alloc]init];
    sortInfo.magazineIdsArray = [NSMutableArray new];
    sortInfo.wapMagazineIdsArray = [NSMutableArray new];
    
    for (MagazineSubsInfo* magazineSubs in subsMagazines) {
        [sortInfo.magazineIdsArray addObject:[NSNumber numberWithLong:magazineSubs.magazineId]];
    }
    
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    if (userInfo) {
        for (MagazineSubsInfo* magazineSubs in wapVisiableMagazines) {
            [sortInfo.wapMagazineIdsArray addObject:[NSNumber numberWithLong:magazineSubs.magazineId]];
        }
        userInfo.magazinesSortInfo = sortInfo;
        [[UserManager sharedInstance] savePathOfUserInfo];
    } else {
        [[EzJsonParser serializeObjectWithUtf8Encoding:sortInfo] writeToFile:[PathUtil pathOfMagazineSortInfo] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    
    for (id<SubsMagazineChangedObserver> observer in observers) {
        [observer subsMagazineChanged];
    }
}

//期刊列表的下拉刷新,回调函数分别是请求是否成功和是否要刷新UI
- (void)refreshMagazinesWithCompletionHandler:(void (^)(BOOL, BOOL))handler
{
    updateMagazineLastDate = [NSDate date];
    
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    
    if (!userInfo) {
        //游客用户的订阅关系在本地,所以不涉及到下拉刷新数据的改变
        //刷新后也要重新加载每个订阅期刊的往期期刊列表
        for (MagazineSubsInfo *m in subsMagazines) {
            m.refreshPeridical = YES;
        }
        handler(YES, YES);
        return;
    } 
    
    id channelReq = [SurfRequestGenerator getMagazineSubsWithUserId:userInfo.userID];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:channelReq];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        if (!error) {
            BOOL changeUI = NO;
            //将服务器返回的订阅关系存在本地
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            
            //期刊订阅
            GetMagazineSubsResponse* magazineSubsList = [EzJsonParser deserializeFromJson:body AsType:[GetMagazineSubsResponse class]];
            if (magazineSubsList) {
                [wapVisiableMagazines removeAllObjects];
                [subsMagazines removeAllObjects];
//                //将已失效的期刊干掉
//                for (NSInteger i = 0; i < [subsMagazines count]; i++) {
//                    MagazineSubsInfo* magazineSubs = subsMagazines[i];
//                    if (![self getMagazineWithSameId:magazineSubs inArray:magazineSubsList.item]) {
//                        [subsMagazines removeObject:magazineSubs];
//                        i--;
//                        changeUI = YES;
//                    }
//                }
                //将新增的期刊保存到本地
                for(MagazineSubsInfo* magazineSubs in magazineSubsList.item) {
                    if (magazineSubs.rssType != 6) {  //先判断订阅的是栏目还是期刊, 1为栏目, 6为期刊
                        continue;
                    }
                    
                    //不在客户端显示的期刊
                    if (magazineSubs.isVisible == 1) {
                        if([wapVisiableMagazines containsObject:magazineSubs]) {
                            continue;
                        }
                        [wapVisiableMagazines addObject:magazineSubs];
                        continue;
                    }
                    
//                    if ([self getMagazineWithSameId:magazineSubs inArray:subsMagazines]) {
//                        //更新期刊info.txt,期刊名称可能有改变
//                        if (![[self getMagazineWithSameId:magazineSubs inArray:subsMagazines].name isEqualToString:magazineSubs.name]) {
//                            [[EzJsonParser serializeObjectWithUtf8Encoding:magazineSubs] writeToFile:[PathUtil pathOfMagazineInfo:magazineSubs] atomically:YES encoding:NSUTF8StringEncoding error:nil];
//                        }
//                        continue;
//                    }
                    
                    NSURL* url = [NSURL URLWithString:magazineSubs.imageUrl relativeToURL:[NSURL URLWithString:magazineSubsList.apicPass]];
                    magazineSubs.imageUrl = url.absoluteString;
                    [[NSFileManager defaultManager] createDirectoryAtPath:[PathUtil pathOfMagazine:magazineSubs] withIntermediateDirectories:YES attributes:nil error:nil];
                    [[EzJsonParser serializeObjectWithUtf8Encoding:magazineSubs] writeToFile:[PathUtil pathOfMagazineInfo:magazineSubs] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    
                    [magazineSubs.periodicalArray removeAllObjects];
                    for (NSString *pid in [FileUtil getSubdirNamesOfDir:[PathUtil pathOfMagazineId:magazineSubs.magazineId]]) {
                        PeriodicalInfo *info = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfPeriodicalInfoWithPeriodicalId:[pid integerValue] inMagazineId:magazineSubs.magazineId] encoding:NSUTF8StringEncoding error:nil] AsType:[PeriodicalInfo class]];
                        if (info) {
                            [magazineSubs.periodicalArray addObject:info];
                        }
                    }
                    
                    //降序排列,最新的排在最前面
                    [magazineSubs.periodicalArray sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                        PeriodicalInfo* t1 = (PeriodicalInfo*)obj1;
                        PeriodicalInfo* t2 = (PeriodicalInfo*)obj2;
                        if(t1.periodicalId <= t2.periodicalId) {
                            return NSOrderedDescending;
                        } else {
                            return NSOrderedAscending;
                        }
                    }];
                    
                    [subsMagazines addObject:magazineSubs];
                    changeUI = YES;
                }
                //刷新后也要重新加载每个订阅期刊的往期期刊列表
                for (MagazineSubsInfo *m in subsMagazines) {
                    m.refreshPeridical = YES;
                }
                [self handleMagazinesResorted];
                handler(YES, changeUI);
            } else {
                handler(NO, NO);
            }
        } else {
            //获取订阅列表失败,返回先有的期刊
            for (MagazineSubsInfo *m in subsMagazines) {
                m.refreshPeridical = YES;
            }
            handler(NO, NO);
        }
    }];
}

//使用magazineId请求该期刊的每期列表
- (void)refreshPeriodicalsWithMagazineId:(long)magazineId completionHandler:(void (^)(BOOL, BOOL, NSArray *))handler
{
    //获得上次请求返回的serverTime
    PeriodicalServerTime *oldPst = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfMagazineServerTime:magazineId] encoding:NSUTF8StringEncoding error:nil] AsType:[PeriodicalServerTime class]];
    long long serverTime = oldPst.serverTime;
    if (serverTime == 0) {
        serverTime = DEFAULT_SERVERTIME;  //首次请求时serverTime == -1
    }
    id req = [SurfRequestGenerator getPeriodicalListWithMagazineId:magazineId serverTime:serverTime];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data, NSError* error) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        
        BOOL changeUI = NO;
        //获取原有的期刊订阅文件夹
        NSString *rootPath = [PathUtil pathOfMagazineId:magazineId];
        NSArray *periodicalIds = [FileUtil getSubdirNamesOfDir:rootPath];
        NSMutableArray *periodicals = [NSMutableArray new];
        for (NSString *peid in periodicalIds) {
            PeriodicalInfo *pe = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfPeriodicalInfoWithPeriodicalId:[peid integerValue] inMagazineId:magazineId] encoding:NSUTF8StringEncoding error:nil] AsType:[PeriodicalInfo class]];
            if (pe) {
                [periodicals addObject:pe];
            }
        }
        
        if(!error) {
            NSString *body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            GetPeriodicalListResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[GetPeriodicalListResponse class]];
            
            if (resp.item != nil && resp.item.count > 0) {//服务器并发量大的时候会漏刊
                //保存服务器返回时间
                PeriodicalServerTime *pst = [PeriodicalServerTime new];
                pst.serverTime = resp.serverTime;
                [[EzJsonParser serializeObjectWithUtf8Encoding:pst] writeToFile:[PathUtil pathOfMagazineServerTime:magazineId] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                //新的期刊创建文件夹
                NSFileManager *fm = [NSFileManager defaultManager];
                for (PeriodicalInfo *pe in resp.item) {
                    if (serverTime != DEFAULT_SERVERTIME) {
                        pe.isNew = 1;
                    }
                    if ([self getPeriodicalWithSameId:pe inArray:periodicals]) {
                        PeriodicalInfo *p = [self getPeriodicalWithSameId:pe inArray:periodicals];
                        [periodicals removeObject:p];
                        //更新期刊数据
                        [[EzJsonParser serializeObjectWithUtf8Encoding:pe] writeToFile:[PathUtil pathOfPeriodicalInfo:pe] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                        [periodicals addObject:pe];
                        changeUI = YES;
                        continue;
                    }
                    NSString *periodicalDir = [PathUtil pathOfPeriodical:pe];
                    [fm createDirectoryAtPath:periodicalDir withIntermediateDirectories:YES attributes:nil error:nil];
                    [[EzJsonParser serializeObjectWithUtf8Encoding:pe] writeToFile:[PathUtil pathOfPeriodicalInfo:pe] atomically:YES encoding:NSUTF8StringEncoding error:nil];
                    [periodicals addObject:pe];
                    changeUI = YES;
                }
            }
            
            //降序排列,最新的排在最前面
            [periodicals sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                 PeriodicalInfo* t1 = (PeriodicalInfo*)obj1;
                 PeriodicalInfo* t2 = (PeriodicalInfo*)obj2;
                 if(t1.periodicalId <= t2.periodicalId) {
                     return NSOrderedDescending;
                 } else {
                     return NSOrderedAscending;
                 }
             }];
            
            handler(YES, changeUI, periodicals);
        } else {
            //降序排列,最新的排在最前面
            [periodicals sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                PeriodicalInfo* t1 = (PeriodicalInfo*)obj1;
                PeriodicalInfo* t2 = (PeriodicalInfo*)obj2;
                if(t1.periodicalId <= t2.periodicalId) {
                    return NSOrderedDescending;
                } else {
                    return NSOrderedAscending;
                }
            }];
            handler(YES, changeUI, periodicals);
        }
    }];
}

//使用page请求期刊列表
- (void)refreshMagazineWithPage:(NSInteger)page completionHandler:(void(^)(BOOL, NSArray*))handler
{
    id req = [SurfRequestGenerator getMagazineListWithPage:page];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data, NSError* error) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        if(!error) {
            NSString *body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            GetMagazineListResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[GetMagazineListResponse class]];
            if (resp.item && [resp.item count] > 0) {
                for (MagazineInfo * ma in resp.item) {
                    ma.iconUrl = [NSString stringWithFormat:@"%@%@", resp.apicPass, ma.iconUrl];//重新拼接icon链接
                }
                handler(YES, resp.item);
            } else {
                handler(YES, nil);
            }
        } else {
            handler(NO, nil);
        }
    }];
}

//获得更新期刊列表
- (void)getUpdatePeriodicalListCompletionHandler:(void(^)(BOOL, BOOL))handler
{
    //获得订阅的期刊id,加到数组里
    NSMutableArray *itemArray = [NSMutableArray new];
    for (MagazineSubsInfo *magazine in subsMagazines) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%ld", magazine.magazineId] forKey:@"magazineId"];
        [itemArray addObject:dict];
        
        //获取原有的期刊订阅文件夹
        UpdatePeriodicalInfo *pe = [EzJsonParser deserializeFromJson:[NSString stringWithContentsOfFile:[PathUtil pathOfUpdatePeriodicalInfoWithMagazineId:magazine.magazineId] encoding:NSUTF8StringEncoding error:nil] AsType:[UpdatePeriodicalInfo class]];
        if (pe) {
            magazine.lastUpdatePeriodicalInfo = pe;
        }
    }
    id req = [SurfRequestGenerator getUpdatePeriodicalList:itemArray];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data, NSError* error) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        
        BOOL changeUI = NO;
        
        if(!error) {
            NSString *body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            UpdatePeriodicalListResponse* resp = [EzJsonParser deserializeFromJson:body AsType:[UpdatePeriodicalListResponse class]];
            
            for (UpdatePeriodicalInfo *pe in resp.item) {
                //组装URL
                pe.magazineLogo = [NSString stringWithFormat:@"%@%@", resp.apicPass, pe.magazineLogo];
                if ([self getUpdatePeriodicalWithSameId:pe]) {  //这句逻辑很重要
                    changeUI = YES;
                }
            }
            
            handler(YES, changeUI);
        } else {
            handler(NO, changeUI);
        }
    }];
}

#pragma mark - 期刊详情
// 获取期刊期刊索引页
- (void)getPeriodicalContentIndex:(PeriodicalInfo*)periodicalInfo complete:(void(^)(BOOL, PeriodicalHtmlResolvingResult*))handler
{
    //普通路径
    NSString *path = [PathUtil pathOfPeriodicalContentIndexWithPeriodicalId:periodicalInfo.periodicalId
                                                               inMagazineId:periodicalInfo.magazineId];

    //离线下载索引页路径
    NSString *offlinesPath = [PathUtil pathOfflinesOfPeriodicalIndexWithPeriodicalId:periodicalInfo.periodicalId
                                                                          inMagazineId:periodicalInfo.magazineId];

    if([FileUtil fileExists:offlinesPath]){
        //获取索引页路径
        PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolving generateOfflinesWithPeriodical:periodicalInfo];
        handler(YES,result);
    }
    else if([FileUtil fileExists:path])
    {
        NSData *data = [NSData dataWithContentsOfFile:path];
        PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolving generateWithPeriodical:periodicalInfo                                                             andResolvedHtml:data];
        handler(YES,result);
    }
    else
    {
        id req = [SurfRequestGenerator getPeriodicalIndexWithMagazineId:periodicalInfo.magazineId
                                                           periodicalId:periodicalInfo.periodicalId];
        GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
        

        PeriodicalFetchingTask* task = [PeriodicalFetchingTask new];
        task.contentInfo = periodicalInfo;
        task.httpFecther = fetcher;
        task.isContentInfo = YES;
        task.completionHandler = handler;
        [fetchingTasks_ addObject:task];
        [fetcher beginFetchWithCompletionHandler:^(NSData* data, NSError* error) {
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            [[NSURLCache sharedURLCache] setDiskCapacity:0];
            [[NSURLCache sharedURLCache] setMemoryCapacity:0];
            if(!error) {
                //正文保存本地
                
                PeriodicalFetchingTask* task = nil;
                for (PeriodicalFetchingTask* t in fetchingTasks_)
                {
                    if(t.contentInfo.periodicalId == periodicalInfo.periodicalId
                        && t.isContentInfo)
                    {
                        task = t;
                        break;
                    }
                }
                if(task)
                {
                    [fetchingTasks_ removeObject:task];
                }
                NSString *body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
                [body writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
                
                //对应关系表保存本地
                PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolving generateWithPeriodical:periodicalInfo                                                             andResolvedHtml:data];
                
                NSString *path =  [PathUtil pathOfPeriodicalMappingWithPeriodicalId:periodicalInfo.periodicalId
                                                             inMagazineId:periodicalInfo.magazineId];

                
                [[EzJsonParser serializeObjectWithUtf8Encoding:result.herfArr] writeToFile:path
                                                                        atomically:YES
                                                                          encoding:NSUTF8StringEncoding
                                                                             error:nil];

                
                handler(YES,result);
            }else {
                handler(NO, nil);
            }
        }];
    }
}

- (void)cancelPeriodicalContent:(PeriodicalInfo*)periodicalInfo
{
    PeriodicalFetchingTask* task = nil;
    for (PeriodicalFetchingTask* t in fetchingTasks_)
    {
        if(t.contentInfo.periodicalId == periodicalInfo.periodicalId
           && t.isContentInfo)
        {
            task = t;
            break;
        }
    }
    if(task)
    {
        [task.httpFecther stopFetching];
        [fetchingTasks_ removeObject:task];
    }
}

// 获取期刊期刊正文
- (void)getPeriodicalContent:(PeriodicalLinkInfo *)info complete:(void(^)(BOOL, PeriodicalHtmlResolvingResult*))handler
{
    //离线下载
    if ([info.linkUrl rangeOfString:@"file://"].location != NSNotFound)
    {
        NSData *data = [NSData dataWithContentsOfFile:[info.linkUrl stringByReplacingOccurrencesOfString:@"file://"
                                                                                              withString:@""]];
        PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolving generateWithPeriodicalContent:info :data];
        handler(YES,result);
        return;
    }
    NSString *rootPath = [PathUtil pathOfPeriodicalWithPeriodicalId:info.periodicalId
                                                       inMagazineId:info.magazineId];
    

    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *filePath =[PathUtil pathOfPeriodicalContentWithLinkInfo:info];
    DJLog(@"%@",filePath);
    [FileUtil ensureDirExists:filePath];
    //旧版本(1.0.0-1.0.1)文件存放路径
    NSString *oldPath = [rootPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",info.linkId ]];
    //新版本文件存放路径
    NSString *newPath = [filePath stringByAppendingPathComponent:@"content.txt"];
    if([FileUtil fileExists:oldPath]){
        /**********************************
         将旧版本文件移动到新目录，并且删除旧文件，
         rootPath只保留对应关系表
        ***********************************/
        NSData *data = [NSData dataWithContentsOfFile:oldPath];

        NSString *body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [body writeToFile:newPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        [fm removeItemAtPath:oldPath error:nil];
        
        PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolving generateWithPeriodicalContent:info :data];
        handler(YES,result);
        
    }else if([FileUtil fileExists:newPath]){
        /**********************************
         将新版本所有资源全部在新目录，其中包括IMG对应关系，
         图片资源，正文内容
         ***********************************/
        NSData *data = [NSData dataWithContentsOfFile:newPath];
        
        PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolving generateWithPeriodicalContent:info :data];
        
        handler(YES,result);
        
    }else{
        NSURLRequest *request = [SurfRequestGenerator getPeriodicalContentWithURL:info.linkUrl];
        GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
        
        PeriodicalFetchingTask* task = [PeriodicalFetchingTask new];
        task.linkInfo = info;
        task.httpFecther = fetcher;
        task.isContentInfo = NO;
        task.linkCompletionHandler = handler;
        [fetchingTasks_ addObject:task];

        
        [fetcher beginFetchWithCompletionHandler:^(NSData* data, NSError* error) {
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            [[NSURLCache sharedURLCache] setDiskCapacity:0];
            [[NSURLCache sharedURLCache] setMemoryCapacity:0];
            PeriodicalFetchingTask* task = nil;
            for (PeriodicalFetchingTask* t in fetchingTasks_)
            {
                if(t.linkInfo.linkUrl == info.linkUrl
                   && !t.isContentInfo)
                {
                    task = t;
                    break;
                }
            }
            if(task)
            {
                [fetchingTasks_ removeObject:task];
            }

            if(!error) {
                NSString *body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
                [body writeToFile:newPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

                PeriodicalHtmlResolvingResult *result = [PeriodicalHtmlResolving generateWithPeriodicalContent:info
                                                                                                            :data];
                
                
                handler(YES,result);
            }else {
                handler(NO, nil);
            }
        }];
    }
}

// 取消获取期刊正文
- (void)cancelPeriodicalLinkInfo:(PeriodicalLinkInfo*)periodicalInfo
{
    PeriodicalFetchingTask* task = nil;
    for (PeriodicalFetchingTask* t in fetchingTasks_)
    {
        if(t.linkInfo.linkUrl == periodicalInfo.linkUrl
           && !t.isContentInfo)
        {
            task = t;
            break;
        }
    }
    if(task)
    {
        [task.httpFecther stopFetching];
        [fetchingTasks_ removeObject:task];
    }
}

//订阅期刊观察
- (void)addMagazineObserver:(id<SubsMagazineChangedObserver>)observer;
{
    if(![observers containsObject:observer])
        [observers addObject:observer];
}

//退订期刊观察
- (void)removeMagazineObserver:(id<SubsMagazineChangedObserver>)observer
{
    for (NSInteger i = 0; i < [observers count]; i++) {
        if (observer == observers[i]) {
            [observers removeObject:observer];
            break;
        }
    }
}

#pragma mark - UserManagerObserver
- (void)currentUserLoginChanged
{
    UserInfo *userInfo = [[UserManager sharedInstance] loginedUser];
    
    if (!userInfo) {
        //退出登陆展示游客用户
        [self loadLocalMagazinesSortInfo];
        for (id<SubsMagazineChangedObserver> observer in observers) {
            [observer subsMagazineChanged];
        }
#ifndef ipad
        //游客状态下删除无关的订阅数据
        NSArray *fileArr = [FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfMagazines]];
        for (NSString *fileName in fileArr)
        {
            if (![self getMagazineWithId:[fileName integerValue]]) {
                [FileUtil deleteDirAndContents:[[PathUtil rootPathOfMagazines]
                                                stringByAppendingPathComponent:fileName]];
            }
        }
#endif
    }
}

//获取登录用户的期刊订阅列表
-(void)refreshMagazineListWithUser:(UserInfo*)userInfo handler:(void(^)(BOOL succeeded))handler
{
    updateMagazineLastDate = [NSDate date];
    
    id channelReq = [SurfRequestGenerator getMagazineSubsWithUserId:userInfo.userID];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:channelReq];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        if (!error) {
            //将服务器返回的订阅关系存在本地
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            
            //期刊订阅
            GetMagazineSubsResponse* magazineSubsList = [EzJsonParser deserializeFromJson:body AsType:[GetMagazineSubsResponse class]];
            if (magazineSubsList) {
                [wapVisiableMagazines removeAllObjects];
                [self overwriteLocalMagazines:magazineSubsList];
                for (id<SubsMagazineChangedObserver> observer in observers) {
                    [observer subsMagazineChanged];
                }
                handler(YES);
            } else {
                handler(NO);
            }
        } else {
            //获取订阅列表失败
            handler(NO);
        }
    }];
}

- (void)dealloc
{
    UserManager *manager = [UserManager sharedInstance];
    [manager removeUserLoginObserver:self];
    
#if ! __has_feature(objc_arc)
    [super dealloc];
#endif
}

@end
