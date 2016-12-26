//
//  PhoneHotRootcontrollerViewController.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-5-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "PhoneHotChannelGridView.h"
#import "HotChannelsScrollScreenView.h"
#import "BgScrollView.h"
#import "ImageLoadModelView.h"
#import "PopMenuView.h"
#import "PhoneWeiboController.h"
#import "WeatherManager.h"
#import "Header.h"
#import "TouchView.h"
@class WeatherView;
@class FutureWeatherView;


@protocol HotChannelItemViewDelegate <NSObject>

- (void)channelItemDidSelected:(HotChannel*)channel;

@end

@interface HotChannelItemView : UIView <UIGestureRecognizerDelegate>
{
    UILabel *channelItemLabel;
    HotChannel *hotChannal;
    BOOL isNightMode;
    UIImageView *isnewView;
    NSInteger itemIdx;
}

@property(nonatomic, weak) id<HotChannelItemViewDelegate> delegate;
@property(nonatomic, strong) HotChannel *hotChannal;

- (id)initWithFrame:(CGRect)frame controller:(id)controller;
- (void)setItemSelected;
- (void)setItemUnselected;
- (void)applyTheme:(BOOL)isNight;
- (void)setItemIsNew:(HotChannel *)hotChannal;
- (void)setImageView:(BOOL)show;
@end

@interface HotChannelScrollView : UIView
{
    UIImageView *baImageView;
    UIScrollView *scrollView;
    UIView *selectedView;
    __weak HotChannelItemView* _itemView;
    BOOL isNightMode;
}

@property(nonatomic, strong) NSArray *channelArray;

+(CGFloat)fitHeight;

- (void)reloadViewWithArray:(NSArray*)array controller:(id)controller;
- (void)setSelectedImageWithTag:(NSInteger)tag;
//在gridView上点击时滑动的特定位置
- (void)scrollToTheLocationWhenClickGridView:(NSInteger)tag;
- (void)applyTheme:(BOOL)isNight;

@end


//用来指示上一次从新闻Tab首页跳至其他画面的用途
//当从其他画面再次跳回新闻Tab首页时，会根据不同的
//情况执行不同的操作
typedef enum
{
    PhoneHotRootDisapperPurposeUnknown = 0,
    PhoneHotRootDisapperPurposeOpenThread,
    PhoneHotRootDisapperPurposeSelectCity,
    PhoneHotRootDisapperPurposeSelectLocalCityNew,// 本地城市新闻
    //add more
} PhoneHotRootDisapperPurpose;


@interface PhoneHotRootController : PhoneWeiboController<HotChannelItemViewDelegate, PhoneHotChannelGridViewDelegate, HotchannelScrollDelegate, PhoneHotChannelGridViewDataSource,
    UIGestureRecognizerDelegate, CityIdChangeDelegate>
{
//    UIImageView *logoImageView;//现在改成按钮
    UIButton *refreshBtn;
    UIImageView *expandButtonBg;
    HotChannelScrollView *headerScrollView;
    UIButton *expandButton;
    UIButton *unexpandButton;
    PhoneHotChannelGridView *gridView;
    HotChannelsScrollScreenView *hotScrollView;
    NSMutableArray* threads;
    HotChannel *currentHotChannel;
    SubsChannel *currentSubsChannel;
    WeatherView *weatherView;
    FutureWeatherView *futureWeatherView;
    
    UIImageView *topImageView;
    UILabel *allChannelsLabel;
    UILabel *clickChannelLabel;
 
    BgScrollView  *popBgView;
    PopMenuView  *_popMenu;       // 弹出菜单
    
    UIImageView *isnewView;
    
    BOOL _isLocalNewsCityChanged;   // 本地新闻省市发生改变
    
    
    UIControl *_localNewsNotMatch;
}
//-(void)requestHotChannels:(HotChannel *)channel;
-(void)requestHotChannelsList;
-(void)selectChannelFromSpalshWithChannelId:(long)channelId;
-(void)enterSelectLocalNewsCities; 

//added by yuleiming 2013-8-2
@property(nonatomic)PhoneHotRootDisapperPurpose disappearPurpose;

@end