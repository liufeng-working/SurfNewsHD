//
//  SNThreadViewer.h
//  SurfNewsHD
//
//  Created by yuleiming on 14-7-3.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneShareView.h"
#import "SNToolBar.h"

@class SNThreadViewer;
@class ThreadContentImageInfoV2;
@class ThreadContentResolvingResultV2;

/**
 帖子内容展示控件状态
 */
typedef enum {
    SNViewerStateIdle,         //闲置状态。必须经由此状态转入SNViewerStateLoading状态
    SNViewerStateLoading,      //载入中，即将转入SNViewerStateLoaded状态
    SNViewerStateLoaded,       //已载入。注意，对于WebView而言，即使网页载入失败也算作SNViewerStateLoaded
                                //特别的，对于正文帖，hmlt dom就绪后就表示SNViewerStateLoaded
    SNViewerStateRecycling     //回收中，即将转入SNViewerStateIdle状态
} SNViewerState;

/**
 仅适用于正文模式
 */
typedef enum {
   
    SNThreadViewerEventViewSource,              // 查看原文点击事件
    SNThreadViewerEventImageClicked,            // 正文图片点击事件
    SNThreadViewerEventRelativeLinkClicked,     // 相关推荐链接点击事件
    SNThreadViewerEventAdLinkClicked,           // 广告链接点击事件
    SNThreadViewerEventActivityShareClicked,    // 活动分享点击事件
    SNThreadViewerEventShareSelectText,         // 选中文字分享点击点击
    SNThreadViewerEventShareNews,               // 分享新闻
    SNThreadViewerEventRssSubscribe,            // rss订阅
    SNThreadViewerEventRssClicked,              // rss点击
    SNThreadViewerEventEnterRssChannel,         // 进入RSS订阅频道
    SNThreadViewerEventDissertationClicked,     // 专题新闻被点击
    SNThreadViewerEventBodyImageClicked,        // 新闻正文图片点击事件
    
} SNThreadViewerEvent;

/********************************************************************
                            帖子viewer回调
 *******************************************************************/
@protocol SNThreadViewerDelegate <NSObject>

@required

/**
 加载状态改变后的回调
 */
-(void)snThreadViewerStateChanged:(SNThreadViewer*)v;

/**
 新闻图片下载成功
 仅针对于正文模式
 */
-(void)snThreadViewer:(SNThreadViewer*)v newsImageDownloaded:(ThreadContentImageInfoV2*)info;

/**
 观察者处理特殊事件
 */
-(void)snThreadViewer:(SNThreadViewer*)v eventOccurred:(SNThreadViewerEvent)evt withInfo:(id)info;

// 检查goBack和goForward状态
-(void)snThreadViewerCheckGoBackOrGoForward:(SNThreadViewer*)v;

// 显示正负能量窗口
-(void)snShowEnergyView;

// 设置标题
-(void)snSetUrlNewsTitle:(NSString*)title;

// 隐藏字体设置
-(void)snHiddenFontSizeView:(BOOL)isHidden;

// 底部工具栏类型发生改变
-(void)snToolsBarTypeChanged:(SNToolBarType)toolBarType
                   isCollect:(BOOL)isC;

// 底部工具栏是否显示
-(void)snToolsBarVisible:(BOOL)isShow;




@end


/**
 帖子展示控件
 */
@interface SNThreadViewer : UIView <UIWebViewDelegate, UIScrollViewDelegate>

/**
 获取当前加载状态
 */
-(SNViewerState)viewerState;

/**
 获取当前展示（或载入中）的帖子
 当状态为Idle或Recycling时返回nil
 */
-(ThreadSummary*)thread;

/**
 加载帖子
 @idx:帖子在帖子列表中的索引，如果只有一个帖子，传0
 */
-(void)loadWithThread:(ThreadSummary*)t
            isCollect:(BOOL)isCollect;

/**
 在销毁前手动调用以释放内存
 */
-(void)cleanResourceForDealloc;

/////////用于显示纯网页帖子时使用////////
-(void)goBack;
-(BOOL)canGoBack;
-(BOOL)canGoForward;
-(BOOL)isWebViewLoading;
-(void)stopWebViewLoading;
-(void)refresh;
// 刷新正负能量值
-(void)refreshEnergy:(long)energyScore;

/////////用于正文帖子时使用/////////
-(ThreadContentResolvingResultV2*) threadResolvingResult;

// 设置字体大小
- (void)setWebViewFontSize:(float)fontSize;

// 网页中用户选择的内容
-(NSString*)userSelectContent;

/**
 设置观察者
 */
@property(nonatomic, weak) id<SNThreadViewerDelegate> delegate;

/**
 是否在页面底部
 */
@property(nonatomic, readonly) BOOL isAtBottom;

// 赞、踩 动画图片
@property (nonatomic, strong) NSMutableArray *upImages;
@property (nonatomic, strong) NSMutableArray *downImages;

@end
