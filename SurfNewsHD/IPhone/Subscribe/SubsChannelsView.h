//
//  SubsChannelsView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "SubsChannelsManager.h"







@class UITableViewEditingOperateView;
@class SubsChannelsManager;
@interface SubsChannelsView : UIView<UITableViewDataSource, UITableViewDelegate,SubsChannelChangedObserver>{
    LoadingView *_topLoading;
    UITableView *_subsTableView;
    NSMutableArray *_tableVewDataSource;
    __weak SubsChannelsManager *_scm;
    int _updateState; // 更新状态
    
    UITableViewEditingOperateView *_editingOperateView;
    
    BOOL _isSimpleMode;
}

// 加载订阅频道列表
- (void)loadSubsChannelsList;

// 刷新订阅频道列表，满足一定的时间间隔
- (void)refreshSubsChannelsListForTimeInterval;
// 检查订阅频道是否发生改变,对改变的频道进行更新或删除操作
- (void)checkSubsChannelChanged;

// 取消加载状态
-(void)cancelLoadingState:(void (^)(BOOL finished))completion;

// EditingOperateView hidder
- (void)handleEditingOperateViewHidderEvent;

// 改变风格：添加一个简介模式风格
- (void)changeStyle;
@end
