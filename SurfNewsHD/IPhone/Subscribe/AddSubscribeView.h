//
//  AddSubscribeView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetSubsCateResponse.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "SubsChannelsManager.h"
#import "MagazineManager.h"
#import <AVFoundation/AVFoundation.h>
@class SubsChannel;
@class MagazineInfo;

/**
 SYZ -- 2014/08/11
 AddSubscribeView,添加RSS频道和期刊订阅以及搜索RSS频道都使用此列表视图
 因为添加RSS频道时,RSS频道列表只占屏幕的右半部分,所以这里的AddSubscribeView分为两种尺寸类型
 */

@protocol AddSubscribeCellDelegate <NSObject>

- (void)playAudioWhenAddSubs;

@end

//栏目和期刊订阅都可以使用的cell视图
@interface AddSubscribeCell : UITableViewCell
{
    UIImageView *iconBgImageView;
    UIImageView *iconImageView;
    UILabel *nameLabel;
    UIView *divideView;                    //搜索界面有分割线
    
    UIButton *addSubsButton;
    BOOL isSearch;
}

@property(nonatomic, weak) id<AddSubscribeCellDelegate> delegate;
@property(nonatomic, strong) SubsChannel *subsChannel;
@property(nonatomic, strong) MagazineInfo *magazine;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier search:(BOOL)search;
- (void)loadSubsInfo:(id)info;
- (void)applyTheme:(BOOL)isNight;

@end

//******************************************************************************

@protocol AddSubscribeViewDelegate <NSObject>

@optional
- (void)magazineSelected:(MagazineInfo*)magazine;
- (void)channelSelected:(SubsChannel*)channel;
- (void)searchSubsChannelByName;
- (void)viewScrolled;
- (void)loadMore;

@end
//栏目和期刊订阅都可以使用的列表视图
@interface AddSubscribeView : UIView <UITableViewDataSource, UITableViewDelegate, AddSubscribeCellDelegate>
{
    UITableView *tableView;
    UIView *footerView;
    UIButton *showAllResultButton;
    BOOL isSearch;
    BOOL isNightMode;
    
    AVAudioPlayer *player;
}

@property(nonatomic, weak) id<AddSubscribeViewDelegate> delegate;
@property(nonatomic, strong) NSArray *dataArray;
@property(nonatomic) BOOL showAllResult;

- (id)initWithFrame:(CGRect)frame search:(BOOL)search;
//加载该分类下的栏目
- (void)loadSubsCate:(NSArray *)array;
//加载搜索到的订阅栏目
- (void)loadSubsChannels:(NSArray *)array;
//加载期刊
- (void)loadMagazine:(NSArray *)array;
- (void)applyTheme:(BOOL)isNight;
//是否显示底部控件
- (void)showTableFooterView:(BOOL)show;

@end
