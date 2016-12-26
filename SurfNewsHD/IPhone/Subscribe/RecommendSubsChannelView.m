//
//  RecommendSubsChannelView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-8-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "RecommendSubsChannelView.h"
#import "PathUtil.h"
#import "ImageDownloader.h"
#import "SurfSubscribeViewController.h"

#define ItemWidth     96.0f
#define ItemHeight    90.0f
#define MarginTop     12.0f
#define MarginLeft    16.0f

@implementation RecommendSubsChannelItem

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 36.0f) / 2, 20.0f, 36.0f, 36.0f)];
        [self addSubview:iconView];
        
        selectView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 46.0f) / 2, 15.0f, 46.0f, 46.0f)];
        [self addSubview:selectView];
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 67.0f, self.frame.size.width, 20.0f)];
        [nameLabel setTextAlignment:NSTextAlignmentCenter];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:12.0f];
        nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [self addSubview:nameLabel];
    }
    return self;
}

- (void)setSubsChannel:(SubsChannel *)channel
{
    _subsChannel = channel;
    
    nameLabel.text = channel.name;
    
    /**
     SYZ -- 2014/08/11
     服务器会返回一些列的推荐订阅
     根据isSelected的值判断是否勾选
     */
    if (_subsChannel.isSelected == 1) {
        selectView.image = [UIImage imageNamed:@"recommend_channel_select.png"];
    } else {
        selectView.image = nil;
    }
    
    NSString *imgPath = [PathUtil pathOfSubsChannelLogo:channel];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:imgPath]) { // 图片文件不存在
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:_subsChannel.ImageUrl];
        [task setUserData:_subsChannel];
        [task setTargetFilePath:imgPath];
        [task setCompletionHandler:^(BOOL succeeded, ImageDownloadingTask *idt) {
            if(succeeded && idt != nil && [idt.userData isEqual:_subsChannel]){
                UIImage *tempImg = [UIImage imageWithData:[idt resultImageData]];
                [iconView setImage:tempImg];
            }
        }];
        [[ImageDownloader sharedInstance] download:task];
    } else { //图片存在
        NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
        [iconView setImage:[UIImage imageWithData:imgData]];
    }
}

//SYZ -- 2014/08/11，改变选中状态
- (void)setSelectViewStatus
{
    if (_subsChannel.isSelected == 0) {
        _subsChannel.isSelected = 1;
        selectView.image = [UIImage imageNamed:@"recommend_channel_select.png"];
        nameLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
    } else if (_subsChannel.isSelected == 1) {
        _subsChannel.isSelected = 0;
        selectView.image = nil;
        if ([[ThemeMgr sharedInstance] isNightmode]) {
            nameLabel.textColor = [UIColor whiteColor];
        } else {
            nameLabel.textColor = [UIColor colorWithHexString:@"999292"];
        }
    }
}

- (void)applyTheme
{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        if (_subsChannel.isSelected == 1) {
            nameLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
        } else {
            nameLabel.textColor = [UIColor whiteColor];
        }
    } else {
        if (_subsChannel.isSelected == 1) {
            nameLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
        } else {
            nameLabel.textColor = [UIColor colorWithHexString:@"999292"];
        }
    }
}

@end

@implementation RecommendSubsChannelView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float titleViewHeight = 45.0f;
        float commitViewHeight = 70.0f;
        float offset = 0.0f;
        if (IOS7) {
            offset = 10.0f;
        }
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(MarginLeft, MarginTop + titleViewHeight + offset, self.bounds.size.width - 2 * MarginLeft, self.bounds.size.height - titleViewHeight - MarginTop - commitViewHeight - offset)];
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = NO;
        scrollView.bounces = YES;
        [self addSubview:scrollView];
        
        commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        commitButton.frame = CGRectMake(40.0f, self.bounds.size.height - 58.0f, 240.0f, 39.0f);
        [commitButton setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"]
                                forState:UIControlStateNormal];
        [commitButton setTitle:@"开始阅读" forState:UIControlStateNormal];
        [commitButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
        [commitButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [commitButton addTarget:self action:@selector(commitSubsChannel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:commitButton];
        
        titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, titleViewHeight + offset)];
        titleView.image = [UIImage imageNamed:[[ThemeMgr sharedInstance] isNightmode] ? @"navBg_night.png" : @"navBg.png"];
        [self addSubview:titleView];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, offset, kContentWidth - 20.f, titleViewHeight)];
        titleLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
        titleLabel.font = [UIFont boldSystemFontOfSize:22.0f];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"推荐订阅";
        [titleView addSubview:titleLabel];
    }
    return self;
}

//加载scrollView
- (void)loadScrollView:(NSArray*)array
{
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    scrollView.contentSize = CGSizeMake(self.bounds.size.width - 2 * MarginLeft,
                                        ItemHeight * (array.count / 3) + ((array.count % 3) == 0 ? 0 : ItemHeight));
    
    for (int i = 0; i < array.count; i ++) {
        float x = ItemWidth * (i % 3);
        float y = ItemHeight * (i / 3);
        RecommendSubsChannelItem *item = [[RecommendSubsChannelItem alloc] initWithFrame:CGRectMake(x, y, ItemWidth, ItemHeight)];
        [item setTag:1000 + i];
        [item setSubsChannel:[array objectAtIndex:i]];
        [item applyTheme];
        [item addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:item];
    }
    
    if (array.count == 0) {
        commitButton.enabled = NO;
    } else {
        commitButton.enabled = YES;
    }
}

//item的触摸点击事件
- (void)itemSelected:(id)sender
{
    RecommendSubsChannelItem *item = (RecommendSubsChannelItem*)[scrollView viewWithTag:[sender tag]];
    [item setSelectViewStatus];
}

//提交
- (void)commitSubsChannel
{
    SurfSubscribeViewController *controller = [self findUserObject:[SurfSubscribeViewController class]];
    if ([controller isKindOfClass:[SurfSubscribeViewController class]]) {
        [controller commitRecommendController];
    }
}

- (void)applyTheme
{
    titleView.image = [UIImage imageNamed:[[ThemeMgr sharedInstance] isNightmode] ? @"navBg_night.png" : @"navBg.png"];
    
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[RecommendSubsChannelItem class]]) {
            RecommendSubsChannelItem *item = (RecommendSubsChannelItem *)view;
            [item applyTheme];
        }
    }
    
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        self.backgroundColor = [UIColor colorWithHexString:@"2D2E2F"];
    } else {
        self.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
    }
}

@end
