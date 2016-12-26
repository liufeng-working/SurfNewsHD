//
//  PhoneshareWeiboInfo.h
//  SurfNewsHD
//
//  Created by XuXg on 15/1/14.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

// 微博布局风格
typedef NS_ENUM(NSInteger, WeiboViewLayoutModel) {
    
    kWeiboView_Center,      // 居中列表风格
    kWeiboView_Bottom,      // 底部列表风格
    
    // Other 如果需要其他风格，自己添加和实现相应的代码
};

//分享到QQ好友还是QQ空间
typedef NS_ENUM(NSInteger,LFShareToQQ){
    LFShareToQQfriend     = 0,   //分享到QQ好友
    LFShareToQZone,              //分享到QQ空间
};


// 分享微博类型
typedef NS_ENUM(NSInteger, WeiboType) {
    kWeixin             = 1,          // 微信好友
    kWeiXinFriendZone   = 1<<1,       // 朋友圈
    kSinaWeibo          = 1<<2,       // 新浪微博
    kQQFriend           = 1<<3,       // QQ好友
    kQZone              = 1<<4,       // QQ空间
    kSMS                = 1<<5,       // 短信
    kPasteboard         = 1<<6,       // 复制到剪切板
    kMore               = 1<<7,       // 更多
    
    kAllWeiboType = (kWeixin|kWeiXinFriendZone|kSinaWeibo|kQQFriend|kQZone|kSMS|kPasteboard|kMore),
};

// 分享数据来源（就是从什么地方分享的）
// 根据来源，生成特定规则的内容
typedef NS_ENUM(NSInteger, WeiboDataSource)
{
    kWeiboData_BeautyCell,      // 美女频道分享
    kWeiboData_Gallery,         // 图集分享
    kWeiboData_Content,         // 正文分享
    kWeiboData_userCenter,      // 用户中心
    kWeiboData_Energy           // 正负能量
};

// 微博分享数据
@interface PhoneshareWeiboInfo : NSObject

@property(nonatomic,retain)UIImage *picture;        // 图片分享
@property(nonatomic) WeiboType showWeiboType;       // defalut all type
@property(nonatomic,strong)UIColor *weiboBGColor;   // 默认 0.5 半透明黑色

@property(nonatomic,readonly)WeiboDataSource weiboSource;

@property(nonatomic,strong)id userData;

// 初始化微博数据
// note:WeiboDataSource 会根据不同的微博类型，返回不一样的title，desc和URL
// 这个类型会根据不同的业务来增加，规则也是根据不同业务来增加的
-(id)initWithWeiboSource:(WeiboDataSource)source;

-(void)setWeiboTitle:(NSString*)title
                desc:(NSString*)desc
                 url:(NSString*)url;

// 如果有ThreadSummer这个参数，就不用在调用上面的函数
-(void)setThread:(ThreadSummary *)thread isShareEnergy:(BOOL)isEn;

//weiboType 注，只能传入分享的微博类型
-(NSString*)title:(WeiboType)weiboType;
-(NSString*)content:(WeiboType)weiboType;
-(NSString*)newsUrl:(WeiboType)weiboType;

@end