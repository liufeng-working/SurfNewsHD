//
//  PhoneHotChannelGridView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotChannelsManager.h"
#import "HotChannelsListResponse.h"


//热推各个频道之间的距离
@interface ItemSpace : NSObject

@property(nonatomic) CGRect aRect;
@property(nonatomic) CGRect bRect;

@end

//******************************************************************************

//热推频道的各频道的视图
@interface HotChannelGridViewItem : UIControl
{
    UILabel *itemNameLabel;
    UIImageView *isnewView;
}

@property(nonatomic, strong) HotChannel *hotChannel;
- (void)applyTheme:(BOOL)isNight;
- (void)setCurrentItemBorder;
- (void)clickEvent;
- (void)setItemIsNewGrid:(HotChannel *)HotChannel;
@end

//******************************************************************************

@protocol PhoneHotChannelGridViewDataSource <NSObject>

- (NSInteger)gridViewCurrentIndex;

@end

@protocol PhoneHotChannelGridViewDelegate <NSObject>

- (void)gridViewItemClicked:(HotChannel*)hotchannel;

@end

@interface PhoneHotChannelGridView : UIView
{
    UIImageView *topImageView;
}

@property(nonatomic, weak) id<PhoneHotChannelGridViewDelegate> delegate;
@property(nonatomic, weak) id<PhoneHotChannelGridViewDataSource> dataSource;
@property(nonatomic, strong) NSMutableArray *hotChannelArray;
@property(nonatomic) float widthOfView;                                 //view的宽度
@property(nonatomic) float heightOfView;                                //view的高度
@property(nonatomic) float itemVerticalSpacing;                         //垂直cell之间的间距
@property(nonatomic) float itemHorizontalSpacing;                       //横向cell之间的间距
@property(nonatomic) NSInteger itemCountPerRow;                         //每行放置cell的最大个数
@property(nonatomic) UIEdgeInsets edgeInsets;                           //指定边缘值

- (void)reloadView;
- (void)applyTheme:(BOOL)isNight;

@end
