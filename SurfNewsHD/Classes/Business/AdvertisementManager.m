//
//  AdvertisementManager.m
//  SurfNewsHD
//
//  Created by xuxg on 14-4-24.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "AdvertisementManager.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "EzJsonParser.h"
#import "NSString+Extensions.h"
#import "GTMHTTPFetcher.h"
#import "ImageDownloader.h"
#import "AppSettings.h"


@implementation AdvertisementInfo
@synthesize adId = __KEY_NAME_id;



@end


@implementation AdvertisementResponse
@synthesize item = __ELE_TYPE_AdvertisementInfo;

// 是否需要更新
- (BOOL)isNeedUpdate
{
    if (self.updateTime > 0) {
        // 计算当前的时间间隔
        NSTimeInterval nowInterval = [[NSDate date] timeIntervalSince1970];
        NSTimeInterval oldInterval = [AppSettings doubleForKey:DoubleKey_Ad_UpdateTime];

        // 过期时间
        if (nowInterval < self.updateTime / 1000 + oldInterval) {
            return NO;
        }
    }
    return YES;
}

@end




@interface AdvertisementManager ()

@property(nonatomic,strong) AdvertisementResponse* adResp;

@end

@implementation AdvertisementManager

+ (AdvertisementManager*)sharedInstance
{
    static AdvertisementManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AdvertisementManager alloc] init];
    });
    return sharedInstance;
}

-(id)init{
    if (self = [super init]) {
        [self loadDataFromFile];
    }
    return self;
}

// 加载本地广告数据
- (void)loadDataFromFile
{
    NSString *adInfoTxtPath = [PathUtil pathOfAdvertisementInfo];
    if ([FileUtil fileExists:adInfoTxtPath]) {
        NSString *fileContent = [NSString stringWithContentsOfFile:adInfoTxtPath
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil];
        if(fileContent && ![fileContent isEmptyOrBlank])
        {
            self.adResp = [EzJsonParser deserializeFromJson:fileContent
                                                 AsType:[AdvertisementResponse class]];
            
            // 删除过期的广告
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSMutableArray *adList = [NSMutableArray arrayWithArray:[self.adResp item]];
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            for (NSInteger i = [adList count]-1; i >= 0; --i) {
                AdvertisementInfo* info = [adList objectAtIndex:i];
                // 删除过期的广告
                if ((now - info.endTime/1000.f) > 0) {
                    // 删除广告资源 1.过期的广告， 2.在新广告列表中不存在的广告
                    if ([[info type] isEqualToString:@"1"]) {
                        NSString *imgPath = [PathUtil pathOfAdvertisementImage:info];
                        if ([fileMgr fileExistsAtPath:imgPath]) {
                            [fileMgr removeItemAtPath:imgPath error:nil];
                        }
                    }
                    [adList removeObjectAtIndex:i];
                }
            }

            if ([adList count] < [_adResp.item count]) {
                _adResp.item = adList;
            }
            
            
            // 检测图片是否准备好
            for (AdvertisementInfo *info in _adResp.item) {
                if ([[info type] isEqualToString:@"1"]) {
                    NSString *path = [PathUtil pathOfAdvertisementImage:info];
                    [info setIsReadyImage:[fileMgr fileExistsAtPath:path]];
                    if (![info isReadyImage]) {
                        [self downloadAdImage:info];
                    }
                }
            }
        }
    }
}

// 更新广告信息
- (void)updateAdvertisement
{
    // 请求广告信息
    if (_adResp && ![_adResp isNeedUpdate]) {
        return;
    }
    
    id req = [SurfRequestGenerator adInfoRequest];
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    fetcher.servicePriority = 2;
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
    {
        if(!error)
        {
            NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
            
            // 保存到文件中
            NSError *err;
            NSString *adInfoTxtPath = [PathUtil pathOfAdvertisementInfo];
            [body writeToFile:adInfoTxtPath atomically:YES encoding:NSUTF8StringEncoding error:&err];

            
            NSMutableArray *oldAdList = [_adResp.item mutableCopy];
            _adResp = [EzJsonParser deserializeFromJson:body AsType:[AdvertisementResponse class]];

            // 删除广告
            NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
            for (NSInteger i=[oldAdList count]-1; i >= 0; --i) {
                AdvertisementInfo* info = [oldAdList objectAtIndex:i];                
                // 删除过期的广告
                if ((now - info.endTime/1000.f) > 0) {
                    // 删除广告资源 1.过期的广告， 2.在新广告列表中不存在的广告
                    if ([[info type] isEqualToString:@"1"] ||
                        ![self isSameAdInfoWithArray:info inArray:_adResp.item]) {
                        NSFileManager *fileMgr = [NSFileManager defaultManager];
                        NSString *imgPath = [PathUtil pathOfAdvertisementImage:info];
                        if ([fileMgr fileExistsAtPath:imgPath]) {
                            [fileMgr removeItemAtPath:imgPath error:nil];
                        }
                    }
                    [oldAdList removeObjectAtIndex:i];
                }
            }
            
            // 保存更新时间
            // 内容中有一个预留数据，不能包含在内容
            if (!err && _adResp.item.count > 1) {
                // 保存广告更新时间本地时间
                NSTimeInterval update = [[NSDate date] timeIntervalSince1970];
                [AppSettings setDouble:update forKey:DoubleKey_Ad_UpdateTime];
            }
            
            
            // 下载广告图片
            NSFileManager *fm = [NSFileManager defaultManager];
            for (AdvertisementInfo* a in _adResp.item) {
                if ([[a type] isEqualToString:@"1"]) {
                    NSString *imgPath = [PathUtil pathOfAdvertisementImage:a];
                    
                    // 检查图片是否存在并设置图片状态
                    [a setIsReadyImage:[fm fileExistsAtPath:imgPath]];
                    if (![a isReadyImage]) {
                        [self downloadAdImage:a];
                    }
                }
            }
        }
    }];
}

// 获取频道广告
// 注：文字广告大于2，会随机抽取2个广告。大于1的图片广告随机获取一个
-(NSArray*)getAdvertisementOfCoid:(long)coid
{
    NSMutableArray *newAdList = [[NSMutableArray alloc] initWithCapacity:3];
    if ([self.adResp item].count > 0) {
        // 找到频道下得所有广告
        NSMutableArray *sameCoidAdList = [NSMutableArray new];
        NSString *coidStr = [NSString stringWithFormat:@"%ld", coid];
        for (AdvertisementInfo *a in [self.adResp item]) {
            if ([[a coid] isEqualToString:coidStr]) {
                [sameCoidAdList addObject:a];
            }
        }
        
        // 广告进行分类
        if ([sameCoidAdList count] > 0) {
            NSMutableArray *textAd = [NSMutableArray new];  // 文字新闻
            NSMutableArray *picAd = [NSMutableArray new];   // 图片新闻
            for (NSInteger i=0; i<[sameCoidAdList count]; ++i) {
                AdvertisementInfo *t = [sameCoidAdList objectAtIndex:i];
                if ([[t type] isEqualToString:@"0"]) {
                    [textAd addObject:t];
                }
                else if([[t type] isEqualToString:@"1"] && [t isReadyImage]){
                    [picAd addObject:t];
                }
            }
      
 
            // 随机搞2个文字广告塞进去
            for (NSInteger i = 0 ; i < 2; ++i) {
                NSInteger r = [textAd count];
                if (r > 0) {
                    NSInteger idx = arc4random() % r;
                    [newAdList addObject:[textAd objectAtIndex:idx]];
                    [textAd removeObjectAtIndex:idx];
                }
            }
            
            // 随机搞1个图片广告塞进去
            for (NSInteger i = 0; i < 1; ++i) {
                NSInteger r = [picAd count];
                if (r > 0 ) {
                    NSInteger idx = arc4random() % r;
                    [newAdList addObject:[picAd objectAtIndex:idx]];
                    [picAd removeObjectAtIndex:idx];
                }
            }
        }
    }
    return newAdList;
}

// 是否存在相同的广告，根据adId 和coid 一致就说明是相同的广告
- (BOOL)isSameAdInfoWithArray:(AdvertisementInfo*)info inArray:(NSArray*)array
{
    for (AdvertisementInfo* ai in array)
    {
        if([ai.adId isEqualToString:info.adId] &&
           [ai.coid isEqualToString:info.coid])
            return YES;
    }
    return NO;
}

// 下载广告图片
-(void)downloadAdImage:(AdvertisementInfo*)info
{
    if (![[info type] isEqualToString:@"1"] || [info isReadyImage]) {
        return;
    }
    
    ImageDownloadingTask *task = [ImageDownloadingTask new];
    [task setImageUrl:[info img_url]];
    [task setUserData:info];
    [task setTargetFilePath:[PathUtil pathOfAdvertisementImage:info]];
    [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
        if (succeeded && [[idt userData] isKindOfClass:[AdvertisementInfo class]]) {
            AdvertisementInfo *adInfo_black = [idt userData];
            AdvertisementInfo *validInfo_black = nil;
            NSFileManager *fm_balck = [NSFileManager defaultManager];
            // 设置图片加载完成，这样做的目的是为了保证图片信息是真实有效的
            for (AdvertisementInfo* ai in self.adResp.item)
            {
                validInfo_black = nil;
                if([ai.adId isEqualToString:adInfo_black.adId] &&
                   [ai.coid isEqualToString:adInfo_black.coid])
                {
                    validInfo_black = ai;
                    // 为什么添加这个多此一举的代码：测试居然给相同imgURl的图片，导致第二个图片不能下载。
                    if (![fm_balck fileExistsAtPath:[idt targetFilePath]]) {
                        [[idt resultImageData] writeToFile:[idt targetFilePath] atomically:YES];
                    }
                    [validInfo_black setIsReadyImage:[fm_balck fileExistsAtPath:[idt targetFilePath]]];
                    break;
                }
            }

            
            // 检查广告是否存在，不存在就需要删除imgDownload保存的文件
            if (validInfo_black == nil) {
                // 删除图片文件
                [FileUtil deleteFileAtPath:[idt targetFilePath]];
            }
        }
    }];
    [[ImageDownloader sharedInstance] download:task];
}
@end
