//
//  RecommendSubsChannelView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-8-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "SubsChannelsManager.h"
#import "AppSettings.h"

/**
 SYZ -- 2014/08/11
 初次使用时有可能出现的推荐订阅view
 RecommendSubsChannelView使用UIScrollView为承载view
 以3个RecommendSubsChannelItem一行的形式排列在UIScrollView上
 最后加上一个提交按钮
 */
@interface RecommendSubsChannelItem : UIControl
{
    UIImageView *iconView;
    UIImageView *selectView;
    UILabel *nameLabel;
}

@property(nonatomic, strong) SubsChannel *subsChannel;

- (void)applyTheme;

@end

@interface RecommendSubsChannelView : UIView <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    UIButton *commitButton;
    UIImageView *titleView;
    UILabel *titleLabel;
}

- (void)loadScrollView:(NSArray*)array;
- (void)applyTheme;

@end
