//
//  UpdateSplashResponse.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"
#import "ThreadSummary.h"

//[DataContract]
//public class UpdateSplashResponse : SurfResponseBase
//{
//    [DataMember(Name = "startscreen")]
//    public SplashData StartScreen { get; set; }
//}


//开机画面的新闻帖子不能混杂存放在热推频道中（因为会在刷新新帖时被当做过期帖而删除）
//所以单独定义一种类型，以便处理其特殊的路径
@interface SplashNewsThreadSummary : ThreadSummary
@end

@interface SplashData : NSObject


@property(nonatomic,strong) NSString* newsstart;      //新闻开始时间
@property(nonatomic,strong) NSString* newsend;        //新闻结束时间
@property(nonatomic,strong) NSString* newsImage;      //新闻图片地址
@property(nonatomic,strong) NSString* newsTitle;      //开机画面图片标题
@property(nonatomic,strong) NSString* desc;             //开机画面图片描述
@property(nonatomic,strong) NSString* color;          //文字颜色,形如#99CC33
@property NSInteger openType;             //新闻图片打开用途
                                    //0-跳转到某条新闻正文
                                    //1-跳转到某个热推栏目
                                    //2-跳转到期刊订阅中心
                                    //3-跳转某个url
//////////////openType == 0
@property(nonatomic,strong) SplashNewsThreadSummary* infoNews;

//////////////openType == 1
@property long jumpId;  //跳转栏目id

//////////////openType == 2
//无特殊字段

//////////////openType == 3
@property(nonatomic,strong) NSString* jumpUrl;        //新闻跳转url




- (BOOL)isEqualToSplashData:(SplashData*)object;

@end



@interface UpdateSplashResponse : SurfJsonResponseBase

@property(nonatomic,strong) SplashData* startscreen;

@end
