//
//  PhoneshareWeiboInfo.m
//  SurfNewsHD
//
//  Created by XuXg on 15/1/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "PhoneshareWeiboInfo.h"
#import "NSString+Extensions.h"



@interface PhoneshareWeiboInfo() {
    
    NSString *_title;
    NSString *_desc;
    NSString *_url;
    
    ThreadSummary *_threadSum;
    long _energyValue;
}

@end

@implementation PhoneshareWeiboInfo
// 初始化微博数据
-(id)initWithWeiboSource:(WeiboDataSource)source;
{
    self = [super init];
    if (!self)return nil;
    
    _weiboSource = source;
    _showWeiboType = kAllWeiboType;
    _weiboBGColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    return self;
}


-(void)setWeiboTitle:(NSString*)title
                desc:(NSString*)desc
                 url:(NSString*)url
{
    _title = title;
    _desc = desc;
    _url = url;
}

-(void)setThread:(ThreadSummary *)thread
   isShareEnergy:(BOOL)isEn
{
    _threadSum = thread;
    _title = thread.title;
    _desc = thread.desc;
    
    
    // 本地频道和订阅频道新闻直接给新闻URl
    _url = [thread buildActivityContentUrl];
    if (isEn){
        _energyValue = thread.energyScore;
        
        
        // 热推新闻需要在URl添加参数(正负能量添加字段)
        if (thread.threadM == HotChannelThread &&
            thread.channelId != 0 )
        {
            //id=824200&cid=4061&coc=6GP3GGjt&fromType=2&from=timeline&isappinstalled=1&sso_command=checkLogin&sso_cl_key=IBqMZwhPka
            // fromType 字段  1.正文分享   2.正负能量分享
            NSMutableString *urlStr = [NSMutableString stringWithString:kShareWeibo];
            [urlStr appendFormat:@"&id=%@&cid=%@",@(thread.threadId),@(thread.channelId)];
            [urlStr appendString:@"&coc=6GP3GGjt"];
            [urlStr appendFormat:@"&fromType=%d",isEn ? 2 : 1];
            _url = urlStr;
        }
    }
}

//weiboType 注，只能传入分享的微博类型
-(NSString*)title:(WeiboType)weiboType
{
    NSMutableString *titleStr = [NSMutableString string];
    [titleStr appendString:@"#冲浪快讯# "];
    if (!_title || [_title isEmptyOrBlank]) {
        return titleStr;
    }
    
    switch (weiboType) {
        case kWeixin:
        case kWeiXinFriendZone:
        case kSinaWeibo:
        case kQQFriend:
        case kQZone:
        case kSMS:
        case kMore:
            if (_weiboSource == kWeiboData_BeautyCell) {
//                [titleStr appendString:@"【美女/帅哥】"];
            }
            else if(_weiboSource == kWeiboData_Energy) {
                [titleStr deleteCharactersInRange:NSMakeRange(0, titleStr.length)];
                if (_energyValue >= 0) {
                    [titleStr appendFormat:@"【正能量值%@点】 ",@(_energyValue)];
                    _picture = [UIImage imageNamed:@"positive_energy_News"];
                }
                else {
                    [titleStr appendFormat:@"【负能量值%@点】 ",@(_energyValue)];
                    _picture = [UIImage imageNamed:@"negative_energy_News"];
                }
            }
            [titleStr appendFormat:@"《%@》",_title];
            break;
        default:
            break;
    }
    return titleStr;
}
-(NSString*)content:(WeiboType)weiboType
{
    NSMutableString *content = [NSMutableString string];
    if([_desc length] > 0) {
        [content appendFormat:@"%@ ", _desc];
    }
    return content;
}
-(NSString*)newsUrl:(WeiboType)weiboType
{
    NSMutableString *url = [NSMutableString string];
    if (!_url || [_url isEmptyOrBlank]) {
        return url;
    }
    
    
    if (_weiboSource == kWeiboData_BeautyCell) {
        // 不分享URL
        return url;
    }
    else if (_weiboSource == kWeiboData_Gallery) {
        // 图集分享URl
        [url appendFormat:@"http://go.10086.cn/picTouch.do?method=second&id=%@",_url];
    }
    else if (_weiboSource == kWeiboData_Content){
        [url appendString:_url];
    }
    else {
        [url appendString:_url];
    }
    
    return url;
}
@end
