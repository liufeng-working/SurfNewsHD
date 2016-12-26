//
//  NewsWebListView.h
//  SurfNewsHD
//
//  Created by apple on 13-1-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotChannelsThreadsResponse.h"
#import "RefreshWebView.h"
#import "LoadingView.h"
#import "PhoneNewsData.h"

@class  NewsWebListView;
@protocol NewsWebListViewDelegate
- (void)tableView:(NSObject *)item
   didSelectStyle:(WebViewLoadHtmlAnimate)style;
-(NSInteger)getCurrentIndex;

// 刷新频道内容
- (void)refreshChannels;
// 加载更多频道内容
- (void)downloadMoreChannels;
@end


@interface NewsWebListView : UIView<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *tableview;
    NSMutableArray *hotChannels;
    NSInteger currentIndex;

    LoadingView *headerView;
    LoadingView *footerView;
}
@property(nonatomic,strong) LoadingView *headerView;
@property(nonatomic,strong) LoadingView *footerView;
@property(nonatomic,weak) id<NewsWebListViewDelegate> delegate;
-(void)reloadChannels:(NSArray *)channels;
-(void)refreshCell;
-(void)cancelLoading;
@end
