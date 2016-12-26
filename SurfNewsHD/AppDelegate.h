//
//  AppDelegate.h
//  SurfNewsHD
//
//  Created by apple on 12-11-14.
//  Copyright (c) 2012年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OauthWebViewController.h"
#import "WXApi.h"
#import "ImageUtil.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>


//全局 AppDelegate
#define theApp ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#ifdef ipad

//===================ipad===================
#import "SurfRootViewController.h"
#import "MyWindow.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    SurfRootViewController *rootController;
}
@property (strong, nonatomic) OauthWebViewController *oauthWebViewController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SurfRootViewController *rootController;

#else   //iphone
//====================iphone==================
#import "PhoneRootViewController.h"
#import "GuideViewController.h"

@class PeriodicalInfo;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,WXApiDelegate>
{
    PhoneRootViewController *rootController;
    
    BOOL    shouldClearAllNotificationsOnEnterBackground;
    NSMutableArray* presentedVCs;   //用以记录展示的VC堆栈
    
    NSTimer *timer;//用于定时回调注册推送获取token
    
    NSDictionary *notificationDic;
    UIApplicationState notifiAppState;
}

@property (strong, nonatomic) OauthWebViewController *oauthWebViewController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PhoneRootViewController *rootController;
@property (strong, nonatomic) UIView *nightModeShadow;

@property (nonatomic, assign) BOOL    isShowAlert;


#endif

@property (nonatomic,retain) NSMutableArray *screenShotsList;

#pragma mark - 段子newsId
@property (nonatomic, strong) ThreadSummary *jokeThread;

//初始化程序
//初始化完成后方能进入主画面
-(void)initAppWithCompletionHandler:(void(^)(BOOL succeed))handler;

//同步模式初始化app
-(void)initAppEnv;

//更新用户订阅关系
-(void)checkUpdateSubs;

-(void)gotoMainUI;
#ifdef ipad


#else
//屏幕添加,删除截图，谨慎调用
-(void)screenAddCapture;
-(void)screenDeleteCapture;
//根据itunes获取的数据,检测更新
- (void)checkUpdateFromItunes;
//发送给好友
- (void)sendThreadToWeinxin:(ThreadSummary*)_thread shareImage:(UIImage *)image;
//发送到朋友圈
- (void)sendThreadToWeinxinTimeline:(ThreadSummary*)_thread shareImage:(UIImage *)image;
- (void)sendWeixin:(NSString *)title
       description:(NSString *)desc
           newsUrl:(NSString *)newsUrl
        shareImage:(UIImage *)image
             scene:(NSInteger)scene;
// 发生图片到微博
- (void)sendImageToWeixin:(NSString *)title
              description:(NSString *)desc
               shareImage:(UIImage *)image
                    scene:(NSInteger)scene;
//分享给QQ好友
-(void)sendThreadToQQFriend:(ThreadSummary *)thread shareImage:(UIImage *)image;
//分享到QQ空间
-(void)sendThreadToQZone:(ThreadSummary *)thread shareImage:(UIImage *)image;
//分享链接
-(void)sendQQ:(NSString *)title
  description:(NSString *)desc
      newsUrl:(NSString *)newsUrl
   shareImage:(UIImage *)image
         type:(LFShareToQQ)type;
//分享图片
-(void)sendImageToQQ:(NSString *)title
         description:(NSString *)desc
          shareImage:(UIImage *)image
                type:(LFShareToQQ)type;

//----------跟PhoneSurfController::presentController配套使用
- (UIViewController*)topMostVC;
- (void)pushTopMostVC:(UIViewController*)vc;
- (void)popTopMostVC;
- (UIViewController*)getRootViewControllerFromAppdelegate;
//--------------------------------------------------------

// 段子频道点分享调用
- (void)commitShareOperation;

#endif

@end
