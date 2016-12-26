//
//  DownLoadViewController.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-3.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "DownLoadViewController.h"

#import "FileUtil.h"
#import "PathUtil.h"
#import "HotChannelsManager.h"
#import "SubsChannelsManager.h"
#import "HotChannelsListResponse.h"
#import "SubsChannelsListResponse.h"
#import "ThreadsManager.h"
#import "ThreadSummary.h"
#import "ThreadContentResolver.h"
#import "ThreadContentDownloader.h"
#import "SurfHtmlGenerator.h"
#import "AppDelegate.h"
#import "CReachability.h"
#import "CustomAnimation.h"
#import "PhoneNotification.h"
#import "OfflineDownloader.h"



#define PROGRESSLENGTH      320
#define VIEWFRAM            CGRectMake(0, 0, 320, kScreenHeight)
#define PROGRESSBGFEAME     CGRectMake(35, 0, 285, 20)
#define DOWNTEXTLAB_FRAME   CGRectMake(55, 2, 150, 16)
#define DOWNNUMLAB_FRAME    CGRectMake(220, 2, 100, 16)
#define DOWNTITLELAB_FRAME  CGRectMake(10, 0, 100, 20)
#define DATANET_ALTTAG      8592
#define WIFINET_ALTTAG      86510
#define PROGRESSORGX        0


@interface DownLoadViewController ()

@end

@implementation DownLoadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

+ (DownLoadViewController *)sharedInstance
{
    static DownLoadViewController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DownLoadViewController alloc] init];
    });
    
    return sharedInstance;
}

- (void)dealloc
{
    //    [self cancelDownLoad];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self viewState];
}

- (void)viewState
{
    theApp.window.windowLevel = 1500;//UIWindowLevelAlert;
    [self.view setFrame:[UIApplication sharedApplication].statusBarFrame];    //[UIApplication sharedApplication].statusBarFrame   CGRectMake(0, 0, 320, 40)
    [self showProgress];
    [self initCloseBt];
}

- (BOOL)isAddSubviews
{
    if ([theApp.window.subviews containsObject:self.view])
        return YES;
    
    return NO;
}

- (void)initCloseBt
{
    closeBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBt setImage:[UIImage imageNamed:@"downloadCloseBt"] forState:UIControlStateNormal];
    [closeBt setBackgroundColor:[UIColor clearColor]];
    [closeBt setFrame:CGRectMake(0, 0, 42, 42)];
    [closeBt addTarget:self action:@selector(clickCloseBt) forControlEvents:UIControlEventTouchUpInside];

    [theApp.window insertSubview:closeBt belowSubview:self.view];
  
}


- (void)changeCloseBtState:(BOOL)canTouch
{
//    [closeBt setUserInteractionEnabled:canTouch];
    if (canTouch)
    {
        if (closeBt.hidden)
        {
            [closeBt setHidden:NO];
        }
    }
    else
    {
        if (!closeBt.hidden)
        {
            [closeBt setHidden:YES];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)clickCloseBt
{
    theApp.window.windowLevel = UIWindowLevelNormal;
            
    if (imageProBgView) {
        [imageProBgView removeFromSuperview];
        imageProBgView = nil;
    }

    
    if (imageProView) {
        [imageProView removeFromSuperview];
        imageProView = nil;
    }

    
    if (downText) {
        [downText removeFromSuperview];
        downText = nil;
    }

    
    if (downText) {
        [downText removeFromSuperview];
        downText = nil;
    }

    
    if (downNumLab) {
        [downNumLab removeFromSuperview];
        downNumLab = nil;
    }

    
    if (wihteBgView) {
        [wihteBgView removeFromSuperview];
        wihteBgView = nil;
    }
    
    if (animationNumView) {
        [animationNumView removeFromSuperview];
        animationNumView = nil;
    }

    [closeBt removeFromSuperview];
    
    [[OfflineDownloader sharedInstance] stop];
    
    [self.view removeFromSuperview];
    self.view = nil;
}

- (void)showProgress
{
    if (!imageProBgView)
    {
        imageProBgView = [[UIImageView alloc] initWithFrame:PROGRESSBGFEAME];
        [imageProBgView setBackgroundColor:[UIColor grayColor]];
    }
//    if (![self.view.subviews containsObject:imageProBgView])
//    {
//        [self.view addSubview:imageProBgView];
//    }

    
    if (!wihteBgView) {
        wihteBgView = [[UIView alloc] initWithFrame:CGRectMake(PROGRESSBGFEAME.origin.x + 2, PROGRESSBGFEAME.origin.y + 2, PROGRESSBGFEAME.size.width - 4, PROGRESSBGFEAME.size.height - 4)];
        [wihteBgView setBackgroundColor:[UIColor whiteColor]];
    }
//    if (![self.view.subviews containsObject:wihteBgView])
//    {
//        [self.view addSubview:wihteBgView];
//    }
    
    if (!imageProView)
    {
        imageProView = [[UIImageView alloc] init];
        [imageProView setBackgroundColor:[UIColor colorWithRed:169/255.0f green:49/255.0f blue:43/255.0f alpha:1]];
        [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, 1, PROGRESSBGFEAME.size.height - 4)];
    }
//    if (![self.view.subviews containsObject:imageProView])
//    {
//        [self.view addSubview:imageProView];
//    }
    
    if (!downText)
    {
        downText = [[DownLoadLabel alloc] initWithFrame:DOWNTEXTLAB_FRAME];
//        downText = [[UILabel alloc] initWithFrame:DOWNTEXTLAB_FRAME];
        [downText setWidthLength:55];
        [downText setBackgroundColor:[UIColor clearColor]];
        [downText setTextAlignment:NSTextAlignmentLeft];
        downText.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [downText setTextColor:[UIColor colorWithHexString:@"999292"]];
        [downText setFont:[UIFont systemFontOfSize:14]];
        [downText setText:@"准备下载"];
    }
    if (![self.view.subviews containsObject:downText])
    {
        [self.view addSubview:downText];
    }
    
    if (!downNumLab)
    {
        downNumLab = [[DownLoadLabel alloc] initWithFrame:DOWNNUMLAB_FRAME];
        [downNumLab setWidthLength:220];
        [downNumLab setBackgroundColor:[UIColor clearColor]];
        [downNumLab setTextAlignment:NSTextAlignmentLeft];
        [downNumLab setTextColor:[UIColor colorWithHexString:@"999292"]];
        [downNumLab setFont:[UIFont systemFontOfSize:12]];
        [downNumLab setText:[NSString stringWithFormat:@" "]];
    }
    if (![self.view.subviews containsObject:downNumLab])
    {
        [self.view addSubview:downNumLab];
    }
    
    [theApp.window addSubview:imageProBgView];
    [theApp.window addSubview:wihteBgView];
    [theApp.window addSubview:imageProView];
    [theApp.window addSubview:downText];
    [theApp.window addSubview:downNumLab];

}


- (void)didFinishDownLoad
{
    if (downText)
    {
        [downText setTextColor:[UIColor whiteColor]];
        [downText setText:[NSString stringWithFormat:@"完成下载"]];
    }
    
    if (imageProView)
        [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, PROGRESSLENGTH - 2, PROGRESSBGFEAME.size.height - 4)];
        
    [self performSelector:@selector(clickCloseBt) withObject:nil afterDelay:1];
    
}

- (void)singleThreadTaskBeginDownLoad:(NSString *)name
{
    [self deleteImage];
    if (downText)
    {
        [downText setText:[NSString stringWithFormat:@"%@", name]];
        
        [downText setFrame:DOWNTEXTLAB_FRAME];
    }
    
    if (0 < [[OfflineDownloader sharedInstance] pendingTasksCount])
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@"%@ 个任务等待中", @([[OfflineDownloader sharedInstance] pendingTasksCount])]];
    }
    else
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@" "]];
    }

    
    if (imageProView)
        [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, 0, PROGRESSBGFEAME.size.height - 4)];
}

- (void)singleThreadTaskDownLoad:(NSString *)name
                        andCount:(NSInteger)completionCount
                         ofTotal:(NSInteger)total
{
    if (0==total) {
        return;
    }
    float num = PROGRESSLENGTH * completionCount / total;// + 30;
    if (downText)
    {
        [downText setText:[NSString stringWithFormat:@"%@(已下载%@条)", name, @(completionCount)]];
//        [downText settext:[NSString stringWithFormat:@"%@(已下载%d条)", name, completionCount]];
//        [downText setTextProgressColor:num];
        if (num > downText.frame.origin.x) {
            [downText getWhiteViewFromWidth:num];
        }
    }
    
    if (0 < [[OfflineDownloader sharedInstance] pendingTasksCount])
    {
        if (downNumLab)
        {
            [downNumLab setText:[NSString stringWithFormat:@"%@ 个任务等待中", @([[OfflineDownloader sharedInstance] pendingTasksCount])]];
            if (num > downNumLab.frame.origin.x) {
                [downNumLab getWhiteViewFromWidth:num];
            }
        }
    }
    else
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@" "]];
        
        if (downText)
        {
            [downText setFrame:CGRectMake(55, 2, 250, 16)];
        }
    }
    
    if (num < PROGRESSLENGTH) {
        if (imageProView)
            [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, num, PROGRESSBGFEAME.size.height - 4)];
    }

}

- (void)singleThreadTaskEndDownLoad:(NSString *)name
{
    if (0 < [[OfflineDownloader sharedInstance] pendingTasksCount])
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@"%@ 个任务等待中", @([[OfflineDownloader sharedInstance] pendingTasksCount])]];
    }
    else
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@" "]];
    }
    
    if (imageProView)
        [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, PROGRESSLENGTH, PROGRESSBGFEAME.size.height - 4)];

}

- (void)singleMagazineTaskBeginDownLoad:(NSString *)name
{
    if (downText)
    {
        [downText setText:[NSString stringWithFormat:@"%@", name]];
        [downText setFrame:DOWNTEXTLAB_FRAME];
    }
    
    if (0 < [[OfflineDownloader sharedInstance] pendingTasksCount])
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@"%@ 个任务等待中", @([[OfflineDownloader sharedInstance] pendingTasksCount])]];
    }
    else
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@" "]];
    }
    
    if (imageProView)
        [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, 0, PROGRESSBGFEAME.size.height - 4)];
}

- (void)singleMagazineTaskDownLoad:(NSString *)name andPercent:(float)percent
{
    float num = percent * PROGRESSLENGTH;// + 30;
//    if (downText)
//        [downText setText:[NSString stringWithFormat:@"%@", name]];
    
    if (downText)
    {
        [downText setText:[NSString stringWithFormat:@"%@", name]];
        if (num > downText.frame.origin.x) {
            [downText getWhiteViewFromWidth:num];
        }
    }
    
    if (0 < [[OfflineDownloader sharedInstance] pendingTasksCount])
    {
        if (downNumLab)
        {
            [downNumLab setText:[NSString stringWithFormat:@"%@ 个任务等待中", @([[OfflineDownloader sharedInstance] pendingTasksCount])]];
            
            if (num > downNumLab.frame.origin.x) {
                [downNumLab getWhiteViewFromWidth:num];
            }
        }
    }
    else
    {
        if (downText)
        {
            [downText setFrame:CGRectMake(55, 2, 250, 16)];
        }
        
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@" "]];
    }
    
    if (num < PROGRESSLENGTH) {
        if (imageProView)
            [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, num, PROGRESSBGFEAME.size.height - 4)];
    }
//    if (imageProView)
//        [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, num, PROGRESSBGFEAME.size.height - 4)];

}

- (void)singleMagazineTaskUnzip:(NSString *)name andPercent:(float)percent
{
    float num = percent * PROGRESSLENGTH;
    if (downText)
        [downText setText:[NSString stringWithFormat:@"正在解压 %@", name]];
    
    if (0 < [[OfflineDownloader sharedInstance] pendingTasksCount])
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@"%@ 个任务等待中", @([[OfflineDownloader sharedInstance] pendingTasksCount])]];
    }
    else
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@" "]];
    }
    
    if (imageProView)
        [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, num, PROGRESSBGFEAME.size.height - 4)];
}

- (void)singleMagazineTaskEndDownLoad:(NSString *)name
{
    
    if (downText)
    {
        [downText setText:[NSString stringWithFormat:@"%@", name]];
        [downText removeCurrentView];
    }
    
    if (downNumLab) {
        [downNumLab removeCurrentView];
    }
    
    if (0 < [[OfflineDownloader sharedInstance] pendingTasksCount])
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@"%@ 个任务等待中", @([[OfflineDownloader sharedInstance] pendingTasksCount])]];
    }
    else
    {
        if (downNumLab)
            [downNumLab setText:[NSString stringWithFormat:@" "]];
    }
    
    if (imageProView)
        [imageProView setFrame:CGRectMake(PROGRESSORGX, PROGRESSBGFEAME.origin.y + 2, PROGRESSLENGTH, PROGRESSBGFEAME.size.height - 4)];

}

- (void)deleteImage
{
    if (downText)
    {
        [downText removeCurrentView];
    }
    
    if (downNumLab) {
        [downNumLab removeCurrentView];
    }
}

- (void)animationNum:(NSInteger)countValue
{
    if (!animationNumView) {
        animationNumView = [[UILabel alloc] init];
    }
    [animationNumView setFrame:CGRectMake(0, 0, 50, 50)];
    animationNumView.center = CGPointMake(downNumLab.center.x - 30, downNumLab.center.y);
    [animationNumView setTextAlignment:NSTextAlignmentLeft];
    [animationNumView setBackgroundColor:[UIColor clearColor]];
    [animationNumView setTextColor:[UIColor colorWithHexString:@"AD2F2F"]];   //[UIColor colorWithHexString:@"999292"]//AD2F2F
    [animationNumView setFont:[UIFont systemFontOfSize:15]];
    [animationNumView setText:[NSString stringWithFormat:@"+ %@", @(countValue)]];
    
    if (![self.view.subviews containsObject:animationNumView]) {
        [self.view addSubview:animationNumView];
    }
    
    [UIView beginAnimations:@"animationName" context:nil];
    [UIView setAnimationDuration:0.5];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(finishiAnimationNumView)];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    CGPoint point = animationNumView.center;
    
    animationNumView.center = CGPointMake(point.x, point.y + 20);
    
    [UIView commitAnimations];
}

- (void)finishiAnimationNumView
{
    if (animationNumView && [self.view.subviews containsObject:animationNumView]) {
        [animationNumView removeFromSuperview];
        animationNumView = nil;
    }
}

- (void)setHiddenView:(BOOL)hidden
{
    if (hidden) {
        if (![[OfflineDownloader sharedInstance] hasChannelTasksDownloadingOrPending])
        {
            theApp.window.windowLevel = UIWindowLevelNormal;
            [self.view removeFromSuperview];
            [closeBt removeFromSuperview];
        }
    }
    else
    {
        [self viewState];
    }
}

@end

