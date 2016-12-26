//
//  HotChannelsScrollView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotChannelsView.h"
#import "SNThreadViewerController.h"
#import "PhoneBelleGirlViewController.h"

@protocol HotchannelScrollDelegate <NSObject>

@optional
- (void)hotchannelScrollChanged:(HotChannel*)hotchannel;
- (void)disapperPresentController;

// 新闻频道滚动距离
-(void)headerViewScrollPercent:(CGFloat)percent;

//增加财经频道顶部cell的webUrl跳转
-(void)addStockWebUrlWithTag:(stockTag)tag;

//下拉刷新时，刷新标志转动
-(void)refreshBtnRotationStart;

//刷新完成
-(void)refreshBtnRotationFinish;
@end

@interface HotChannelsScrollScreenView : UIView<UIScrollViewDelegate,ReadThreadContentDelegate,LoadContentDelegate>{
    UIScrollView *_scrollView;
    CGFloat _scrollBeginX;
}

@property(nonatomic,strong) id<HotchannelScrollDelegate> hotChannelChangedDelegate;


- (void)reloadHotChannels:(BOOL)isTop isReloadEqualHotchannel:(BOOL)isEqualHotChannel;

// 设置当前显示的热门帖子内容
- (void)setCurrentHotChannel:(HotChannel*)hotchannel;

// 当前展示的滚动试图
-(HotChannelsView*)curHotChannelsView;

// 刷新本地频道
-(void)refreshLocalChannel;


/**
 *  刷新当前频道
 */
-(void)refreshCurrentChannel:(void (^)())completion;
@end
