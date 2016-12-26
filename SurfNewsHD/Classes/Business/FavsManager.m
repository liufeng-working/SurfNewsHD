//
//  FavsManager.m
//  SurfNewsHD
//
//  Created by yuleiming on 13-1-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "FavsManager.h"
#import "ThreadSummary.h"
#import "EzJsonParser.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "NSString+Extensions.h"

@implementation FavsManager

+(FavsManager*)sharedInstance
{
    static FavsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FavsManager alloc] init];
    });
    
    return sharedInstance;
}

-(NSUInteger)threadsCount
{
    [self ensureThreadsDirNamesReady];
    return [threadsDirNames_ count];
}

-(NSArray*)fetchThreadsWithRange:(NSRange)range
{
    NSUInteger totalCount = [self threadsCount];
    NSMutableArray* array = [NSMutableArray new];

    for (NSUInteger i = range.location; i < range.location + range.length && i < totalCount; i++)
    {
        NSString* infoFilePath = [[[PathUtil rootPathOfFavs] stringByAppendingPathComponent:[threadsDirNames_ objectAtIndex:i]] stringByAppendingPathComponent:@"info.txt"];
        NSString* info = [NSString stringWithContentsOfFile:infoFilePath encoding:NSUTF8StringEncoding error:nil];
        if(info && ![info isEmptyOrBlank])
        {
            FavThreadSummary* fav = [EzJsonParser deserializeFromJson:info AsType:[FavThreadSummary class]];
            [array addObject:fav];
        }
    }

    return array;
}

-(BOOL)isThreadInFav:(ThreadSummary*)thread
{
    return [self getFavDirNameWithThread:thread] != nil;
}

- (long)isEnergyInTs:(ThreadSummary*)thread{
    return thread.is_energy;
}

- (long)isPositive_energy:(ThreadSummary*)thread{
    if ([self isEnergyInTs:thread]) {
        NSInteger positive = thread.positive_energy;
        NSInteger negative;
        if (thread.negative_energy < 0) {
            negative = 0 - thread.negative_energy;
        }
        else
            negative = thread.negative_energy;
        if (positive > negative) {
            return thread.positive_energy;
        }
    }
    return 0;
}

- (long)isNegative_energy:(ThreadSummary*)thread{
    if ([self isEnergyInTs:thread]) {
        if (thread.negative_energy > 0) {
            return thread.negative_energy;
        }
    }
    return 0;
}


-(void)doAddFav:(ThreadSummary*)thread
{
    FavThreadSummary* fav = [[FavThreadSummary alloc] initWithThread:thread];
    
    NSDateFormatter* df = [NSDateFormatter new];
    [df setDateFormat:@"yyyyMMddHmmss"];
    NSString* targetDirName = [NSString stringWithFormat:@"%ld_%@_%@",thread.channelId,@(thread.threadId),[df stringFromDate:[NSDate dateWithTimeIntervalSince1970:fav.creationDate / 1000.0]]];
    [[NSFileManager defaultManager]createDirectoryAtPath:[[PathUtil rootPathOfFavs] stringByAppendingPathComponent:targetDirName] withIntermediateDirectories:YES attributes:nil error:nil];
    
    //把thread目录下所有文件都拷贝过来
    [FileUtil copyContentsOfDir:[PathUtil pathOfThread:thread] toDir:[[PathUtil rootPathOfFavs] stringByAppendingPathComponent:targetDirName]];
    
    //覆盖info.xml
    [[EzJsonParser serializeObjectWithUtf8Encoding:fav] writeToFile:[[[PathUtil rootPathOfFavs] stringByAppendingPathComponent:targetDirName] stringByAppendingPathComponent:@"info.txt"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    //只有在已经读取过收藏记录后才需要添加到收藏记录
    if (threadsDirNames_)
    {
        [threadsDirNames_ addObject:targetDirName];
        [self sortThreadsByCreationDate];
    }
}

-(void)addFav:(ThreadSummary*)thread withCompletionHandler:(void(^)(BOOL))handler
{
    if ([self isThreadInFav:thread])
        return;

    if(handler)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^(void)
                       {
                           [self doAddFav:thread];
                           dispatch_sync(dispatch_get_main_queue(), ^(void)
                                         {
                                             handler(YES);
                                         });
                       });
    }
    else
    {
        [self doAddFav:thread];
    }
}

-(void)addFav:(ThreadSummary*)thread
{
    [self addFav:thread withCompletionHandler:NULL];
}

-(void)removeFav:(ThreadSummary*)thread
{
    NSString* dirName = [self getFavDirNameWithThread:thread];
    if (!dirName)
        return;
    
    //移除物理文件
    [FileUtil deleteDirAndContents:[[PathUtil rootPathOfFavs]stringByAppendingPathComponent:dirName]];
    
    if (threadsDirNames_)
    {
        [threadsDirNames_ removeObject:dirName];
    }
}

-(void)removeAllFavs
{
    [FileUtil deleteContentsOfDir:[PathUtil rootPathOfFavs]];
    if(threadsDirNames_)
    {
        [threadsDirNames_ removeAllObjects];
    }
}

-(NSString*)getFavDirNameWithThread:(ThreadSummary*)thread
{
    [self ensureThreadsDirNamesReady];
    NSString* tmp = [NSString stringWithFormat:@"%ld_%@_",thread.channelId,@(thread.threadId)];
    
    for (NSString* dirName in threadsDirNames_)
    {
        if([dirName hasPrefix:tmp])
            return dirName;
    } 
    return nil;
}

-(void)ensureThreadsDirNamesReady
{
    if (!threadsDirNames_)
    {
        threadsDirNames_ = [[NSMutableArray alloc] initWithArray:[FileUtil getSubdirNamesOfDir:[PathUtil rootPathOfFavs]]];
        [self sortThreadsByCreationDate];
    }
}

-(void)sortThreadsByCreationDate
{
    [threadsDirNames_ sortUsingComparator:^NSComparisonResult(NSString* x,NSString* y)
     {
         //4061_112234_20120809120102
         NSString* xDate = [x substringFromIndex:[x lastIndexOfString:@"_"] + 1];
         NSString* yDate = [y substringFromIndex:[y lastIndexOfString:@"_"] + 1];
         return [xDate compare:yDate];
     }];
}

@end
