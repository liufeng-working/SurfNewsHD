//
//  ThreadSummary.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    HotChannelThread=0,     // 热门类型新闻
    SubChannelThread,       // RSS订阅新闻
    ImageChannelThread      // 图片频道新闻
} ThreadModel;


// 1. 单图 1001 多图 1002 无图 1003
// 2. 广告大图 2001 广告小图 2002 (ios不支持广告下载小图 2003 广告下载大图 2004)
// 3. 专题有图片 3001 专题无图片 3002
typedef NS_ENUM(NSInteger, TSShowType)
{
    TSShowType_Image_Only = 1001,
    TSShowType_Image_mutable = 1002,
    TSShowType_Image_None = 1003,
    
    // 广告
    TSShowType_Adver_BigImage = 2001,
    TSShowType_Adver_SmallImage = 2002,
    
    // 专题
    TSShowType_Special_Image = 3001, // 专题有图片
    TSShowType_Special_None = 3002,  // 专题无图片
};


@class SNMultiImageUrl;
@class PeriodicalInfo;

@interface ThreadSummary : NSObject


@property NSInteger threadId;        // 新闻id
@property NSInteger isTop;           // 是否置顶。该属性只有对于热推频道的帖子有意义
@property(nonatomic) double time;  // 发布日期（since1970，单位为ms）
@property(nonatomic, strong) NSString *title;  // 标题
@property(nonatomic, strong) NSString *source; // 发布者
@property(nonatomic, strong) NSString *desc;   // 预览文字


// 1. 单图 1001 多图 1002 无图 1003
// 2. 广告大图 2001 广告小图 2002 (ios不支持广告下载小图 2003 广告下载大图 2004)
// 3. 专题有图片 3001 专题无图片 3002
@property TSShowType showType;          // 用于区分不同显示布局

//大图新闻showType=1003为无图模式，老版本可正常显示，
//新版本先判断showType=1003，再根据新增string型字段 bigImg=“1”才为大图新闻，大图新闻的图片地址取bannerUrl字段
@property(nonatomic) NSInteger bigImg;
@property(nonatomic,strong)NSString *bannerUrl;

@property (nonatomic) double updateTime;
@property(nonatomic, strong) NSString *newsUrl;  // 原始URL
@property(nonatomic, strong) NSString *contentUrl; //html分享网址
@property(nonatomic, strong) NSString *imgUrl;   // 预览图url
@property(nonatomic) long channelId;        // 所属的频道id

//打开方式
//  0. 默认正文模式。
//  1. 网页模式。
//  2. 调整图集(放弃)。
//  3. 跳转期刊(放弃)。
@property(nonatomic) NSInteger open_type;


//帖子类型：
//1-普通新闻；2-图片新闻banner；3-活动;
//王鹏凯解释 5 普通专题新闻 6 图片专题新闻 4好像也是微博
@property NSInteger type;
@property(nonatomic,strong) NSString *iconPath;  // 热点图片路径

// multiImgUrl新闻列表3张图
@property(nonatomic,strong) NSArray* multiImgUrl;

// 专题新闻
@property(nonatomic,strong) NSArray* special_list;

// added by xuxg on 2014.8.14 T+智能订阅字段
// referer在请求正文的时候要带给服务器的
@property(nonatomic,strong) NSString *referer;

// Rectype:0:快讯自有新闻，默认0,1：rss推荐新闻，2：T+推荐新闻
@property(nonatomic) NSInteger rectype;


//  热推T+新闻 ：
//    0 普通新闻（不是T+）
//    1 RSS T+新闻
//    2 自有新闻 T+
@property(nonatomic) NSInteger ctype;


// 跳转图集新增字段
@property(nonatomic,strong) NSString *channel_name; // 图集频道名


// 跳转期刊新增字段  by Jerry Yu
@property(nonatomic,strong) NSString *magazine_name;   //期刊名
@property(nonatomic)long is_energy;         //是否支持能量显示  “1”支持  "0"不支持
@property(nonatomic)long positive_energy;   //正能量总值
@property(nonatomic)long negative_energy;   //负能量总值



// 美女频道新增字段
// 图片尺度，1一级，2二级，3三级，4四级
@property(nonatomic)NSInteger imageScale;
@property(nonatomic)NSInteger intimacyDegree;   // 亲密度
@property(nonatomic,strong)NSString *imageTag;  // 图片标签，多个用英文逗号隔开
@property(nonatomic,strong)NSString *dm;        // 图片分辨率


// 新闻评论增加字段
@property(nonatomic)NSInteger isComment;            // 是否是评论新闻
@property(nonatomic)NSUInteger comment_count;       // 新闻评论总数

// 这个和open_Url关系，先判断
//webView字段，0:正文   1:url
@property(nonatomic)NSInteger webView;              // 是否用url方式打开

//=========本地属性===========
@property NSInteger channelType;                              /**所属的频道type
                                                               * 注：热门频道中的【热推】为0，其他热门频道为0
                                                               * 用户订阅频道原始数据中无此属性，认为固定为1
                                                               * 2014.05.13 姜俊解释  1：冲浪新闻  0 快讯新闻，  默认是快讯新闻 ，在相关推荐中都是快讯新闻
                                                               **/
@property BOOL isPicThread;                                     //本地属性。该帖子是否是图片新闻

//added by yuleiming 2014年04月29日
//本地属性。为了从本地读取帖子缓存时，能还原原始数组元素顺序，故添加此字段。
//仅对picThread有意义。数值越小，排得越靠前，默认为0
@property NSInteger picThreadOrder;

// 本地属性, 就是time 转成String   yyyy-MM-dd (不序列化)
@property(nonatomic,strong)NSString* timeStr;

@property(nonatomic,assign)ThreadModel  threadM;



// added by xuxg 2014.6.25
// 本地属性：在三屏滑动中，用来记录RSS订阅号，用来从CV返回刷新订阅状态,(不序列化)
@property(nonatomic)long rssId;
@property(nonatomic)long energyScore; // 发表正负能量值(不序列化)

@property(nonatomic)NSInteger belleGirl_report;
@property(nonatomic)NSInteger belleGirl_hate;

// 新增段子属性
@property (nonatomic, assign) NSInteger isBeauty;

@property (nonatomic, assign) NSInteger newsId;             // 新闻ID

@property (nonatomic, copy) NSString *content;              // 正文内容

@property (nonatomic, assign) NSInteger upCount;            // 顶数量

@property (nonatomic, assign) NSInteger downCount;          // 踩数量

@property (nonatomic, assign) NSInteger shareCount;         // 分享数量

@property (nonatomic, strong) NSArray *hot_comment_list;    // 热门评论，对象数组类型

@property (nonatomic, assign) BOOL uped;

@property (nonatomic, assign) BOOL downed;

- (BOOL)isEqualToThread:(ThreadSummary*)thread;

// 确保文件目录存在，必须threadId 是有效值
- (void)ensureFileDirExist;

//分享的链接
-(NSString *)buildActivityContentUrl;

// 只正对type==3(活动类型)创建新闻链接
- (NSString*)buildActivityNewUrl;

//获取webView 支持的类型
-(NSString *)getNowebpWithUrlString:(NSString *)urlString;


// 创建一个期刊对象
-(PeriodicalInfo*)buildPeriodical;

// 返回美女频道图片高度
-(CGFloat)getBeautyChannelImageHeight:(CGFloat)imageWidth;

-(void)saveToFile;

// 是否T+新闻
-(BOOL)isTPlusNews;

// 是否支持显示的类型
-(BOOL)isSupportShowType;

// 是否是专题
-(BOOL)isSpecialNews;

// 是否是Url方式打开
-(BOOL)isUrlOpen;

// 是否是大图类型(在新闻列表中使用)
-(BOOL)isBigImageType;

// 是否需要下载图片(在新闻列表中使用)
-(BOOL)isNeedLoadImage;

@end




//收藏帖子概要
@interface FavThreadSummary : ThreadSummary

@property(nonatomic) NSTimeInterval creationDate;   //创建时间(since1970,单位为ms)

-(id)initWithThread:(ThreadSummary*)thread;

@end


// multiImgUrl新闻列表3张图
//"multiImgUrl\":[{\"imgUrl\":\"http://go.10086.cn/surfnews/images/bannerNewsPic/img4edit_8046_20150811154909.jpg\"},{\"imgUrl\":\"http://go.10086.cn/surfnews/images/bannerNewsPic/img4edit_4165_20150811154909.jpg\"},{\"imgUrl\":\"http://go.10086.cn/surfnews/images/bannerNewsPic/img4edit_5014_20150811154910.jpg\"}]
@interface SNMultiImageUrl : NSObject


@property(nonatomic,strong) NSString* imgUrl;

@end

