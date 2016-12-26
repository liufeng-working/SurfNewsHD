//
//  PhotoCollectionListHorizontalScrollView.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-12.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoCollectionChannel;
@class PhotoCollectionListView;
@class PhotoCollectionManager;

@interface PhotoCollectionListHorizontalScrollView : UIView <UIScrollViewDelegate>{
    UIScrollView *_horizontalScrollView;
    
    NSUInteger _curIndex;
    PhotoCollectionListView *_subView1;
    PhotoCollectionListView *_subView2;
    PhotoCollectionListView *_subView3;
    
    
    __weak PhotoCollectionManager *_pcm;

}
// 状态值，用来指示图集频道列表是否刷新结束。(目的是在刷新图集频道列表的时候，其它频道不做刷新，等待刷新结束)
@property(nonatomic,getter = isPCCLRefreshEnd) BOOL pcclRefreshEnd;// 默认为NO

// 通过图集频道加载数据
- (void)reloadDataWithPhotoCollectionChannel:(PhotoCollectionChannel*)pcc;

// 图集频道列表刷新完，使用这个函数（会根据刷新时间间隔来决定是否需要刷新图集列表）
- (void)refreshCurrentPhotoCollectionListAfterPCCLRefreshEnd;

// 重新加载当前图集频道数据
- (void)reloadCurrentPhotoCollectionChannel;

// 当前视图显示的频道
-(PhotoCollectionChannel*)currentViewShowPCC;

// 频道顺序发生改变
- (void)photoCollectionChannelOrderChanned:(PhotoCollectionChannel*)curPcc;

@end
