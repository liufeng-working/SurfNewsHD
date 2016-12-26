//
//  SNToolBar.h
//  SurfNewsHD
//
//  Created by yuleiming on 14-7-11.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareMenuView.h"

@protocol SNToolBarDelegate <NSObject>

@required

-(void)toolBarActionFontSizeChanged:(float)size;

-(void)toolBarActionRefresh;

-(void)toolBarActionReport:(ThreadSummary *)ts;

- (void)toolBarActionEnergy:(ThreadSummary *)ts;

-(NSString*)toolBarActionGetWeiboContent; // 获取微博内容
-(NSMutableArray*)getContentImgArr;//获取正文图片
-(void)toolBarGotoLogin; // 进入登陆界面

@optional
- (void)toolBarActionBelleGirlDown:(ThreadSummary *)ts;

// 美女频道更多菜单  不喜欢 + 举报
- (void)toolBarActionBelleMore:(ThreadSummary *)ts;

- (void)toolBarActionLikeBelleGirl:(ThreadSummary *)ts;

- (void)toolBarActionExit;

- (void)toolBarActionShare:(ThreadSummary *)ts;

// 工具栏新闻评论
- (void)toolBarActionNewComment:(ThreadSummary *)ts;
@end


typedef enum {
    SNToolBarTypeNews,          //正文类型        评论|正能量|分享|收藏|更多
    SNToolBarTypeWeb,           //纯网页类型      评论|正能量|分享|收藏|更多
    SNBelleGirlType             //美女频道专用       返回|分享|点赞|下载|更多
} SNToolBarType;

@interface SNToolBar : UIView

@property(nonatomic,assign) BOOL isMySelect;//是否点击

@property(nonatomic,assign) BOOL isCollect;//是否收藏
/**
 初始化
 */
-(id)initWithToolBarType:(SNToolBarType)type
                  thread:(ThreadSummary*)ts;

/**
 修改工具栏类型
 */
-(void)changeBarType:(SNToolBarType)type thread:(ThreadSummary*)ts;

// 刷新工具栏
-(void)refreshToolsBar;

// 刷新评论按钮
-(void)refreshCommentItem;

- (void)refreshToolsBarWithSelectThread:(ThreadSummary *)selectThread;

// 获取toolBar类型
-(SNToolBarType)toolBarType;
/**
 获取normal状态下的高度
 */
+(CGFloat)normalHeight;


//info是活动分享构造的对象
-(void)setShareType:(ShareWeiboType)type withInfo:(id)info;
-(void)setShareType:(ShareWeiboType)type energy:(long)value;
/**
 设置观察者
 */
@property(nonatomic,weak) id<SNToolBarDelegate> deletage;

//是否需要增加收藏按钮    by Jerry
@property (nonatomic, assign)BOOL isShowCollectButton;

// 工具栏美女点赞按钮更新
- (void)setLikeGirlBt;

// 显示字体设置界面
- (void)showFontsSettingView;

@end
