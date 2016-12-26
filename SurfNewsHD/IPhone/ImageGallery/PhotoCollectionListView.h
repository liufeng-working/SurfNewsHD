//
//  PhotoCollectionListView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoCollectionData.h"



@class LoadingView;
@interface PhotoCollectionListView : UIView<UITableViewDelegate, UITableViewDataSource>{
    UITableView *_photoCollectionTableView;
    LoadingView *_headerView;
    NSMutableArray *_pccListData;   // 帖子数组(图片帖子)
}

@property(nonatomic,readonly,retain) PhotoCollectionChannel *photoCollectionChannel;

// 加载数据
- (void)reloadDataWithPhotoCollectionChannel:(PhotoCollectionChannel*)pcc
                         photoCollectionList:(NSArray*)cList
                                 refreshDate:(NSDate*)date;


- (void)updateRefreshDate:(NSDate*)date;

// 滚动条的偏移坐标
- (void)scrollOffsetY:(float)y;

// 设置刷新状态
- (void)setRefreshState;
- (void)cancelRefreshState:(BOOL)animated;

// 检测图集频道内容是否发生改变
- (NSUInteger)photoCollectionCount;
@end
