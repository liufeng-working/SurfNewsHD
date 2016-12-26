//
//  SurfFlagsManager.m
//  SurfNewsHD
//
//  Created by XuXg on 14-10-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "SurfFlagsManager.h"
#import "SurfRequestGenerator.h"
#import "SubsChannelsManager.h"
#import "MagazineManager.h"
#import "EzJsonParser.h"
#import "ClassifyUpdateFlagResponse.h"
#import "NSString+Extensions.h"
#import "PathUtil.h"
#import "HotChannelsManager.h"
#import "HotChannelsListResponse.h"


typedef enum  {
    kRequestType_Classity,  // 分类请求
    kRequestType_Complete   // 请求完成
} RequestType;

@class HotChannel;



@interface SurfFlagsManager ()
{
    BOOL _isLoding;
    RequestType _type;
    
    
    // 新闻频道标记
    NSMutableArray *_addNewChannelList;   // 新增频道列表
    NSMutableArray *_newsChannelReadList; // 新闻频道已读列表
}



@end




@implementation SurfFlagsManager
@synthesize classifyFlag = _classifyFlag;


+ (SurfFlagsManager*)sharedInstance
{
    static SurfFlagsManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [SurfFlagsManager new];
    });
    return sharedInstance;
}

-(id)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    
    _addNewChannelList = [NSMutableArray array];
    [self initNewsChannelReadArray];

    
    return self;
}

+ (UIImage*)flagImage
{
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = [UIImage imageNamed:@"isnew.png"];
    });
    return image;
}

// 刷新标记点
-(void)refreshFlags
{
    if (_isLoding) {
        return;
    }
    
    _type = kRequestType_Classity;
    [self requestFlags];
}

// 请求标记点
-(void)requestFlags
{
    if (_type == kRequestType_Classity) {
        [self requestClassityFlag];
    }
    
}


// 请求分类标记
-(void)requestClassityFlag
{
    // 准备订阅频道和期刊频道
    NSMutableArray *subsIds = [NSMutableArray array];
    NSMutableArray *magazineIds = [NSMutableArray array];
    MagazineManager *mm = [MagazineManager sharedInstance];
    SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
    
    // 取订阅频道ids
    for (SubsChannel *sc in [scm visibleSubsChannels]) {
        [subsIds addObject:[NSString stringWithFormat:@"%ld", sc.channelId]];
    }
    

    // 取订阅频道ids
    NSMutableArray *subMagazines = [mm subsMagazines];
    [subMagazines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[MagazineSubsInfo class]]) {
            NSString *str =[NSString stringWithFormat:@"%ld", [obj magazineId]];
            [magazineIds addObject:str];
        }
    }];
    
    
    // 初始化请求
    _isLoding = YES;
    NSURLRequest *request = [SurfRequestGenerator classifyUpdateFlag:magazineIds subcribeIds:subsIds];
    __block GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* err) {
        if(!err) {
            NSString *body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            Class ct = [ClassifyUpdateFlagResponse class];
            _classifyFlag = [EzJsonParser deserializeFromJson:body AsType:ct];
        }

        // 如果还有请求，直接在这里加入
        _isLoding = NO;
        _type = kRequestType_Complete;
        [self requestFlags];
    }];
}




#pragma -mark  新闻频道模块标记
// 检查新闻频道是否增加新的频道或删除频道
-(void)checkNewsChannels:(NSArray*)newsChannels
{
    if(!newsChannels || [newsChannels count] == 0)
        return;
    
    
    BOOL readListIsChanged = NO;
    [_addNewChannelList removeAllObjects];
    for (NSInteger i=0; i<[newsChannels count]; ++i)
    {
        HotChannel *hc = (HotChannel*)[newsChannels objectAtIndex:i];
        NSString *flagV = [NSString stringWithFormat:@"%@", hc.channelName];
        if ([hc isnew])
        {
            // 检查已读标记列表中不存在
            if(![_newsChannelReadList containsObject:flagV])
            {
                [_addNewChannelList addObject:flagV];
            }
        }
        else{
            // 为了防止数据不停增长，对数据删减
            if([_newsChannelReadList containsObject:flagV])
            {
                readListIsChanged = YES;
                [_newsChannelReadList removeObject:flagV];
                
            }
        }
    }


    // 已读频道列表发生改变
    if (readListIsChanged) {
        [self writeToArraySelected];
    }
}

// 标记新闻频道已读
-(void)markNewsChnannelAsRead:(HotChannel*)hc
{
    if (!hc || ![hc isnew])
        return;
    
    NSString *flagV = [NSString stringWithFormat:@"%@", hc.channelName];
    
    if ([_addNewChannelList containsObject:flagV]) {
        [_addNewChannelList removeObject:flagV];
    }
    
    if (![_newsChannelReadList containsObject:flagV]) {
        [_newsChannelReadList addObject:flagV];
        [self writeToArraySelected];
    }
}

// 检查新闻频道是否是新增频道
-(BOOL)checkNewsChannelIsAddChannel:(HotChannel*)hc
{
    BOOL isAdd = NO;
    if (!hc) {
        return isAdd;
    }
    
    if (hc.isnew) {
        
        NSString *flagV = [NSString stringWithFormat:@"%@", hc.channelName];
        if ([_addNewChannelList containsObject:flagV] &&
            ![_newsChannelReadList containsObject:flagV]) {
            isAdd = YES;
        }
    }
    return isAdd;
}

// 是否存在新增加的新闻频道
-(BOOL)isExistNewsChannelFlag
{
    return [_addNewChannelList count];
}


- (void)writeToArraySelected
{
    NSString *path = [PathUtil pathOfHotChannelSelected];
    [_newsChannelReadList writeToFile:path atomically:YES];
}
-(void)initNewsChannelReadArray
{
    NSString *filePath = [PathUtil pathOfHotChannelSelected];
    _newsChannelReadList = [[NSArray arrayWithContentsOfFile:filePath] mutableCopy];
    if (!_newsChannelReadList) {
        _newsChannelReadList = [NSMutableArray array];
    }
}

@end
