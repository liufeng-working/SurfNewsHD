//
//  ShareController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-29.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#import "SurfDbManager.h"
#import "ShareView.h"
#import "OauthWebViewController.h"
#import "OAuth2Client.h"

@interface ShareController : SurfNewsViewController <SendWeiboDelegate, OauthWebViewControllerDelegate>
{
    ShareView *shareView;
    
    NSString *cmAccessToken;
    NSString *sinaAccessToken;
    NSString *tencentAccessToken;
    NSString *tencentOpenId;
    NSString *renrenAccessToken;
    
    BOOL shareToCM;
    BOOL shareToSina;
    BOOL shareToTencent;
    BOOL shareToRenren;
    
    BOOL bindCM;
    BOOL bindSina;
    BOOL bindTencent;
    BOOL bindRenren;
    
    BOOL keyboardShowing;
    
    SendWeibo *sendWeibo;
    NSMutableArray *shareArray;
    
    SurfNotification *notification;
}

@property(nonatomic, strong) NSString *shareText;
@property(nonatomic, strong) UIImage *shareImage;
@property(nonatomic, strong) NSString *shareUrl;

+ (ShareController*)sharedInstance;
- (void)showShareViewWithShareText:(NSString*)text shareImage:(UIImage*)image shareURL:(NSString*)url;

@end
