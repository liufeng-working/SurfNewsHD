//
//  HotRootController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-10.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "HotChannelsListResponse.h"
#import "HotChannelsThreadsResponse.h"
#import "HotChannelsManager.h"
#import "HotChannelsView.h"
#import "HotChannelGridView.h"
#import "HotInfomationInChannelView.h"
#import "LoadingView.h"

@protocol HotChannelItemViewDelegate <NSObject>

- (void)channelItemDidSelected:(HotChannel*)channel;

@end

@interface HotChannelItemView : UIView <UIGestureRecognizerDelegate>
{
    UIImageView *selectedImageView;
    UILabel *channelItemLabel;
    HotChannel *hotChannal;
}

@property(nonatomic, weak) id<HotChannelItemViewDelegate> delegate;
@property(nonatomic, strong) HotChannel *hotChannal;

- (id)initWithFrame:(CGRect)frame controller:(id)controller;
- (void)setItemSelected;
- (void)setItemUnselected;

@end

@interface HotChannelScrollView : UIView
{
    UIScrollView *scrollView;
}

- (void)reloadViewWithArray:(NSArray*)array controller:(id)controller;
- (void)setSelectedImageWithTag:(NSInteger)tag;

@end

@interface HotRootController : SurfNewsViewController<ReadThreadContentDelegate, HotChannelItemViewDelegate, HotChannelGridViewDataSource, HotChannelGridViewDelegate,LoadContentDelegate,NightModeChangedDelegate>
{
    HotChannelScrollView *headerScrollView;
    UIButton *operateGridViewButton;
    HotChannelGridView *gridView;
    HotChannelsView *leftNewsView;
    HotInfomationInChannelView *rightNewsView;
    NSMutableArray* threads;
    HotChannel *currentHotChannel;
    SubsChannel *currentSubsChannel;
    
    UIButton *weather_Guide;
}
-(void)requestHotChannels:(HotChannel *)channel;
-(void)requestHotChannelsList;

// 请求频道中的热门资讯
- (void)requestHotInfomation:(HotChannel *)channel;
@end
