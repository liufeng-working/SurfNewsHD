//
//  subsChannelContentView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"

@class SubsChannel;


// 订阅频道内容窗口
@interface subsChannelContentView : UIView<UITableViewDataSource,UITableViewDelegate>{
    __weak SubsChannel *_subsChannel;
    UITableView *_subsContentTableView;
    LoadingView *_headerLoadingView;
    NSMutableArray *_channelContentArray; // 订阅频道的内容数组
}


// 加载订阅频道
- (void)reloadSubsChannel:(SubsChannel*)sc;
- (void)setScrollOfThread:(ThreadSummary *)thread;
@end
