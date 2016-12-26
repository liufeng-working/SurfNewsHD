//
//  HotChannelsView.h
//  SurfNewsHD
//
//  Created by apple on 13-1-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotChannelsThreadsResponse.h"
#import "HotBannerView.h"
#import "PictureThreadView.h"
#import "LoadingView.h"
#import "ThemeMgr.h"
#import "StockMarketThreadView.h"
#import "SNJokeCell.h"

// 读取帖子内容
@protocol ReadThreadContentDelegate <NSObject>
@required
- (void)readThreadContent:(id)sender threadSummary:(ThreadSummary *)thread;    // 读取帖子内容

//给财经频道头部的cell增加webUrl跳转
-(void)addStockUrlWithTag:(stockTag)tag;

@end

//NS_DEPRECATED_IOS(2_0, 3_0);
@interface HotChannelsView : UIView<UITableViewDataSource,UITableViewDelegate,StockMarketThreadViewDelegate,SNJokeCellDelegate>{
    UITableView *tableview;
    LoadingView *_headerView;
    HotBannerView* hotBannerView;
    NSMutableArray *_cellsModel;    // 帖子数组(图片帖子)
    NSMutableArray *_layouts;       // 段子频道的layout数组
    UILabel *_msgLabel;
    StockMarketThreadView *stockView;
    UIImageView *TPlusIcon;
    
    // 订阅
    __weak UIView *_subschannelEmptyV; // 没有定义的提示框
}
@property(nonatomic,readonly) HotChannel* hotChannel;
@property(nonatomic) id<ReadThreadContentDelegate> delegate;
@property(nonatomic) id<LoadContentDelegate> refreshDelegate;
@property(nonatomic, readonly) BOOL isLoading;
@property (nonatomic, assign) BOOL shared;      // 点击分享
@property (nonatomic, assign) BOOL commented;   // 点击评论

// 加载频道
- (void)reloadChannels:(HotChannel *)channel array:(NSArray *)channelsArray date:(NSDate *)refreshDate;
- (void)moreChannels:(HotChannel *)channel array:(NSArray *)channelsArray date:(NSDate *)refreshDate;

- (void)setLoadingState:(BOOL)isAciton;            // 设置加载状态
- (void)cancelLoadingState:(BOOL)animated;         // 取消加载状态

// 更新刷新时间
- (void)updateRefreshDate:(NSDate*)date;

// 设置滚动条的偏移位置
- (void)setScrollOffsetY:(float)y;
- (void)setScrollOfThread:(ThreadSummary *)thread;
@end



