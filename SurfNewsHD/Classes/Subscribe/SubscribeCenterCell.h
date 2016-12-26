//
//  SubscribeCenterCell.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetSubsCateResponse.h"
#import "SubscribeImagePool.h"
#import "SubscribeCenterCellSubitem.h"


@class SubscribeCenterCell;

@protocol SubscribeCenterCellDelegate <NSObject>
@required
// 展开Cell通知
- (void)handleExpansionCell:(float)cellY expCell:(SubscribeCenterCell*)cell;

// 打开SubsChannelView
- (void)openSubsChannelView:(SubsChannel *)subsChannel;
@end




@interface SubscribeCenterCell : UITableViewCell<UIScrollViewDelegate,SubsCellSubitemClickObserver>{
    CategoryItem *_cateItem;
    UIPageControl *_pageCtrl;
    UIScrollView *_scrollView;
    UILabel *_categoryName;
    NSInteger _channelsCount;
    BOOL _isVisibleExpansionStr;// 是否显示扩展文字
    
    CGRect _expRect;
    CGPoint _beganPoint;
    
    BOOL _isExpansion;      // 是否展开
    UIButton *_expButton;   // 展开的Button
    NSIndexPath *_indexPath;
    
    UIView *_sepaView;              // 分割线
    UIImageView *_expTopLine;       // 展开后的顶部线
    UIImageView *_expBottomLine;    // 展开后底部线
}


@property(nonatomic,weak) id<SubscribeCenterCellDelegate> delegate;
@property(nonatomic,weak) SubscribeImagePool *imgPool;


+ (CGFloat)cellHeight;    //默认高度
+ (CGFloat)cellExtHeight; //展开高度

// 提供UIView类型的使用，不要在UITable中使用这种类型的初始化。
//+ (SubscribeCenterCell *)CreateCellWithFrame:(CGRect)frame isExpansion:(BOOL)isExp;

- (void)loadData:(NSIndexPath *)indexPath
        cateItem:(CategoryItem *)cateItem
     isExpansion:(bool)isExp;

-(void)setCellWillExpansion;


// 需要下载图片的订阅频道
- (NSArray*)needDownloadImageChannels;
- (void)updateImage:(SubsChannel*)channel image:(UIImage *)img;
- (BOOL)checkSubscribeState;   //  检查订阅状态  YES:发生改变，NO：没有改变
@end
