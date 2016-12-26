//
//  RecommendSubsChannelController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-8-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "SubsChannelsManager.h"
#import "AppSettings.h"

@interface RecommendSubsChannelItem : UIControl
{
    UIImageView *iconView;
    UIImageView *selectView;
    UILabel *nameLabel;
}

@property(nonatomic, strong) SubsChannel *subsChannel;

- (void)applyTheme;

@end

@interface RecommendSubsChannelController : PhoneSurfController <UIScrollViewDelegate>
{
    UIScrollView *scrollView;
    NSMutableArray *channelsArray;
}

@end
