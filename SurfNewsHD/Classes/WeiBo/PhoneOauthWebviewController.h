//
//  PhoneOauthWebviewController.h
//  SurfNewsHD
//
//  Created by SYZ on 14-5-15.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "PhoneSurfController.h"
#import "OAuth2Client.h"
#import "AppSettings.h"

@protocol PhoneOauthWebviewControllerDelegate;

@interface PhoneOauthWebviewController : PhoneSurfController <OAuth2ClientDelegate> {
    OAuth2Client *oauth2Client;
    UIWebView *webView;
    OAuthClientType clientType;
    UIView *tools;
    
    NSString *ssoCallbackScheme;
}

@property(nonatomic, unsafe_unretained) id<PhoneOauthWebviewControllerDelegate> delegate;

- (id)initWithOAuthClientType:(OAuthClientType)_clientType;
- (void)applicationDidBecomeActive;
- (BOOL)handleOpenURL:(NSURL *)url;
- (void)setOAuthClientType:(OAuthClientType)type;

@end

@protocol PhoneOauthWebviewControllerDelegate <NSObject>

- (void)oauthResult:(PhoneOauthWebviewController*)controller oauthTpye:(OAuthClientType)type;
- (void)oauthFailed:(PhoneOauthWebviewController*)controller oauthTpye:(OAuthClientType)type;

@end
