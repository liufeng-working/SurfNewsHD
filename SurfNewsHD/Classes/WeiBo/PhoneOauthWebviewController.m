//
//  OauthWebViewController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneOauthWebviewController.h"
#import "NSDictionary+QueryString.h"
#import "GTMHTTPFetcher.h"
#import "UserManager.h"

@interface PhoneOauthWebviewController ()

@end

@implementation PhoneOauthWebviewController

- (id)initWithOAuthClientType:(OAuthClientType)_clientType
{
    self = [super init];
    if (self) {
        clientType = _clientType;
    }
    return self;
}

- (void)setOAuthClientType:(OAuthClientType)type
{
    clientType = type;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    webView = [[UIWebView alloc] init];
    webView.delegate = self;
    [self.view addSubview:webView];
    webView.frame = CGRectMake(0.0f, 0.0f, 320.0f, kScreenHeight);
    
    [self addBottomToolsBar];
//    float width = CGRectGetWidth(self.view.frame);
//    float height = CGRectGetHeight(self.view.frame) - 47.0f;
//    
//    tools = [[UIView alloc] initWithFrame:CGRectMake(0, height, width, 47.0f)];
//    tools.backgroundColor = self.view.backgroundColor;
//    
//    NSMutableArray *colors = [NSMutableArray array];
//    [colors addObject:(id)[[UIColor colorWithWhite:1.0f alpha:0.0] CGColor]];
//    [colors addObject:(id)[[UIColor colorWithWhite:0.0f alpha:0.2] CGColor]];
//    
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    [gradient setFrame:CGRectMake(0,-3.0f,tools.frame.size.width,4.0f)];
//    gradient.colors = colors;
//    [tools.layer insertSublayer:gradient atIndex:0];
//    [self.view addSubview:tools];
//    
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.frame = CGRectMake(0.0f, 0.0f, 64.0f, 49.0f);
//    [backButton setBackgroundImage:[UIImage imageNamed:@"backBar.png"] forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
//    [tools addSubview:backButton];
//    
//    ThemeMgr *tm = [ThemeMgr sharedInstance];
//    tools.backgroundColor = [UIColor hexChangeFloat:[tm isNightmode] ? @"2D2E2F":@"FFFFFF"];
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (clientType == ChinaMobielOAuth) {
        oauth2Client = [[OAuth2Client alloc] initWithClientKey:kChinaMobileWeiboAppKey
                                                  clientSecret:kChinaMobileWeiboAppSecret
                                                   redirectURL:kWeiboRedirectURL
                                            gtmFetcherDelegate:self];
        oauth2Client.delegate = self;
        oauth2Client.authURL = kChinaMobileWeiboAuthorizeURL;
        oauth2Client.tokenURL = kChinaMobileWeiboAccessTokenURL;
        oauth2Client.clientType = ChinaMobielOAuth;
        
        NSDictionary *additionalParams = [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type", nil];
        [oauth2Client authorizeUsingWebView:webView additionalParameters:additionalParams httpMethod:@"GET"];
    } else if (clientType == SinaOAuth) {
        //新浪SSO登录
        //if ([self sinaSSOLogin]) {
        //    return;
        //}
        oauth2Client = [[OAuth2Client alloc] initWithClientKey:kSinaWeiboAppKey
                                                  clientSecret:kSinaWeiboAppSecret
                                                   redirectURL:kWeiboRedirectURL
                                            gtmFetcherDelegate:self];
        oauth2Client.delegate = self;
        oauth2Client.authURL = kSinaWeiboAuthorizeURL;
        oauth2Client.tokenURL = kSinaWeiboAccessTokenURL;
        oauth2Client.clientType = SinaOAuth;
        NSDictionary *additionalParams = [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type",
                                          @"mobile", @"display", @"true", @"forcelogin", nil];
        [oauth2Client authorizeUsingWebView:webView additionalParameters:additionalParams httpMethod:@"GET"];
    }
    else if (clientType == TencentWeiboOAuth) {
        oauth2Client = [[OAuth2Client alloc] initWithClientKey:kTencentWeiboAppKey
                                                  clientSecret:kTencentWeiboAppSecret
                                                   redirectURL:kWeiboRedirectURL
                                            gtmFetcherDelegate:self];
        oauth2Client.delegate = self;
        oauth2Client.authURL = kTencentWeiboAuthorizeURL;
        oauth2Client.tokenURL = kTencentWeiboAccessTokenURL;
        oauth2Client.clientType = TencentWeiboOAuth;
        
        NSDictionary *additionalParams = [NSDictionary dictionaryWithObjectsAndKeys:@"code", @"response_type",
                                          @"2", @"wap", nil];
        [oauth2Client authorizeUsingWebView:webView additionalParameters:additionalParams httpMethod:@"GET"];
    }
    else if (clientType == RenRenOAuth) {
        oauth2Client = [[OAuth2Client alloc] initWithClientKey:kRenRenAppKey
                                                  clientSecret:kRenRenAppSecret
                                                   redirectURL:kWeiboRedirectURL
                                            gtmFetcherDelegate:self];
        oauth2Client.delegate = self;
        oauth2Client.authURL = kRenRenAuthorizeURL;
        oauth2Client.tokenURL = kRenRenAccessTokenURL;
        oauth2Client.clientType = RenRenOAuth;
        
        NSDictionary *additionalParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"token", @"response_type",
                                          @"touch", @"display", @"status_update,photo_upload", @"scope", @"true", @"x_renew", nil];
        [oauth2Client authorizeUsingWebView:webView additionalParameters:additionalParams httpMethod:@"POST"];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [webView loadHTMLString:@"<html><body></body></html>" baseURL:nil];
}

- (void)dismissBackController
{
    [webView stopLoading];
    
    [super dismissBackController];
}

//新浪SSO登录
- (BOOL)sinaSSOLogin
{
    [AppSettings setBool:NO forKey:@"sso"];
    BOOL ssoLoggingIn = [AppSettings boolForKey:@"sso"];
    ssoCallbackScheme = kSinaSSOCallbackScheme;
    
    UIDevice *device = [UIDevice currentDevice];
    if ([device respondsToSelector:@selector(isMultitaskingSupported)] &&
        [device isMultitaskingSupported]) {
        NSDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                kSinaWeiboAppKey, @"client_id",
                                kWeiboRedirectURL, @"redirect_uri",
                                ssoCallbackScheme, @"callback_uri", nil];

        NSString *appAuthBaseURL = kSinaWeiboAppAuthURL_iPhone;
        NSURL *appAuthURL = [NSURL URLWithString:[appAuthBaseURL stringByAppendingFormat:@"?%@",
                                                  [params stringWithFormEncodedComponents]]];
        ssoLoggingIn = [[UIApplication sharedApplication] openURL:appAuthURL];
    }
    [AppSettings setBool:ssoLoggingIn forKey:@"sso"];
    return ssoLoggingIn;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)back
{
//    [self.navigationController dismissModalViewControllerAnimated:YES];
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}

#pragma mark OAuthClientDelegate methods
/**
 *- (void)oauthClientFailReceiveString:(NSString *)errorResult;
 *任何一个网站在授权的过程中出错都会调用此方法
 **/
- (void)oauthClientFailReceiveString:(NSString *)errorResult
{
    [self.delegate oauthFailed:self oauthTpye:clientType];
}

/**
 *- (void)renrenOauthSuccessReceiveString:(NSString *)result;
 *只有人人网获得access_token会调用此方法
 **/
- (void)renrenOauthSuccessReceiveString:(NSString *)result
{
    //    access_token=212587|6.b81b748892542206911f3f498d04e87b.2592000.1362211200-251509086&expires_in=2594501&scope=status_update
    SurfDbManager *manager = [SurfDbManager sharedInstance];
    
    NSDictionary *dict = [NSDictionary dictionaryWithFormEncodedString:result];
    if ([manager addRenrenWeiboInfoForUser:kDefaultID infoDictionary:dict]) {
        DJLog(@"保存成功");
        [self.delegate oauthResult:self oauthTpye:clientType];
    } else {
        DJLog(@"保存失败");
        [self.delegate oauthFailed:self oauthTpye:clientType];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DJLog(@"webview:fail");
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    DJLog(@"webview:startload");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    DJLog(@"webview:finishload");
}

#pragma mark GTMHTTPFetcher Protocol
//中国移动微博,新浪微博和腾讯微博授权失败成功调用此方法
- (void)myFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error
{
    if (error != nil) {
        [self.delegate oauthFailed:self oauthTpye:clientType];
    } else {
        //得到返回值也要判断是否成功授权
        NSString *result = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
        //判断返回值是否包括access_token,不包括即是失败
        if ([result rangeOfString:@"access_token"].location == NSNotFound) {
            [self.delegate oauthFailed:self oauthTpye:clientType];
            return;
        }
        
        SurfDbManager *manager = [SurfDbManager sharedInstance];
        
        //数据库保存token等
        if (clientType == ChinaMobielOAuth) {
            //             {"access_token":"7bda8baaf04a401438e4f3c4b86a5ad5","expires_in":2592000,"scope":null,"refresh_token":"513fa74657e30d5177502cb1c0abffd0"}
            NSDictionary *dict = [result objectFromJSONString];
            if ([manager addCMWeiboInfoForUser:kDefaultID infoDictionary:dict]) {
                DJLog(@"保存成功");
            } else {
                DJLog(@"保存失败");
                [self.delegate oauthFailed:self oauthTpye:clientType];
            }
        } else if (clientType == SinaOAuth) {
            //            {"access_token":"2.00B89YwCg7doPC53e4ab5bc1u7ynDB","remind_in":"659066","expires_in":659066,"uid":"2697505611"}
            NSDictionary *dict = [result objectFromJSONString];
            if ([manager addSinaWeiboInfoForUser:kDefaultID infoDictionary:dict]) {
                DJLog(@"保存成功");
            } else {
                DJLog(@"保存失败");
                [self.delegate oauthFailed:self oauthTpye:clientType];
            }
        } else if (clientType == TencentWeiboOAuth) {
            //            access_token=918417a026d41dda93e2b992a5270d73&expires_in=1209600&refresh_token=eadadb23a3be4a3edc3022b167ce67c1&openid=ab77fb16194f125357c803d1847ba654&name=siyz2012&nick=Test&state=
            NSDictionary *dict = [NSDictionary dictionaryWithFormEncodedString:result];
            if ([manager addTencentWeiboInfoForUser:kDefaultID infoDictionary:dict]) {
                DJLog(@"保存成功");
            } else {
                DJLog(@"保存失败");
                [self.delegate oauthFailed:self oauthTpye:clientType];
            }
        }
        [self.delegate oauthResult:self oauthTpye:clientType];
    }
}

- (void)applicationDidBecomeActive
{
    if ([AppSettings boolForKey:@"sso"]) {
        [AppSettings setBool:NO forKey:@"sso"];
    }
}

/**
 * @description sso回调方法，官方客户端完成sso授权后，回调唤起应用，应用中应调用此方法完成sso登录
 * @param url: 官方客户端回调给应用时传回的参数，包含认证信息等
 * @return YES
 */
- (BOOL)handleOpenURL:(NSURL *)url
{
    BOOL ssoLoggingIn = [AppSettings boolForKey:@"sso"];
    NSString *urlString = [url absoluteString];
    if ([urlString hasPrefix:kSinaSSOCallbackScheme]) {
        if (!ssoLoggingIn) {
            // sso callback after user have manually opened the app
            // ignore the request
        } else {
            [AppSettings setBool:NO forKey:@"sso"];;
            
            NSDictionary *dict = [NSDictionary dictionaryWithFormEncodedString:urlString];
            if ([dict valueForKey:@"sso_error_user_cancelled"]) {
                if ([self.delegate respondsToSelector:@selector(oauthFailed:oauthTpye:)]) {
                    [self.delegate oauthFailed:self oauthTpye:clientType];
                }
            } else if ([dict valueForKey:@"sso_error_invalid_params"]) {
                if ([self.delegate respondsToSelector:@selector(oauthFailed:oauthTpye:)]) {
                    [self.delegate oauthFailed:self oauthTpye:clientType];
                }
            } else if ([dict valueForKey:@"error_code"]) {
                //                NSString *error_code = [dict valueForKey:@"error_code"];
                //                NSString *error = [dict valueForKey:@"error"];
                //                NSString *error_uri = [dict valueForKey:@"error_uri"];
                //                NSString *error_description = [dict valueForKey:@"error_description"];
                [self.delegate oauthFailed:self oauthTpye:clientType];
            } else {
                NSString *access_token = [dict valueForKey:@"access_token"];
                NSString *expires_in = [dict valueForKey:@"expires_in"];
                if (access_token && expires_in) {
                    SurfDbManager *manager = [SurfDbManager sharedInstance];
                    if ([manager addSinaWeiboInfoForUser:kDefaultID infoDictionary:dict]) {
                        DJLog(@"保存成功");
                        [self.delegate oauthResult:self oauthTpye:clientType];
                    } else {
                        DJLog(@"保存失败");
                        [self.delegate oauthFailed:self oauthTpye:clientType];
                    }
                } else {
                    [self.delegate oauthFailed:self oauthTpye:clientType];
                }
            }
        }
    }
    return YES;
}

@end

