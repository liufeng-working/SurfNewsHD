   //
//  LoadingController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "LoadingController.h"
#import "AppDelegate.h"
#import "AppSettings.h"
#import "PathUtil.h"
#import "FileUtil.h"
#import "AppSettings.h"
#import "UpdateSplashResponse.h"
#import "EzJsonParser.h"

@interface LoadingController ()

@end

@implementation LoadingController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    loadingImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    loadingImage.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
#ifdef ipad
        loadingImage.image = [UIImage imageNamed:@"Default-Landscape~ipad"];
#else
        loadingImage.image = [UIImage imageNamed:@"Default"];
        loadingImage.backgroundColor = [UIColor grayColor];
#endif

    [self.view addSubview:loadingImage];
    
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activityView.frame = CGRectMake(self.view.frame.size.width/2 -20, self.view.frame.size.height /2 -20, 40.0f, 40.0f);
    [_activityView startAnimating];
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:_activityView];

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate initAppWithCompletionHandler:^(BOOL succeeded)
     {
         [self performSelector:@selector(changeWindow) withObject:self afterDelay:0.0f];
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)changeWindow
{
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    [AppSettings setDate:[NSDate date] forkey:DateLastRunDate];
    NSString *newVer = [AppSettings stringForKey:StringLastRunVersion];
    if (![version isEqualToString:newVer]) {
        [AppSettings setString:version forKey:StringLastRunVersion];
#ifdef ipad
        NewVersionGuideView *newVersionGuideView = [[NewVersionGuideView alloc] initWithFrame:
                                                    CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)];
        newVersionGuideView.delegate = self;
        [self.view addSubview:newVersionGuideView];
#else
//        GuideViewController *controller = [[GuideViewController alloc] init];
//        controller.guideDelegate = self;
//        [self presentModalViewController:controller animated:PresentAnimatedStateNone];
        
        
        GuideView *controller = [[GuideView alloc] initWithFrame:theApp.rootController.view.frame];
        [controller setBackgroundColor:[UIColor clearColor]];
        controller.guideDelegate = self;
        [self.view addSubview:controller];
#endif

    } else {
        [self removeNewVersionGuideControllerView:nil];
    }


    

}

#pragma mark - NewVersionGuideViewDelegate
- (void)removeNewVersionGuideControllerView:(NewVersionGuideView*)view
{
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setStatusBarHidden:NO];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = appDelegate.rootController;
#ifdef ipad

#else
    [appDelegate.window addSubview:appDelegate.nightModeShadow];
    
    ThemeMgr *gmr = [ThemeMgr sharedInstance];
    appDelegate.nightModeShadow.hidden = ![gmr isNightmode];
    
#endif


}
#pragma mark - GuideViewControllerDelegate
- (void)finishLoadGuideView
{
    UIApplication *myApp = [UIApplication sharedApplication];
    [myApp setStatusBarHidden:NO];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.window.rootViewController = appDelegate.rootController;
#ifdef ipad
    
#else
    [appDelegate.window addSubview:appDelegate.nightModeShadow];
    
    ThemeMgr *gmr = [ThemeMgr sharedInstance];
    appDelegate.nightModeShadow.hidden = ![gmr isNightmode];
#endif
    

}
@end
