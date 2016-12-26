//
//  OauthWebViewController.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAuth2Client.h"
#import "AppSettings.h"
#import "PhoneSurfController.h"

@protocol OauthWebViewControllerDelegate;

@interface OauthWebViewController : PhoneSurfController
<OAuth2ClientDelegate> {
    OAuth2Client *oauth2Client;
    UIWebView *webView;
    OAuthClientType clientType;
    
    NSString *ssoCallbackScheme;
}

@property(nonatomic, unsafe_unretained) id<OauthWebViewControllerDelegate> delegate;

- (id)initWithOAuthClientType:(OAuthClientType)_clientType;
- (void)applicationDidBecomeActive;
- (BOOL)handleOpenURL:(NSURL *)url;
- (void)setOAuthClientType:(OAuthClientType)type;

@end

@protocol OauthWebViewControllerDelegate <NSObject>

- (void)oauthResult:(OauthWebViewController*)controller oauthTpye:(OAuthClientType)type;
- (void)oauthFailed:(OauthWebViewController*)controller oauthTpye:(OAuthClientType)type;

@end