//
//  OAuth2Client.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//
//
//中国移动微博,新浪微博和腾讯微博的授权流程是:
//   请求授权网页:
//       授权请求所需要的参数和方法根据各个门户有所不同
//       详细参数请参照代码
//       授权后会返回accesscode
//   获取access_token:
//       使用上一步获得的accesscode以及各个门户所需要的参数
//
//人人网的授权流程:
//   授权请求所需要的参数和方法请参照代码
//   点击网页授权后返回的URL中带有access_token(人人网的授权流程没有按照oauth2的流程，我可以说脏话吗)
//
//注意:此代码中没有使用refresn_token获得access_token
//    因为不是每个门户都会返回refresh_token和过期时间
//

#import <Foundation/Foundation.h>

typedef enum {
    ChinaMobielOAuth,
    SinaOAuth,
    TencentWeiboOAuth,
    TencentQZone, // 腾讯空间
    RenRenOAuth,
} OAuthClientType;

@protocol OAuth2ClientDelegate <UIWebViewDelegate>

@required
- (void)renrenOauthSuccessReceiveString:(NSString *)successResult;
- (void)oauthClientFailReceiveString:(NSString*)errorResult;

@end

@interface OAuth2Client : NSObject {
    id<OAuth2ClientDelegate> __unsafe_unretained delegate;
    
    NSString *clientKey;
    NSString *clientSecret;
    NSString *redirectURL;
    NSString *authURL;
    NSString *tokenURL;
    
    OAuthClientType clientType;
    
    BOOL isVerifying;
}

@property (nonatomic, unsafe_unretained) id<OAuth2ClientDelegate> delegate;
@property (nonatomic, unsafe_unretained) id gtmFetcherDelegate;
@property (nonatomic, strong) NSString *clientKey;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *redirectURL;
@property (nonatomic, strong) NSString *authURL;
@property (nonatomic, strong) NSString *tokenURL;

@property (nonatomic, assign) OAuthClientType clientType;

- (id)initWithClientKey:(NSString *)key
           clientSecret:(NSString *)secret
            redirectURL:(NSString *)url
     gtmFetcherDelegate:(id)delegate;

- (NSURLRequest *)userAuthorizationRequestWithParameters:(NSDictionary *)additionalParameters httpMethod:(NSString*)httpMethod;
- (void)verifyAuthorizationWithAccessCode:(NSString *)accessCode;

@end

@interface OAuth2Client (UIWebViewIntegration) <UIWebViewDelegate>

- (void)authorizeUsingWebView:(UIWebView *)webView;
- (void)authorizeUsingWebView:(UIWebView *)webView additionalParameters:(NSDictionary *)additionalParameters httpMethod:(NSString*)httpMethod;
- (BOOL)extractAccessCodeFromCallbackURL:(NSURL *)url;
- (BOOL)extractAccessTokenFromCallbackURL:(NSURL *)url;

@end

//------------------------------------发送微博-----------------------------------
@protocol SendWeiboDelegate <NSObject>

- (void)sendWeiboResult:(NSString*)result weiboType:(NSString*)type;
- (void)sendWeiboFailed:(NSString*)result weiboType:(NSString*)type;

@end

@interface SendWeibo : NSObject

@property(nonatomic, unsafe_unretained) id<SendWeiboDelegate> delegate;
@property(nonatomic, strong) NSString *shareText;
@property(nonatomic, strong) UIImage *shareImage;
@property(nonatomic, strong) NSString *shareType;

- (void)sendWeiboWithTpye:(NSString*)type shareText:(NSString*)text shareImage:(UIImage*)image;

@end
