//
//  SubsThreadSummaryViewController.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-31.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "subsChannelContentView.h"
#import "PhoneSurfController.h"
#import "SubsChannelsListResponse.h"

typedef enum {
    SubsChannelSummaryDownload = 0,     //订阅栏目下载模式
    SubsChannelSummarySubs = 1          //订阅栏目订阅或取消订阅
} SubsChannelSummaryStyle;

typedef enum {
    subsChannelContent = 0,         // 正文点击RSS过来
    subsChannelCommon = 1
} SubsChannelFromStyle;

@interface SubsChannelSummaryViewController : PhoneSurfController< UIAlertViewDelegate>
{
    SubsChannelSummaryStyle style;
    UIButton *orderButton;
    SubsChannelFromStyle stl;
}

@property(nonatomic,strong) SubsChannel* subsChannel;

- (id)initWithStyle:(SubsChannelSummaryStyle)style_;
- (void)setSubsFromStyle:(SubsChannelFromStyle)subsStyle;

@end
