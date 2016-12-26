//
//  ImageGalleryViewController.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-8-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhotoGalleryViewController.h"
#import "PhotoCollectionManager.h"
#import "PhotoCollectionData.h"
#import "PhotoGalleryChannelGridView.h"
#import "PhotoCollectionListHorizontalScrollView.h"
#import "UserManager.h"
#import "AppDelegate.h"
#import "OfflineDownloader.h"
#import "NetworkStatusDetector.h"
#import "UIAlertView+Blocks.h"
#import "FlowIndicatorViewController.h"

#define TopViewHeight  35.0f

@implementation PhotoGalleryViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateRoot;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"冲浪图集";

    
    // 添加底部菜单栏
    [self addBottomToolsBar];
    
    //因为动画要求,重新写了个头view
    titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, self.StateBarHeight)];
    titleView.image = [UIImage imageNamed:[[ThemeMgr sharedInstance] isNightmode] ? @"navBg_night.png" : @"navBg.png"];
    [self.view addSubview:titleView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 0.0f, kContentWidth - 20.f, self.StateBarHeight)];
    titleLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
    titleLabel.font = [UIFont boldSystemFontOfSize:22.0f];
    [titleLabel setTextAlignment:NSTextAlignmentLeft];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = @"冲浪图集";
    [titleView addSubview:titleLabel];
    
    // 离线下载按钮
    float offlineBtnWidth = 45.f;   //home_more.png分辨率的一半
    float offlineBtnHeight = 45.f;
    float offlineX = kContentWidth-offlineBtnWidth;
    UIButton *offlineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [offlineBtn setFrame:CGRectMake(offlineX, ([self StateBarHeight]-offlineBtnHeight)*0.5, offlineBtnWidth, offlineBtnHeight)];
    [offlineBtn setImage:[UIImage imageNamed:@"home_more.png"] forState:UIControlStateNormal];
    [offlineBtn addTarget:self action:@selector(showPopMenu) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:offlineBtn];
    
    // 分割线
    float lineH = 30.f;
    float lineY = ([self StateBarHeight]-lineH) * 0.5f;
    lineView = [[UIView alloc] initWithFrame:CGRectMake(offlineX, lineY, 1, lineH)];
    [lineView setBackgroundColor:[UIColor colorWithHexValue:0xFFDCDBDB]];
    [titleView addSubview:lineView];
    
    
    float channleViewHeight = 37.f;
    float tableRectY = [self StateBarHeight] + channleViewHeight;
    CGRect tableRect = CGRectMake(10.f, tableRectY, kContentWidth-10,
                                  kContentHeight-kToolsBarHeight-tableRectY-2.f);
    _pclhsView = [[PhotoCollectionListHorizontalScrollView alloc] initWithFrame:tableRect];
    [self.view addSubview:_pclhsView];
    
    headerView = [[PhotoGalleryHeaderView alloc] initWithFrame:CGRectMake(0.0f, self.StateBarHeight, kContentWidth, channleViewHeight)];
    [self.view addSubview:headerView];
    
    expandButtonBg = [[UIImageView alloc] initWithFrame:CGRectMake(kContentWidth - 45.0f, self.StateBarHeight, 45.0f, 37.0f)];
    [self.view addSubview:expandButtonBg];
    
    expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    expandButton.frame = CGRectMake(kContentWidth - 40.0f, self.StateBarHeight, 40.0f, 37.0f);
    [expandButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [expandButton addTarget:self
                       action:@selector(expandGridView:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:expandButton];
    
    PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];    
    
    // 没有图集频道列表数据，需要添加一个临时风火轮
    if (pcm.photoCollecChannelList.count == 0)
    {        
        UIActivityIndicatorViewStyle style = [ThemeMgr sharedInstance].isNightmode ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray;
        _hotwheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        _hotwheel.frame = CGRectMake((kContentWidth-40)/2,(kContentHeight-kTabBarHeight-[self StateBarHeight]-40)/2, 40, 40);;
        [_hotwheel startAnimating];
        [self.view addSubview:_hotwheel];
    }
    else {
        // 加载旧数据
        currentChannel = pcm.photoCollecChannelList[0];
        [_pclhsView reloadDataWithPhotoCollectionChannel:currentChannel];
        [headerView reloadViewWithPhotoChannelArray:pcm.photoCollecChannelList];
        [headerView setChannelSelectedWithTag:0];
    }

    if (IOS7) {
        titleLabel.frame = CGRectMake(10.f, 5.0f, kContentWidth - 20.f, self.StateBarHeight);
        [offlineBtn setFrame:CGRectMake(offlineX, ([self StateBarHeight]-offlineBtnHeight)*0.5+5, offlineBtnWidth, offlineBtnHeight)];
        lineView.frame = CGRectMake(offlineX, lineY+5, 1, lineH);

    }


    // 刷新图集频道列表
    // note:逻辑顺序，图集频道列表只会刷新一次（在程序生命周期内），在刷新图集频道列表的过程中不会刷新图集频道的，
    // 只有在刷新完成之后在开始刷新图集频道(目的，防止图集频道在服务端给删除了，也避免在同一时间端内，程序过多的处理业务关系)
    [self refreshPhotoCollectionChannelList];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if (currentChannel != nil)
    {
        // 从新加载当前频道
        [_pclhsView reloadCurrentPhotoCollectionChannel];        
    }
    
    titleView.userInteractionEnabled = YES;
}

#pragma mark 弹出菜单
- (void)showPopMenu
{
    float btnWidth = 170;          // 按钮宽度
    float menuHeight = [UserManager sharedInstance].loginedUser.userID? 3 * 44 + 15 : 2 * 44 + 15;
    CGRect menuRect = CGRectMake(kContentWidth-btnWidth - 10,
                                 kTabBarHeight - 10,
                                 btnWidth, menuHeight);
    
    if (!_popMenu)
    {
        _popMenu = [[PopMenuView alloc] initWithFrame:menuRect];
        [_popMenu setPopMenuViewDelegate:self];
    }
    
    if (!popBgView)
    {
        popBgView = [[BgScrollView alloc] initWithFrame:theApp.window.frame];
        [popBgView setBgSvDelegate:self];
        [popBgView setBackgroundColor:[UIColor clearColor]];
    }
    [popBgView addSubview:_popMenu];
    
    //    if(![self.view.subviews containsObject:popBgView])
    //    {
    //        [theApp.window addSubview:popBgView];
    [self.view addSubview:popBgView];
    //    }
    
    CGAffineTransform transform = _popMenu.transform;
    transform = CGAffineTransformScale(transform, 0.8f, 0.8f);
    _popMenu.transform = transform;
    
    [UIView animateWithDuration:0.05f animations:^
     {
         CGAffineTransform transform = _popMenu.transform;
         transform = CGAffineTransformScale(transform, 1.3f, 1.3f);
         _popMenu.transform = transform;
         
     } completion:^(BOOL finished) {
         [UIView animateWithDuration:0.05f animations:^{
             _popMenu.transform = CGAffineTransformIdentity;
         }];
         
     }];
}//

-(void)hidePopMenu
{
    if(popBgView && [popBgView.subviews containsObject:_popMenu])
    {
        [UIView animateWithDuration:0.08f animations:^{
            CGAffineTransform transform = _popMenu.transform;
            transform = CGAffineTransformScale(transform, 0.8f, 0.8f);
            _popMenu.transform = transform;
            
        } completion:^(BOOL finished) {
            [_popMenu removeFromSuperview];
            [popBgView removeFromSuperview];
            
            _popMenu = nil;
            popBgView = nil;
        }];
    }
}

- (void)cilickBgScrollView:(BgScrollView *)bgScroll{
    [self hidePopMenu];
}

#pragma mark PopMenuViewDelegate
- (void)clickMenuBt:(UIButton *)bt
{
    if (10 == bt.tag)
    {
        [self hidePopMenu];
        if ([[ThemeMgr sharedInstance] isNightmode])
        {
            [[ThemeMgr sharedInstance] changeNightmode:NO];
        }
        else
        {
            [[ThemeMgr sharedInstance] changeNightmode:YES];
        }
        
    }
    if (50 == bt.tag)
    {
        [self hidePopMenu];
        [self offlineDownloadClick:bt];
    }
    else if(100 == bt.tag)
    {
        [UIView beginAnimations:@"animationName" context:nil];
        [UIView setAnimationDuration:0.08]; //动画持续的秒数
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(showFlowIndicatorViewCrl)];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        CGAffineTransform transform = _popMenu.transform;
        transform = CGAffineTransformScale(transform, 0.8f, 0.8f);
        _popMenu.transform = transform;
        
        [UIView commitAnimations];
        
        
        [self showFlowIndicatorViewCrl];
    }
}

- (void)showFlowIndicatorViewCrl
{
    [self hidePopMenu];

    //流量
    FlowIndicatorViewController *flowIndicatorViewCrl = [[FlowIndicatorViewController alloc] init];
    [self presentController:flowIndicatorViewCrl animated:PresentAnimatedStateFromRight];
}

// 离线下载点击事件
-(void)offlineDownloadClick:(id)sender
{
    //TODO 离线下载
    [self hidePopMenu];
    
    NetworkStatusType type = [NetworkStatusDetector currentStatus];
    if (type == NSTNoWifiOrCellular || type == NSTUnknown)
    {
        [PhoneNotification autoHideWithText:@"当前没有网络连接!"];
    }
    else if(type == NST2G || type == NST3G || type == NST4G || type == NSTLTE)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"您尚未连接WiFi,选择继续将消耗您的流量,确定继续?" cancelButtonItem:
                              [RIButtonItem itemWithLabel:@"取消" action:
                               ^{
                                   
                               }] otherButtonItems:
                              [RIButtonItem itemWithLabel:@"确定" action:
                               ^{
                                   [self addTaskItem];
                               }], nil];
        [alert show];
    }
    else if(type == NSTWifi)
    {
        [self addTaskItem];
    }
}

- (void)addTaskItem
{
    NSMutableArray *arr0 = [PhotoCollectionManager sharedInstance].photoCollecChannelList;
    
    if (arr0 && arr0.count > 0)
    {
        for (PhotoCollectionChannel *pcC in arr0)
        {
            ImageGalleryTask *Task = [[ImageGalleryTask alloc] init];
            [Task setPhotoCChannel:pcC];
            [[OfflineDownloader sharedInstance] addDownloadTask:Task];
        }
    }

}

// 显示的图集频道发生改变
-(void)showPhotoCollectionChanged:(PhotoCollectionChannel*)pcc
{
    if (!pcc) { return; }
    
    currentChannel = pcc;    
    PhotoCollectionChannel *curPCC = [_pclhsView currentViewShowPCC];
    if (curPCC.cid != currentChannel.cid) {
        [_pclhsView reloadDataWithPhotoCollectionChannel:currentChannel];
    }
    else{
        // 还有一种特殊情况，就是频道顺序发生改变,还要一个一个的检查
        [_pclhsView photoCollectionChannelOrderChanned:pcc];        
    }

    
    
    PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
    NSInteger pccIndex = [[pcm photoCollecChannelList] indexOfObject:currentChannel];
    [headerView scrollToTheLocation:pccIndex];
    [headerView setChannelSelectedWithTag:pccIndex];
}


#pragma  mark SurfScrollExpandComplexViewDelegate


#pragma mark private method
- (void)reloadDate{
    
}

// 刷新图集频道列表
- (void)refreshPhotoCollectionChannelList{
    PhotoCollectionManager *pcm = [PhotoCollectionManager sharedInstance];
    [pcm refreshPhotoCollectionChannelList:^(BOOL succeeded,BOOL ischanned) {
        // 删除临时风火轮
        if (_hotwheel) {
            [_hotwheel stopAnimating];
            [_hotwheel removeFromSuperview];
            _hotwheel = nil;
        }
        
        if (succeeded && ischanned) {
            // todo 小司你自己写了。
            [headerView reloadViewWithPhotoChannelArray:pcm.photoCollecChannelList];
            [headerView setChannelSelectedWithTag:0];
            
            // 重新加载数据
            if (pcm.photoCollecChannelList.count > 0) {
                currentChannel = pcm.photoCollecChannelList[0];
                [_pclhsView reloadDataWithPhotoCollectionChannel:currentChannel];
            }
        }
        else{   // 刷新失败或没有频道更新
            // 加载之前的旧数据
            if (pcm.photoCollecChannelList.count > 0) {
                [_pclhsView reloadDataWithPhotoCollectionChannel:pcm.photoCollecChannelList[0]];
            }
            else{
                [PhoneNotification autoHideWithText:@"图集频道列表刷新失败"];
            }
        }
        
        _pclhsView.pcclRefreshEnd = YES;
        if (pcm.photoCollecChannelList.count > 0) {
            // 只刷新当前的图集列表
            [_pclhsView refreshCurrentPhotoCollectionListAfterPCCLRefreshEnd];
        }
    }];
}

#pragma mark NightModeChangedDelegate
-(void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
     titleView.image = [UIImage imageNamed:[[ThemeMgr sharedInstance] isNightmode] ? @"navBg_night.png" : @"navBg.png"];
    if (night) {
        expandButtonBg.image = [UIImage imageNamed:@"expand_hot_gridview_shadow_night.png"];
        titleView.backgroundColor = [UIColor colorWithHexString:@"2D2E2F"];
        lineView.backgroundColor = [UIColor colorWithHexValue:0xFF19191A];

    } else {
        expandButtonBg.image = [UIImage imageNamed:@"expand_hot_gridview_shadow.png"];
        titleView.backgroundColor = [UIColor whiteColor];
        lineView.backgroundColor = [UIColor colorWithHexValue:0xFFDCDBDB];

    }
    [headerView applyTheme];
    [_pclhsView viewNightModeChanged:night];
}

- (void)expandGridView:(UIButton*)button
{
    if (gridView) {
        return;
    }
    
    //搞死其他控件的触摸操作
    _pclhsView.userInteractionEnabled = NO;
    titleView.userInteractionEnabled = NO;
    headerView.userInteractionEnabled = NO;
    
    //注意，这里的singleFingerTap是个傀儡，它的处理函数中啥都不干
    //我们利用的是其delegate回调：- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
    //因为我们的需求是在触摸开始时就把展开的面板搞死，而不是在单击操作结束后
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    singleFingerTap.delegate = self;
    [self.view addGestureRecognizer:singleFingerTap];
    
    gridView = [PhotoGalleryChannelGridView new];
    gridView.delegate = self;
    gridView.dataSource = self;
    gridView.widthOfView = kContentWidth;
    gridView.edgeInsets = UIEdgeInsetsMake(10.0f, 5.0f, 10.0f, 5.0f);
    gridView.itemHorizontalSpacing = 10.0f;
    gridView.itemVerticalSpacing = 5.0f;
    gridView.itemCountPerRow = 4;
    gridView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:gridView];
    [gridView applyTheme:[[ThemeMgr sharedInstance] isNightmode]] ;
    
    topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, self.StateBarHeight, kContentWidth, 37.0f)];
    UIImage *image = [UIImage imageNamed:[[ThemeMgr sharedInstance] isNightmode] ? @"hot_gridview_bg_night.png" : @"hot_gridview_bg.png"];
    [topImageView setImage:[image stretchableImageWithLeftCapWidth:1.0f topCapHeight:0.0f]];
    topImageView.alpha = 0.0f;
    [self.view addSubview:topImageView];
    
    collapseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    collapseButton.alpha = 0.0f;
    collapseButton.frame = CGRectMake(kContentWidth - 40.0f, [self StateBarHeight], 40.0f, 37.0f);
    [collapseButton setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    collapseButton.transform = CGAffineTransformRotate(collapseButton.transform, M_PI);
    [collapseButton addTarget:self
                       action:@selector(collapseGridView:)
             forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:collapseButton];
    
    allChannelsLabel = [[UILabel alloc] initWithFrame:CGRectMake(-180.0f, self.StateBarHeight + 5.0f, 60.0f, 25.0f)];
    allChannelsLabel.text = @"所有频道";
    allChannelsLabel.font = [UIFont systemFontOfSize:15.0f];
    allChannelsLabel.backgroundColor = [UIColor clearColor];
    allChannelsLabel.textColor = [UIColor colorWithHexString:@"AD2F2F"];
    [self.view addSubview:allChannelsLabel];
    
    clickChannelLabel = [[UILabel alloc] initWithFrame:CGRectMake(-100.0f, self.StateBarHeight + 5.0f, 100.0f, 25.0f)];
    clickChannelLabel.text = @"点击进入频道";
    clickChannelLabel.font = [UIFont systemFontOfSize:12.0f];
    clickChannelLabel.backgroundColor = [UIColor clearColor];
    clickChannelLabel.textColor = [[ThemeMgr sharedInstance] isNightmode] ? [UIColor whiteColor] : [UIColor colorWithHexString:@"999292"];
    [self.view addSubview:clickChannelLabel];
    
    //赋值
    PhotoCollectionManager *manager = [PhotoCollectionManager sharedInstance];
    [gridView.galleryChannelArray addObjectsFromArray:manager.photoCollecChannelList];
    [gridView reloadView];
    gridView.frame = CGRectMake(0.0f, -(gridView.heightOfView - self.StateBarHeight - TopViewHeight), kContentWidth, gridView.heightOfView);
    
    [self.view bringSubviewToFront:gridView];
    [self.view bringSubviewToFront:headerView];
    [self.view bringSubviewToFront:expandButtonBg];
    [self.view bringSubviewToFront:expandButton];
    [self.view bringSubviewToFront:topImageView];
    [self.view bringSubviewToFront:collapseButton];
    [self.view bringSubviewToFront:allChannelsLabel];
    [self.view bringSubviewToFront:clickChannelLabel];
    [self.view bringSubviewToFront:titleView];
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         topImageView.alpha = 1.0f;
                         collapseButton.alpha = 1.0f;
                         gridView.frame = CGRectMake(0.0f, [self StateBarHeight] + TopViewHeight, kContentWidth, gridView.heightOfView);
                     }
                     completion:nil];
    
    [UIView animateWithDuration:0.2f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         allChannelsLabel.frame = CGRectMake(10.0f, self.StateBarHeight + 5.0f, 60.0f, 25.0f);
                         clickChannelLabel.frame = CGRectMake(90.0f, self.StateBarHeight + 5.0f, 100.0f, 25.0f);
                     }
                     completion:nil];
}

- (void)collapseGridView:(UIButton*)button
{
    PhotoCollectionManager *manager = [PhotoCollectionManager sharedInstance];
    [manager changePhotoCollectionChannelListOrder:gridView.galleryChannelArray];
    [headerView reloadViewWithPhotoChannelArray:manager.photoCollecChannelList];
    
    [self showPhotoCollectionChanged:currentChannel];
    [self collapseGridViewWithAnimate:YES];
}

#pragma mark PhotoGellaryChannelGridViewDataSource methods
- (NSInteger)gridViewCurrentIndex
{
    PhotoCollectionManager *manager = [PhotoCollectionManager sharedInstance];
    return [manager.photoCollecChannelList indexOfObject:currentChannel];
}


#pragma mark PhotoGalleryChannelGridViewDelegate methods
- (void)gridViewItemClicked:(PhotoCollectionChannel*)channel
{
    PhotoCollectionManager *manager = [PhotoCollectionManager sharedInstance];
    [manager changePhotoCollectionChannelListOrder:gridView.galleryChannelArray];
    [headerView reloadViewWithPhotoChannelArray:manager.photoCollecChannelList];
    
    [self showPhotoCollectionChanged:channel];
    [self collapseGridViewWithAnimate:YES];
}


//隐藏gridview
- (BOOL)collapseGridViewWithAnimate:(BOOL)animate
{
    if (!gridView) {
        return NO;
    }
    
    //还原其他控件的触摸操作
    _pclhsView.userInteractionEnabled = YES;
    titleView.userInteractionEnabled = YES;
    headerView.userInteractionEnabled = YES;
    if ([self.view.gestureRecognizers count] > 0) {
        [self.view removeGestureRecognizer:self.view.gestureRecognizers[0]];
    }
    
    
    if (!animate) {
        [topImageView removeFromSuperview];
        [collapseButton removeFromSuperview];
        [allChannelsLabel removeFromSuperview];
        [clickChannelLabel removeFromSuperview];
        [gridView removeFromSuperview];
        topImageView = nil;
        collapseButton = nil;
        allChannelsLabel = nil;
        clickChannelLabel = nil;
        gridView = nil;
        return YES;
    }
    
    [UIView animateWithDuration:0.2f animations:^{
        allChannelsLabel.frame = CGRectMake(-180.0f, self.StateBarHeight + 5.0f, 60.0f, 25.0f);
        clickChannelLabel.frame = CGRectMake(-100.0f, self.StateBarHeight + 5.0f, 100.0f, 25.0f);
    } completion:^(BOOL finished) {
        [allChannelsLabel removeFromSuperview];
        [clickChannelLabel removeFromSuperview];
        allChannelsLabel = nil;
        clickChannelLabel = nil;
    }];
    
    [UIView animateWithDuration:0.3f
                          delay:0.1f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         topImageView.alpha = 0.0f;
                         collapseButton.alpha = 0.0f;
                         gridView.frame = CGRectMake(0.0f, -(gridView.heightOfView -[self StateBarHeight]- TopViewHeight), kContentWidth, gridView.heightOfView);
                     }
                     completion:^(BOOL finished) {
                         [topImageView removeFromSuperview];
                         [collapseButton removeFromSuperview];
                         [gridView removeFromSuperview];
                         topImageView = nil;
                         collapseButton = nil;
                         gridView = nil;
                     }];
    return YES;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    //do nothing
}

#pragma mark UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(self.view.gestureRecognizers[0] == gestureRecognizer) {
        //先判断触摸的点的位置是否在gridview里
        if (CGRectContainsPoint(gridView.frame, [touch locationInView:self.view]) ||
            (CGRectContainsPoint(topImageView.frame, [touch locationInView:self.view]))) {
            //do nothing
        } else {
            PhotoCollectionManager *manager = [PhotoCollectionManager sharedInstance];
            [manager changePhotoCollectionChannelListOrder:gridView.galleryChannelArray];
            [headerView reloadViewWithPhotoChannelArray:manager.photoCollecChannelList];
            [self showPhotoCollectionChanged:currentChannel];
            
            [self collapseGridViewWithAnimate:YES];
        }
    }
    return NO;
}

@end
