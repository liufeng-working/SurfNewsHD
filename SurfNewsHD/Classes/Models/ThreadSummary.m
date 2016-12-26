//
//  ThreadSummary.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ThreadSummary.h"
#import "NSString+Extensions.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "EzJsonParser.h"
#import "ActivityRequest.h"
#import "GetPeriodicalListResponse.h"

@implementation ThreadSummary

@synthesize threadId = __KEY_NAME_newsId;
@synthesize time=_time;
@synthesize multiImgUrl = __ELE_TYPE_SNMultiImageUrl;
@synthesize special_list = __ELE_TYPE_ThreadSummary;


// 不需要被序列化,也就是不需要保存的值
@synthesize rssId = __DO_NOT_SERIALIZE_;
@synthesize energyScore = __DO_NOT_SERIALIZE_ES;
@synthesize timeStr = __DO_NOT_SERIALIZE_timeStr;


-(id)init
{
    if(self = [super init])
    {
        self.channelType = 1;
        self.title = @"";
        self.source = @"";
        self.desc = @"";
        self.type = 1;  //默认为普通帖子
        self.belleGirl_report = 0;
        self.belleGirl_hate = 0;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    ThreadSummary *copy = [[[self class] allocWithZone:zone] init];
    copy.title = [_title copy];
    copy.desc = [_desc copy];
    copy.newsUrl = [_newsUrl copyWithZone:zone];
    
    return copy;
}

-(void)setTime:(double)time
{
    _time = time;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000.f];
    
    // 多少小时前
    NSTimeInterval timeInter = [[NSDate date] timeIntervalSinceDate:date];
    NSInteger hours = ((NSInteger)timeInter)%(3600*24)/3600;
    if(hours < 12) {
        if (hours <= 1) {
            hours = 1;
        }
        __DO_NOT_SERIALIZE_timeStr = [NSString stringWithFormat:@"%@小时前",@(hours)];
    }
    else {
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyy-MM-dd"];
        __DO_NOT_SERIALIZE_timeStr = [df stringFromDate:date];
    }
}

// 热点图片路径（测试用的代码）
-(void)setIconPath:(NSString *)iconPath
{
    if (![iconPath isEmptyOrBlank] && [iconPath rangeOfString:@"http"].location == NSNotFound) {
        // http://go.10086.cn/surfnews/usr/surf/icon/20130805100846.png        
        _iconPath = [NSString stringWithFormat:@"http://go.10086.cn/surfnews/usr/surf/icon/%@",iconPath];
    }
    else{
         _iconPath = iconPath;
    }
}

- (BOOL)isEqualToThread:(ThreadSummary*)thread
{
    if(self.threadId != thread.threadId)
        return NO;
    if(self.isTop != thread.isTop)
        return NO;
    if(self.time != thread.time)
        return NO;
    if(self.channelId != thread.channelId)
        return NO;
    if(self.channelType != thread.channelType)
        return NO;
    if(self.threadM != thread.threadM)
        return NO;
    if(self.isPicThread != thread.isPicThread)
        return NO;
    if(![NSString isString:self.title logicallEqualsToString:thread.title])
        return NO;
    if(![NSString isString:self.source logicallEqualsToString:thread.source])
        return NO;
    if(![NSString isString:self.desc logicallEqualsToString:thread.desc])
        return NO;
    if(![NSString isString:self.newsUrl logicallEqualsToString:thread.newsUrl])
        return NO;
    if(![NSString isString:self.imgUrl logicallEqualsToString:thread.imgUrl])
        return NO;
    if ((self.multiImgUrl == nil && thread.multiImgUrl) ||
        (self.multiImgUrl && thread.multiImgUrl == nil )) {
        return NO;
    }
    if ([self.multiImgUrl count] == [thread.multiImgUrl count]){
        for(NSInteger i = 0; i<[self.multiImgUrl count]; ++i) {
            SNMultiImageUrl *urlObj1 = self.multiImgUrl[i];
            SNMultiImageUrl *urlObj2 = thread.multiImgUrl[i];
            if (![urlObj1.imgUrl isEqualToStringCaseInsensitive:urlObj2.imgUrl]) {
                return NO;
            }
        }
    }
    return YES;
}

// 确保文件目录存在，必须存在channelId threadId 是有效值
- (void)ensureFileDirExist{
    if (self.threadId == 0 || self.channelId == 0) {
        @throw [NSException exceptionWithName:@"threadSummary.m ensureFileDirExist" reason:@"不符合创建目录要求" userInfo:nil];
    }
    
    NSString *threadDir = [PathUtil pathOfThread:self];
    if (![FileUtil dirExists:threadDir]) {
        [FileUtil ensureDirExists:threadDir];
        
        // 创建info.txt文件
        [[EzJsonParser serializeObjectWithUtf8Encoding:self] writeToFile:[PathUtil pathOfThreadInfo:self] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

//分享的链接
-(NSString *)buildActivityContentUrl
{
    if (_contentUrl) {
        _contentUrl = [self getNowebpWithUrlString:_contentUrl];
        
    }else{
        _contentUrl = [self buildActivityNewUrl];
    }
    return self.contentUrl;
}

// 只正对type==3(活动类型)创建新闻链接
- (NSString*)buildActivityNewUrl
{
    if (!_newsUrl || [_newsUrl isEmptyOrBlank])
        return nil;
    
    _newsUrl = [_newsUrl trim]; // 过滤空格
    
    if (_type == 3) {
//        http://192.168.10.170:8091/suferDeskInteFace/redirectService?jsonRequest={"activityId":"97894","uid":"faf50a122c70cd91","sdkv":"15","os":"android","cityId":"101190101","dm":"540*960","pm":"HTC Z715e","did":"314ee5f7-b5a5-36be-85d6-ef04cd1b3cba","vername":"3.4","imsi":"460020019644765","cid":"11","vercode":47}
      
        ActivityRequest* activityReq = [[ActivityRequest alloc] init:self.threadId];
        NSString* json = [EzJsonParser serializeObjectWithUtf8Encoding:activityReq];
        NSString* url = [self.newsUrl stringByAppendingString:@"?jsonRequest="];
        return [url stringByAppendingString:[json urlEncodedString]];
    }
    else {
        _newsUrl = [self getNowebpWithUrlString:_newsUrl];
        }
    return self.newsUrl;
}

-(NSString *)getNowebpWithUrlString:(NSString *)urlString
{
    [urlString trim];
    
    // IOS webView 对webP图片不支持，在分享的时候就不使用webP图片
    if (![urlString containsCasInsensitive:@"nowebp"]) {
        //判读url中是否有“ ？”，有：说明url中已经有参数了；没有：说明url中没有参数
        if ([urlString containsCasInsensitive:@"?"]) {
            //有参数，直接加 &nowebp
            urlString = [urlString stringByAppendingString:@"&nowebp"];
        }
        else {
            //没有参数，加 ？nowebp
            urlString = [urlString stringByAppendingString:@"?nowebp"];
        }
    }
    
        return urlString;

}


// 创建一个期刊对象
-(PeriodicalInfo*)buildPeriodical
{
//    if (_open_type == 3) {
//        PeriodicalInfo *pi = [PeriodicalInfo new];
//        pi.magazineName = _magazine_name;
//        return pi;
//    }
    return nil;
}

// 返回美女频道图片高度
-(CGFloat)getBeautyChannelImageHeight:(CGFloat)imageWidth
{
    NSString *dm = _dm;
    // 防止服务器不给值
    if (!dm || [_dm isEmptyOrBlank]){
        dm = @"600*800";    // 设置默认值
    }
    
    if (imageWidth > 0) {
        NSArray* comp = [dm componentsSeparatedByString:@"*"];
        if ([comp count] >= 2) {
            float w = [[comp objectAtIndex:0] floatValue];
            float h = [[comp objectAtIndex:1] floatValue];
            if (w > 0 && h > 0) {
                CGFloat scale = w / h;
                return imageWidth / scale;
            }
        }
    }
    return 400.f; // 这个是默认值，不能完全相信服务器。
}

-(void)saveToFile
{
    [self ensureFileDirExist];
    
    [[EzJsonParser serializeObjectWithUtf8Encoding:self] writeToFile:[PathUtil pathOfThreadInfo:self] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


// 是否T+新闻
-(BOOL)isTPlusNews
{
    //  热推第一条的T+新闻  新闻推荐  2
    //  热推第一条的T+新闻  RSS推荐   1
    return (_ctype > 0);
}

// 是否支持显示的类型
-(BOOL)isSupportShowType
{
    if (_showType == TSShowType_Image_Only ||
        _showType == TSShowType_Image_mutable ||
        _showType == TSShowType_Image_None ||
        _showType == TSShowType_Adver_BigImage ||
        _showType == TSShowType_Adver_SmallImage ||
        _showType == TSShowType_Special_Image ||
        _showType == TSShowType_Special_None) {
        
        
        // 尼玛在做一个扩展功能，对图片的合法性验证
        if(_showType == TSShowType_Image_Only &&
           (!_imgUrl || [_imgUrl isEmptyOrBlank])){
            _showType = TSShowType_Image_None;
        }
        else if (_showType == TSShowType_Image_mutable &&
                 [self.multiImgUrl count] < 3) {
            if (_imgUrl && ![_imgUrl isEmptyOrBlank]) {
                _showType = TSShowType_Image_Only;
            }
            else {
                _showType = TSShowType_Image_None;
            }
        }
        
        return YES;
    }
    return NO;
}

// 是否是专题新闻
-(BOOL)isSpecialNews
{
    if (TSShowType_Special_Image == _showType||
        TSShowType_Special_None == _showType)
        return YES;
    return NO;
}

// 是否是Url方式打开
-(BOOL)isUrlOpen
{
    if(1 == _webView)
        return YES;
    return NO;
}

// 是否是大图类型(在新闻列表中使用)
-(BOOL)isBigImageType
{
    //大图新闻showType=1003为无图模式，老版本可正常显示，
    //新版本先判断showType=1003，再根据新增string型字段 bigImg=“1”才为大图新闻，大图新闻的图片地址取bannerUrl字段
    if (1 == _bigImg &&
        _showType == TSShowType_Image_None &&
        _bannerUrl && ![_bannerUrl isEmptyOrBlank])
        return YES;
    return NO;
}


// 是否需要下载图片(在新闻列表中使用)
-(BOOL)isNeedLoadImage
{
    if ([self isBigImageType]) {
        return YES;
    }
    
    if(_showType == TSShowType_Special_Image ||
       _showType == TSShowType_Image_Only ||
       _showType == TSShowType_Adver_BigImage ||
       _showType == TSShowType_Adver_SmallImage){
        if (_imgUrl && ![_imgUrl isEmptyOrBlank]) {
            return YES;
        }
    }
    else if (_showType == TSShowType_Image_mutable ){
        if ( [[self multiImgUrl] count] >=3) {
            return YES;
        }
    }
    return NO;
}
@end


@implementation FavThreadSummary



-(id)initWithThread:(ThreadSummary*)thread
{
    if(self = [self init]) {
        self->_creationDate = [[NSDate date] timeIntervalSince1970] * 1000;
        self.channelId = thread.channelId;
        self.channelType = thread.channelType;
        self.desc = thread.desc;
        self.time = thread.time;
        self.imgUrl = thread.imgUrl;
        self.isTop = thread.isTop;
        self.source = thread.source;
        self.newsUrl = thread.newsUrl;
        self.threadId = thread.threadId;
        self.title = thread.title;
        self.threadM = thread.threadM;
        self.isPicThread = thread.isPicThread;
        self.type = thread.type;
        self.multiImgUrl = thread.multiImgUrl;
    }
    return self;
}
@end

// multiImgUrl新闻列表3张图
@implementation SNMultiImageUrl

@end
