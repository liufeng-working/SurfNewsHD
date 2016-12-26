//
//  HotInfomationInChannel.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-2-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeatherView.h"
#import "HotChannelsView.h"


// 频道中的热门资讯
@interface HotInfomationInChannelView : UIView<UITableViewDelegate, UITableViewDataSource>{
    UIImage *_dottedLine;       // 虚线图片
    WeatherView* _weatherView;  // 天气视图
    UITableView* _tableView;
    NSMutableArray *_hotInfoArray;
    UIFont *_titleFont;
    UIFont *_detailFont;
    LoadingView *_headerView;
    LoadingView *_footerView;
}
@property(nonatomic) id<ReadThreadContentDelegate> readThreadDelegate;
@property(nonatomic,weak)id<LoadContentDelegate> refreshDelegate;
- (void)loadHotInfomationWithArray:(NSArray*)threadsSummary updateTime:(NSDate*)updateTime;
- (void)loadMoreThreadsSummary:(NSArray*)threadsSummary updateTime:(NSDate*)updateTime;
-(void)cancelLoading; // 取消加载

- (void)updateRefreshDate:(NSDate*)date;// 设置刷新时间
- (void)updateMoreDate:(NSDate*)date;   // 刷新更多的时间
@end