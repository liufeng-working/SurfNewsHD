//
//  PhoneClassifyViewController.m
//  SurfNewsHD
//
//  Created by xuxg on 14-10-13.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "PhoneClassifyViewController.h"
#import "ThreadsManager.h"
#import "PhoneClassifyCell.h"
#import "PhotoGalleryViewController.h"
#import "PhoneMagazineController.h"
#import "SurfSubscribeViewController.h"
#import "SurfFlagsManager.h"

@interface PhoneClassifyViewController ()
{
    PhoneClassifyCell *_subscribeCell;
    PhoneClassifyCell *_galleryCell;
    PhoneClassifyCell *_periodicalCell;
}

@end

@implementation PhoneClassifyViewController

- (id)init
{
    self = [super init];
    if (!self) return nil;
    
    self.titleState = PhoneSurfControllerStateRoot;
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"分类资讯";
    float cellHeight = 75.f;
    
    // 订阅
    CGRect cellR = CGRectMake(0.f, [self StateBarHeight], kContentWidth, cellHeight);
    _subscribeCell = [[PhoneClassifyCell alloc] initWithFrame:cellR];
    [_subscribeCell addTarget:self action:@selector(subscribeClick:) forControlEvents:UIControlEventTouchUpInside];
    [_subscribeCell setBackgroundColor:[UIColor clearColor]];
    _subscribeCell.title = @"订阅";
    _subscribeCell.defaultContent = @"订阅更多频道";
    _subscribeCell.icon = [UIImage imageNamed:@"classify_subscribe.png"];
    [self.view addSubview:_subscribeCell];

    
    // 图集
    cellR = CGRectOffset(cellR, 0.f, cellHeight);
    _galleryCell = [[PhoneClassifyCell alloc] initWithFrame:cellR];
    [_galleryCell addTarget:self action:@selector(galleryClick:) forControlEvents:UIControlEventTouchUpInside];
    [_galleryCell setHighlighted:YES];
    [_galleryCell setBackgroundColor:[UIColor clearColor]];
    _galleryCell.title = @"图集";
    _galleryCell.defaultContent = @"视觉盛宴等你品味";
    _galleryCell.icon = [UIImage imageNamed:@"classify_gallery.png"];
    [self.view addSubview:_galleryCell];
    
    // 期刊（暂时2015.4.3关闭期刊入口）
//    cellR =  CGRectOffset(cellR, 0.f, cellHeight);
//    _periodicalCell = [[PhoneClassifyCell alloc] initWithFrame:cellR];
//    [_periodicalCell addTarget:self action:@selector(periodicalClick:) forControlEvents:UIControlEventTouchUpInside];
//    [_periodicalCell setHighlighted:YES];
//    [_periodicalCell setBackgroundColor:[UIColor clearColor]];
//    _periodicalCell.title = @"期刊";
//    _periodicalCell.defaultContent = @"订阅更多期刊";
//    _periodicalCell.icon = [UIImage imageNamed:@"classify_periodical.png"];
//    [self.view addSubview:_periodicalCell];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    ClassifyUpdateFlag *flags = [[SurfFlagsManager sharedInstance] classifyFlag];
    // 订阅第一个频道中得第一个新闻标题
    if (flags != nil) {
        // 订阅
        if ([flags infoNews] != nil) {
            if ([[[flags infoNews] title] length] > 0 &&
                ![_subscribeCell.content isEqualToString:[[flags infoNews] title]]) {
                _subscribeCell.content = [[flags infoNews] title];
                _subscribeCell.isFlag = [[flags infoNews] isNewFlag];
                [_subscribeCell setNeedsDisplay];
            }
        }
        
        // 期刊
//        if ([flags magazine] != nil) {
//            if ([[[flags magazine] title] length] > 0 &&
//                ![_periodicalCell.content isEqualToString:[[flags magazine] title]]) {
//                _periodicalCell.content = [[flags magazine] title];
//                _periodicalCell.isFlag = [[flags magazine] isNewFlag];
//                [_periodicalCell setNeedsDisplay];
//            }
//        }
        
        // 图集
        if ([flags imgNews] != nil) {
            _galleryCell.content = [[flags imgNews] title];
        }
    }
    
}


// 订阅
-(void)subscribeClick:(id)sender
{
    if (_subscribeCell.isFlag) {
        SurfFlagsManager *sfm = [SurfFlagsManager sharedInstance];
        _subscribeCell.isFlag = NO;
        [[sfm classifyFlag] infoNews].isNewFlag = NO;
    }
    
    
    //订阅Tab
    id subsController = [SurfSubscribeViewController new];
    [self presentController:subsController animated:PresentAnimatedStateFromRight];
}

// 图集
-(void)galleryClick:(id)sender
{
    //图集Tab
    id photoController = [PhotoGalleryViewController new];
    [self presentController:photoController animated:PresentAnimatedStateFromRight];
}

// 期刊
//-(void)periodicalClick:(id)sender
//{
//    if (_periodicalCell.isFlag) {
//        SurfFlagsManager *sfm = [SurfFlagsManager sharedInstance];
//        _periodicalCell.isFlag = NO;
//        [[sfm classifyFlag] magazine].isNewFlag = NO;
//    }
//    
//    id magazineController = [PhoneMagazineController new];
//    [self presentController:magazineController animated:PresentAnimatedStateFromRight];
//}


// 夜间模式切换
-(void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    [_subscribeCell viewNightModeChanged:night];
    [_galleryCell viewNightModeChanged:night];
    [_periodicalCell viewNightModeChanged:night];
}

@end

