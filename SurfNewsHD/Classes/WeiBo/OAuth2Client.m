//
//  OAuth2Client.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "OAuth2Client.h"
#import "GTMHTTPFetcher.h"
#import "NSDictionary+QueryString.h"
#import "NSURL+QueryInspector.h"
#import "NSString+Extensions.h"
#import "NSData+Base64.h"

@implementation OAuth2Client

@synthesize delegate;
@synthesize clientKey;
@synthesize clientSecret;
@synthesize redirectURL;
@synthesize authURL;
@synthesize tokenURL;

@synthesize clientType;

- (id)initWithClientKey:(NSString *)key
           clientSecret:(NSString *)secret
            redirectURL:(NSString *)url
     gtmFetcherDelegate:(id)theDelegate
{
    if (self = [super init]) {
        self.clientKey = key;
        self.clientSecret = secret;
        self.redirectURL = url;
        self.gtmFetcherDelegate = theDelegate;
    }
    return self;
}

- (NSURLRequest *)userAuthorizationRequestWithParameters:(NSDictionary *)additionalParameters
                                              httpMethod:(NSString *)httpMethod
{
    NSDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.clientKey forKey:@"client_id"];
    [params setValue:self.redirectURL forKey:@"redirect_uri"];
    
    
    if (additionalParameters) {
        for (NSString *key in additionalParameters) {
            [params setValue:[additionalParameters valueForKey:key] forKey:key];
        }
    }
    
    NSURL *fullURL = [NSURL URLWithString:[self.authURL stringByAppendingFormat:@"%@",
                                           [params stringWithFormEncodedComponents]]];
    NSMutableURLRequest *authRequest = [NSMutableURLRequest requestWithURL:fullURL];
    [authRequest setHTTPMethod:httpMethod];
    return authRequest;
}

//使用accesscode验证
- (void)verifyAuthorizationWithAccessCode:(NSString *)accessCode;
{
    @synchronized(self) {
        if (isVerifying) return; // don't allow more than one auth request
        
        isVerifying = YES;
        
        NSURLRequest *authRequest = [self getTokenRequest:accessCode];
        
        SEL fetcherSel = NSSelectorFromString(@"myFetcher:finishedWithData:error:");
        GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:authRequest];
        [myFetcher beginFetchWithDelegate:self.gtmFetcherDelegate
                        didFinishSelector:fetcherSel];
    }
}

//中国移动微博,新浪微博和腾讯微博的获取token请求
- (NSURLRequest*)getTokenRequest:(NSString*)accessCode
{
    NSDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"authorization_code" forKey:@"grant_type"];
    [params setValue:self.clientKey forKey:@"client_id"];
    [params setValue:self.clientSecret forKey:@"client_secret"];
    [params setValue:self.redirectURL forKey:@"redirect_uri"];
    [params setValue:accessCode forKey:@"code"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.tokenURL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[[params stringWithFormEncodedComponents] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return request;
}

@end

@implementation OAuth2Client (UIWebViewIntegration)

- (void)authorizeUsingWebView:(UIWebView *)webView;
{
    [self authorizeUsingWebView:webView additionalParameters:nil httpMethod:nil];
}

- (void)authorizeUsingWebView:(UIWebView *)webView additionalParameters:(NSDictionary *)additionalParameters httpMethod:(NSString *)httpMethod
{
    //清除webview缓存
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]) { //活动的时候不能清除缓存,否则会出错
        if ([cookie.domain rangeOfString:@"go.10086.cn"].length == 0) {
            [storage deleteCookie:cookie];
        }
    }
    
    [webView setDelegate:self];
    [webView loadRequest:[self userAuthorizationRequestWithParameters:additionalParameters httpMethod:httpMethod]];
}

#pragma mark UIWebViewDelegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request.URL absoluteString] urlDecodedString] hasPrefix:self.redirectURL]) {
        if (self.clientType == RenRenOAuth) {
            return [self extractAccessTokenFromCallbackURL:request.URL];
        } else {
            return [self extractAccessCodeFromCallbackURL:request.URL];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [self.delegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [self.delegate webView:webView didFailLoadWithError:error];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [self.delegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [self.delegate webViewDidFinishLoad:webView];
    }
}

//回调地址里获得accesscode
- (BOOL)extractAccessCodeFromCallbackURL:(NSURL *)callbackURL;
{
    if ([[callbackURL queryDictionary] valueForKey:@"code"] == nil) {
        if ([self.delegate respondsToSelector:@selector(oauthClientFailReceiveString:)]) {
            [self.delegate oauthClientFailReceiveString:nil];
        }
        return NO;
    }
    
    NSString *accessCode = [[callbackURL queryDictionary] valueForKey:@"code"];
    
    [self verifyAuthorizationWithAccessCode:accessCode];
    
    return NO;
}

//坑爹的人人网在回调地址里返回了token
- (BOOL)extractAccessTokenFromCallbackURL:(NSURL *)callbackURL
{
    NSString *query = [[callbackURL fragment] urlDecodedString]; // url中＃字符后面的部分。
    if (!query) {
        query = [callbackURL query];
    }
    NSString *error = [[NSDictionary dictionaryWithFormEncodedString:query] objectForKey:@"error"];
    if(error) {
        [self.delegate oauthClientFailReceiveString:query];
    } else {
        [self.delegate renrenOauthSuccessReceiveString:query];
    }

    return NO;
}

@end

@implementation SendWeibo

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//设置发送微博的类型以及文字和图片
- (void)sendWeiboWithTpye:(NSString *)type
                shareText:(NSString *)text
               shareImage:(UIImage *)image
{
    self.shareType = type;
    self.shareText = text;
    self.shareImage = image;
    
    SurfDbManager *manager = [SurfDbManager sharedInstance];
    
    if ([self.shareType isEqualToString:ShareToCM]) {
        NSDictionary *cmDict = [manager getCMWeiboInfoForUser:kDefaultID];
        if ([cmDict valueForKey:@"access_token"]) {
            [self sendCMWeiboRequestWithShareText:self.shareText
                                       shareImage:self.shareImage
                                            token:[cmDict valueForKey:@"access_token"]];
        }
    } else if ([self.shareType isEqualToString:ShareToSina]) {
        NSDictionary *cmDict = [manager getSinaWeiboInfoForUser:kDefaultID];
        if ([cmDict valueForKey:@"access_token"] && [cmDict valueForKey:@"uid"]) {
            [self sendSinaWeiboRequestWithShareText:self.shareText
                                         shareImage:self.shareImage
                                              token:[cmDict valueForKey:@"access_token"]];
        }
    } else if ([self.shareType isEqualToString:ShareToTencent]) {
        NSDictionary *cmDict = [manager getTencentWeiboInfoForUser:kDefaultID];
        if ([cmDict valueForKey:@"access_token"]) {
            [self sendTencentWeiboRequestWithShareText:self.shareText
                                            shareImage:self.shareImage
                                                 token:[cmDict valueForKey:@"access_token"]
                                                openId:[cmDict valueForKey:@"tencent_open_id"]];
        }
    } else if ([self.shareType isEqualToString:ShareToRenren]) {
        NSDictionary *cmDict = [manager getRenrenWeiboInfoForUser:kDefaultID];
        if ([cmDict valueForKey:@"access_token"]) {
            [self sendRenrenRequestWithShareText:self.shareText
                                      shareImage:self.shareImage
                                           token:[cmDict valueForKey:@"access_token"]];
        }
    }
}

#define kRequestStringBoundary          @"293iosfksdfkiowjksdf31jsiuwq003s02dsaffafass3qw"
#define kMultipartContentType           [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kRequestStringBoundary]

//发送中国移动微博
#define kSendCMWeiboURL                 @"http://talkapi.weibo.10086.cn/timeline/posttext.json"
#define kSendCMWeiboWithImageURL        @"http://talkapi.weibo.10086.cn/timeline/postpict.json"
- (void)sendCMWeiboRequestWithShareText:(NSString *)text shareImage:(UIImage *)image token:(NSString*)token
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:kChinaMobileWeiboAppKey forKey:@"client_id"];
    [params setObject:token forKey:@"access_token"];
    [params setObject:(text ? text : @"") forKey:@"text"];
    [params setObject:[NSNumber numberWithInt:1] forKey:@"no_sms"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    if (image) {
        [params setObject:[self imageToString:image] forKey:@"pic"];
        [request setValue:kMultipartContentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[self postBodyWithParams:params]];
        request.URL = [NSURL URLWithString:kSendCMWeiboWithImageURL];
    } else {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[params stringWithFormEncodedComponents] dataUsingEncoding:NSUTF8StringEncoding]];
        request.URL = [NSURL URLWithString:kSendCMWeiboURL];
    }
    
    [self sendWeiboRequest:request];
}

//将图片进行Base64编码
- (NSString*)imageToString:(UIImage*)image
{
    NSData *pictureData = UIImagePNGRepresentation(image);
    NSString *pictureDataString = [pictureData base64Encoding];
    return pictureDataString;
}

//发送新浪微博
#define kSendSinaWeiboURL               @"https://upload.api.weibo.com/2/statuses/update.json"
#define kSendSinaWeiboWithImageURL      @"https://upload.api.weibo.com/2/statuses/upload.json"
- (void)sendSinaWeiboRequestWithShareText:(NSString *)text shareImage:(UIImage *)image token:(NSString*)token
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
	[params setObject:(text ? text : @"") forKey:@"status"];
    [params setObject:token forKey:@"access_token"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    if (image) {
        [params setObject:image forKey:@"pic"];
        [request setValue:kMultipartContentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[self postBodyWithParams:params]];
        request.URL = [NSURL URLWithString:kSendSinaWeiboWithImageURL];
    } else {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[params stringWithFormEncodedComponents] dataUsingEncoding:NSUTF8StringEncoding]];
        request.URL = [NSURL URLWithString:kSendSinaWeiboURL];
    }
    
    [self sendWeiboRequest:request];
}

//发送腾讯微博
#define kSendTencentWeiboURL             @"https://open.t.qq.com/api/t/add"
#define kSendTencentWeiboWithImageURL    @"https://open.t.qq.com/api/t/add_pic"
- (void)sendTencentWeiboRequestWithShareText:(NSString *)text
                                  shareImage:(UIImage *)image
                                       token:(NSString*)token
                                      openId:(NSString*)openId
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:token forKey:@"access_token"];
    [params setObject:openId forKey:@"openid"];
    [params setObject:kTencentWeiboAppKey forKey:@"oauth_consumer_key"];
    [params setObject:@"2.a" forKey:@"oauth_version"];
    [params setObject:@"all" forKey:@"scope"];
    [params setObject:@"json" forKey:@"format"];
    [params setObject:(text ? text : @"") forKey:@"content"];
    [params setObject:@"127.0.0.1" forKey:@"clientip"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    if (image) {
        [params setObject:image forKey:@"pic"];
        [request setValue:kMultipartContentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[self postBodyWithParams:params]];
        request.URL = [NSURL URLWithString:kSendTencentWeiboWithImageURL];
    } else {
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[params stringWithFormEncodedComponents] dataUsingEncoding:NSUTF8StringEncoding]];
        request.URL = [NSURL URLWithString:kSendTencentWeiboURL];
    }
    
    [self sendWeiboRequest:request];
}

//人人网无图发送状态,有图发送到相册
- (void)sendRenrenRequestWithShareText:(NSString *)text shareImage:(UIImage *)image token:(NSString*)token
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"1.0" forKey:@"v"];
    [params setObject:@"json" forKey:@"format"];
    [params setObject:token forKey:@"access_token"];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    if (image) {
        [params setObject:image forKey:@"upload"];
        [params setObject:(text ? text : @"") forKey:@"caption"];
        [params setObject:@"photos.upload" forKey:@"method"];
        [request setValue:kMultipartContentType forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[self postBodyWithParams:params]];
    } else {
        [params setValue:text forKey:@"status"];
        [params setValue:@"status.set" forKey:@"method"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:[[params stringWithFormEncodedComponents] dataUsingEncoding:NSUTF8StringEncoding]];
        
    }
    request.URL = [NSURL URLWithString:kRenRenRestserverBaseURL];
    
    [self sendWeiboRequest:request];
}

//发送微博的请求
- (void)sendWeiboRequest:(NSURLRequest*)request
{
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [myFetcher beginFetchWithDelegate:self
                    didFinishSelector:@selector(myFetcher:finishedWithData:error:)];
}

//得到发送的数据
- (NSMutableData *)postBodyWithParams:(NSDictionary*)params
{
    NSMutableData *body = [NSMutableData data];
    
    NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", kRequestStringBoundary];
    NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", kRequestStringBoundary];
    
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    
    [self appendUTF8Body:body dataString:bodyPrefixString];
    
    for (id key in [params keyEnumerator]) {
        if (([[params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[params valueForKey:key] isKindOfClass:[NSData class]])) {
            [dataDictionary setObject:[params valueForKey:key] forKey:key];
            continue;
        }
        
        [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [params valueForKey:key]]];
        [self appendUTF8Body:body dataString:bodyPrefixString];
    }
    
    if ([dataDictionary count] > 0) {
        for (id key in dataDictionary) {
            NSObject *dataParam = [dataDictionary valueForKey:key];
            
            if ([dataParam isKindOfClass:[UIImage class]]) {
                NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
                [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.png\"\r\n", key]];
                [self appendUTF8Body:body dataString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
                [body appendData:imageData];
            } else if ([dataParam isKindOfClass:[NSData class]]) {
                [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key]];
                [self appendUTF8Body:body dataString:@"Content-Type: content/unknown\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
                [body appendData:(NSData*)dataParam];
            }
            [self appendUTF8Body:body dataString:bodySuffixString];
        }
    }
    
    return body;
}

- (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString
{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

//发送微博的回调方法
#pragma mark GTMHTTPFetcher Protocol
- (void)myFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)retrievedData error:(NSError *)error
{
    if (error != nil) {
        NSString *failed = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
        [self.delegate sendWeiboFailed:failed weiboType:self.shareType];
    } else {
        NSString *result = [[NSString alloc] initWithData:retrievedData encoding:NSUTF8StringEncoding];
        DJLog(@"success result:%@",result);
        [self.delegate sendWeiboResult:result weiboType:self.shareType];
    }
}

@end