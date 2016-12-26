//
//  AddSubscribeController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhoneSurfController.h"
#import "AddSubscribeView.h"
#import "SubsChannelsManager.h"
#import "SubsChannelsListResponse.h"
#import "SubsChannelSummaryViewController.h"
#import "SearchChannelController.h"
#import "SearchBoxControl.h"
#import "SNLoadingMoreCell.h"

/**
 SYZ -- 2014/08/11
 AddSubscribeController添加RSS订阅
 分为左右两个UITableView
 左UITableView的数据源是RSS的分类,使用CategoryViewCell作为cell
 右UITableView的数据源是各个分类下的频道,使用AddSubscribeCell作为cell
 */

@interface CategoryViewCell : UITableViewCell
{
    UIView *cellBg;
    UILabel *categoryLabel;
    UIImageView *divideLine;
    
    BOOL isNightMode;
}

- (void)loadCategory:(NSString*)cate;
- (void)applyTheme:(BOOL)isNight;

@end

@interface AddSubscribeController : PhoneSurfController <UITableViewDelegate, UITableViewDataSource, AddSubscribeViewDelegate, UIAlertViewDelegate>
{
    SearchBoxControl *searchBoxControl;
    
    UIImageView *cateTableViewBg;
    UITableView *cateTableView;
    AddSubscribeView *subscribeView;
    NSIndexPath *currentIndexPath;
    NSMutableArray *allChannelsArray;
    CategoryItem *selectItem;
    
    BOOL isNightMode;
    BOOL isLoadingMore;
}

@property(nonatomic, strong) NSMutableArray *catesArray;

@end
