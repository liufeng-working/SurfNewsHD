//
//  ShareController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ShareController.h"
#import "AppDelegate.h"
#import "SurfRootViewController.h"
#import "NSString+Extensions.h"

@interface ShareController ()

@end

@implementation ShareController

+ (ShareController*)sharedInstance
{
    static ShareController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ShareController alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = ViewTitleStateNone;
        sendWeibo = [[SendWeibo alloc] init];
        sendWeibo.delegate = self;
        shareArray = [[NSMutableArray alloc] init];
        
        shareToCM = YES;
        shareToSina = YES;
        shareToTencent = YES;
        shareToRenren = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *viewController = appDelegate.window.rootViewController;
    self.view.frame = viewController.view.bounds;
    
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backgroundView];
    
    shareView = [[ShareView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 360.0f, 400.0f)
                                      controller:self];
    shareView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    CGPoint center = CGPointMake(self.view.center.x + 46.0f, self.view.center.y);
    shareView.center = center;
    [self.view addSubview:shareView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(singleTapDetected:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [backgroundView addGestureRecognizer:tapRecognizer];
}

#pragma mark Observer methods
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGRect frame = shareView.frame;
                             frame.origin.y -= 252.0f;
                             shareView.frame = frame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGRect frame = shareView.frame;
                             frame.origin.y += 252.0f;
                             shareView.frame = frame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = NO;
}

//显示分享界面,并接收分享的文字和图片
- (void)showShareViewWithShareText:(NSString*)text shareImage:(UIImage*)image shareURL:(NSString*)url
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *viewController = appDelegate.window.rootViewController;
    [viewController.view addSubview:self.view];
    
    _shareText = text;
    _shareImage = image;
    _shareUrl = url;
    
    shareView.shareTextView.text = _shareText;
    
    [self setShareViewItemImage];
    [shareView calculateTextLength];
}

//设置分享项的图片和选择
- (void)setShareViewItemImage
{
    SurfDbManager *manager = [SurfDbManager sharedInstance];
        
    NSDictionary *sinaDict = [manager getSinaWeiboInfoForUser:kDefaultID];
    if ([sinaDict valueForKey:@"access_token"] && [sinaDict valueForKey:@"uid"]) {
        bindSina = YES;
    } else {
        shareToSina = NO;
        bindSina = NO;
    }
    [shareView setItemViewImageWithTag:1 bind:bindSina share:shareToSina];
    
    NSDictionary *tencentDict = [manager getTencentWeiboInfoForUser:kDefaultID];
    if ([tencentDict valueForKey:@"access_token"]) {
        bindTencent = YES;
    } else {
        shareToTencent = NO;
        bindTencent = NO;
    }
    [shareView setItemViewImageWithTag:2 bind:bindTencent share:shareToTencent];
    
    NSDictionary *renrenDict = [manager getRenrenWeiboInfoForUser:kDefaultID];
    if ([renrenDict valueForKey:@"access_token"]) {
        bindRenren = YES;
    } else {
        shareToRenren = NO;
        bindRenren = NO;
    }
    [shareView setItemViewImageWithTag:3 bind:bindRenren share:shareToRenren];
    
    NSDictionary *cmDict = [manager getCMWeiboInfoForUser:kDefaultID];
    if ([cmDict valueForKey:@"access_token"]) {
        bindCM = YES;
    } else {
        shareToCM = NO;
        bindCM = NO;
    }
    [shareView setItemViewImageWithTag:4 bind:bindCM share:shareToCM];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark ShareView methods
- (void)shareItemTapDetected:(UIGestureRecognizer*)sender
{
    switch (sender.view.tag) {
            
        case 1:
        {
            if (bindSina) {
                shareToSina = !shareToSina;
                [shareView setItemViewImageWithTag:1 bind:bindSina share:shareToSina];
            } else { //绑定微博
                [self oauthWebViewController:SinaOAuth];
            }
        }
            break;
            
        case 2:
        {
            if (bindTencent) {
                shareToTencent = !shareToTencent;
                [shareView setItemViewImageWithTag:2 bind:bindTencent share:shareToTencent];
            } else { //绑定微博
                [self oauthWebViewController:TencentOAuth];
            }
        }
            break;
            
        case 3:
        {
            if (bindRenren) {
                shareToRenren = !shareToRenren;
                [shareView setItemViewImageWithTag:3 bind:bindRenren share:shareToRenren];
            } else { //绑定微博
                [self oauthWebViewController:RenRenOAuth];
            }
        }
            break;
            
        case 4:
        {
            if (bindCM) {
                shareToCM = !shareToCM;
                [shareView setItemViewImageWithTag:4 bind:bindCM share:shareToCM];
            } else { //绑定微博
                [self oauthWebViewController:ChinaMobielOAuth];
            }
        }
            break;
            
        default:
            break;
    }
}

//跳转到授权界面
- (void)oauthWebViewController:(OAuthClientType)type
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
    OauthWebViewController *controller = [[OauthWebViewController alloc] initWithOAuthClientType:type];
    controller.delegate = self;
    UINavigationController *navgation = [[UINavigationController alloc] initWithRootViewController:controller];
    rootController.willAppear = NO;
    [rootController presentModalViewController:navgation animated:YES];
}

//将分享的加入到分享数组中
- (void)didShare:(UIButton*)button
{
    if (!shareToCM && !shareToSina && !shareToTencent && !shareToRenren) {
        [SurfNotification surfNotification:@"请选择要分享到的网站"];
        return;
    }
    
    if (shareView.leftWordCount < 0) {
        [SurfNotification surfNotification:@"字数超过限制"];
        return;
    }
    
    [shareView.shareTextView resignFirstResponder];
    
    if (shareToSina) {
        [shareArray addObject:ShareToSina];
    }
    if (shareToTencent) {
        [shareArray addObject:ShareToTencent];
    }
    if (shareToRenren) {
        [shareArray addObject:ShareToRenren];
    }
    if (shareToCM) {
        [shareArray addObject:ShareToCM];
    }

    notification = [SurfNotification surfNotificatioIndicatorAutoHide:NO];
    _shareText = [NSString stringWithFormat:@"%@ %@", shareView.shareTextView.text, [_shareUrl completeUrl]];
    [self didShareOperate];
}

//分享
- (void)didShareOperate
{
    if ([shareArray count] > 0) {
        [sendWeibo sendWeiboWithTpye:[shareArray objectAtIndex:0] shareText:_shareText shareImage:_shareImage];
    }
}

//移除分享界面的view
- (void)singleTapDetected:(UITapGestureRecognizer *)sender
{
    if (keyboardShowing) {
        [shareView.shareTextView resignFirstResponder];
    } else {
        [self.view removeFromSuperview];
    }
}

#pragma mark OauthWebViewControllerDelegate methods
//授权成功
- (void)oauthResult:(OauthWebViewController *)controller oauthTpye:(OAuthClientType)type
{
    [controller dismissModalViewControllerAnimated:YES];
    
    shareView.center = self.view.center;
    
    if (type == SinaOAuth) {
        shareToSina = YES;
        bindSina = YES;
        [shareView setItemViewImageWithTag:1 bind:bindSina share:shareToSina];
    } else if (type == TencentOAuth) {
        shareToTencent = YES;
        bindTencent = YES;
        [shareView setItemViewImageWithTag:2 bind:bindTencent share:shareToTencent];
    } else if (type == RenRenOAuth) {
        shareToRenren = YES;
        bindRenren = YES;
        [shareView setItemViewImageWithTag:3 bind:bindRenren share:shareToRenren];
    } else if (type == ChinaMobielOAuth) {
        shareToCM = YES;
        bindCM = YES;
        [shareView setItemViewImageWithTag:4 bind:bindCM share:shareToCM];
    }
}

//授权失败
- (void)oauthFailed:(OauthWebViewController *)controller oauthTpye:(OAuthClientType)type
{
    [controller dismissModalViewControllerAnimated:YES];
    
    if (type == SinaOAuth) {
        [SurfNotification surfNotification:@"绑定新浪微博失败,请重试"];
    } else if (type == TencentOAuth) {
        [SurfNotification surfNotification:@"绑定腾讯微博失败,请重试"];
    } else if (type == RenRenOAuth) {
        [SurfNotification surfNotification:@"绑定人人网失败,请重试"];
    } else if (type == ChinaMobielOAuth) {
        [SurfNotification surfNotification:@"绑定中国移动微博失败,请重试"];
    }
}

#pragma mark SendWeiboDelegate methods
//发送微博成功
- (void)sendWeiboResult:(NSString *)result weiboType:(NSString *)type
{
    if ([shareArray count] > 0) {
        [shareArray removeObject:type];
        [self didShareOperate];
        if ([shareArray count] == 0) {
            [notification hideNotificatioIndicator:^(BOOL finished) {
                [self.view removeFromSuperview];
                [SurfNotification surfNotification:@"分享成功"];
            }];
        }
    }
}

//发送微博失败
- (void)sendWeiboFailed:(NSString *)result weiboType:(NSString *)type
{
    if ([shareArray count] > 0) {
        [shareArray removeObject:type];
        [self didShareOperate];
        if ([shareArray count] == 0) {
            [notification hideNotificatioIndicator:^(BOOL finished) {
                [SurfNotification surfNotification:@"分享失败"];
            }];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
