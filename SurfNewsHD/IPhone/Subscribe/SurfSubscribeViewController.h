//
//  SurfSubscribeViewController.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-24.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubsChannelsManager.h"
#import "AddSubscribeController.h"
#import "RecommendSubsChannelView.h"


@class SubsChannelsView;
@interface SurfSubscribeViewController : PhoneSurfController
{
    UIView *_topVLine;      // 分割线
    UIButton *_addSubsChannelBtn;
    SubsChannelsView *_subsChannelsView;
    RecommendSubsChannelView *recommendView;
    NSMutableArray *recommendChannels;
}
- (void)addSubschannelClick:(id)sender;
- (void)commitRecommendController;

@end