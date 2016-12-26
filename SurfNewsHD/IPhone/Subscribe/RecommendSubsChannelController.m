//
//  RecommendSubsChannelController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-8-13.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "RecommendSubsChannelController.h"
#import "PathUtil.h"
#import "ImageDownloader.h"

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
        nameLabel.textAlignment = UITextAlignmentCenter;
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
    
    if (_subsChannel.isSelected == 1) {
        selectView.image = [UIImage imageNamed:@"recommend_channel_select.png"];
    } else {
        selectView.image = nil;
    }
    
    NSString *imgPath = [PathUtil pathOfSubsChannelLogo:channel];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:imgPath]) { // 图片文件不存在
        ImageDownloadingTask *task = [ImageDownloadingTask new];
        [task setImageUrl:_subsChannel.imageUrl];
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

- (void)setSelectViewStatus
{
    if (_subsChannel.isSelected == 0) {
        _subsChannel.isSelected = 1;
        selectView.image = [UIImage imageNamed:@"recommend_channel_select.png"];
        nameLabel.textColor = [UIColor hexChangeFloat:@"AD2F2F"];
    } else if (_subsChannel.isSelected == 1) {
        _subsChannel.isSelected = 0;
        selectView.image = nil;
        if ([[ThemeMgr sharedInstance] isNightmode]) {
            nameLabel.textColor = [UIColor whiteColor];
        } else {
            nameLabel.textColor = [UIColor hexChangeFloat:@"999292"];
        }
    }
}

- (void)applyTheme
{
    if ([[ThemeMgr sharedInstance] isNightmode]) {
        if (_subsChannel.isSelected == 1) {
            nameLabel.textColor = [UIColor hexChangeFloat:@"AD2F2F"];
        } else {
            nameLabel.textColor = [UIColor whiteColor];
        }
    } else {
        if (_subsChannel.isSelected == 1) {
            nameLabel.textColor = [UIColor hexChangeFloat:@"AD2F2F"];
        } else {
            nameLabel.textColor = [UIColor hexChangeFloat:@"999292"];
        }
    }
}

@end

@implementation RecommendSubsChannelController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateRoot;
        channelsArray = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	self.title = @"推荐订阅";
    
    float commitViewHeight = 70.0f;
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(MarginLeft, self.StateBarHeight +  MarginTop, kContentWidth - 2 * MarginLeft, kContentHeight - self.StateBarHeight - MarginTop - kTabBarHeight - commitViewHeight)];
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = NO;
    scrollView.bounces = YES;
    [self.view addSubview:scrollView];
    
    UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    commitButton.frame = CGRectMake(40.0f, kContentHeight - kTabBarHeight - 58.0f, 240.0f, 39.0f);
    [commitButton setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"]
                           forState:UIControlStateNormal];
    [commitButton setTitle:@"开始阅读" forState:UIControlStateNormal];
    [commitButton setTitleColor:[UIColor whiteColor]
                      forState:UIControlStateNormal];
    [commitButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
    [commitButton addTarget:self action:@selector(commitSubsChannel) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:commitButton];
    
    [self loadRecommendSubsChannel];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![[AppSettings sharedInstance] boolForKey:BoolKeyShowSubsPrompt]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

//加载推荐订阅栏目
- (void)loadRecommendSubsChannel
{
    [[SubsChannelsManager sharedInstance] loadRecommendSubsChannelsWithCompletionHandler:^(NSArray *channels) {
        if (channels) {
            [channelsArray removeAllObjects];
            [channelsArray addObjectsFromArray:channels];
            [self loadScrollView];
        } else {

        }
    }];
}

//加载scrollView
- (void)loadScrollView
{
    [scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    scrollView.contentSize = CGSizeMake(kContentWidth - 2 * MarginLeft, ItemHeight * (channelsArray.count / 3));
    
    for (int i = 0; i < channelsArray.count; i ++) {
        float x = ItemWidth * (i % 3);
        float y = ItemHeight * (i / 3);
        RecommendSubsChannelItem *item = [[RecommendSubsChannelItem alloc] initWithFrame:CGRectMake(x, y, ItemWidth, ItemHeight)];
        [item setTag:1000 + i];
        [item setSubsChannel:[channelsArray objectAtIndex:i]];
        [item applyTheme];
        [item addTarget:self action:@selector(itemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [scrollView addSubview:item];
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
    NSMutableArray *commitChannels = [NSMutableArray new];
    
    for (SubsChannel *channel in channelsArray) {
        if (channel.isSelected == 1) {
            [commitChannels addObject:channel];
        } 
    }
    
    if (commitChannels.count == 0) {
        [PhoneNotification autoHideWithText:@"请至少选择一个订阅栏目"];
        return;
    }

    SubsChannelsManager *scm = [SubsChannelsManager sharedInstance];
    for (SubsChannel *channel in commitChannels) {
        [scm addSubscription:channel];
    }
    [scm commitChangesWithHandler:^(BOOL succeeded) {
        if (succeeded) {
            [[AppSettings sharedInstance] setBool:NO forKey:BoolKeyShowSubsPrompt];
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            [PhoneNotification autoHideWithText:@"订阅栏目失败,请重试"];
            [commitChannels removeAllObjects];
        }
    }];
}

#pragma NightModeChangedDelegate method
- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    for (UIView *view in scrollView.subviews) {
        if ([view isKindOfClass:[RecommendSubsChannelItem class]]) {
            RecommendSubsChannelItem *item = (RecommendSubsChannelItem *)view;
            [item applyTheme];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
