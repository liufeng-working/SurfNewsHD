//
//  iTunesLookupUtil.m
//  SurfNewsHD
//
//  Created by Jerry Yu on 13-6-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "iTunesLookupUtil.h"
#import "EzJsonParser.h"
#import "CheckUpgradeRequest.h"
#import "NSString+Extensions.h"
#import "GTMHTTPFetcher.h"
#import "AppDelegate.h"
#import "NSString+Extensions.h"
#import "PhoneNotification.h"
#import "JSONKit.h"


#define NEVERSHOWVERSION_KEY     [NSString stringWithFormat:@"%@_NEVER_KEY", [self getLocalVersion]]
#define SHOWTIMESVERSION_KEY     @"SHOWTIMES"

@implementation iTunesLookupUtil

- (id)init
{
    self = [super init];
    if (self)
    {
        self.isError = NO;
    }
    
    return self;
}

+ (iTunesLookupUtil *)sharedInstance
{
    static iTunesLookupUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[iTunesLookupUtil alloc] init];
    });
    
    return sharedInstance;
}

- (void)checkUpdate
{
    openTimes=0;
    NSString *netVerdsionStr=[AppSettings stringForKey:SHOWTIMESVERSION_KEY];
    if (netVerdsionStr) {
        openTimes=[netVerdsionStr integerValue];
        if (5>openTimes) {
            ++openTimes;
        }
        else{
            openTimes=5;
        }
        
        [AppSettings setInteger:openTimes forKey:SHOWTIMESVERSION_KEY];
    }

    if(self.isLoading) return;
    
    self->_isLoading = YES;
    NSMutableURLRequest *request = nil;
#ifdef ENTERPRISE
    
    request = (NSMutableURLRequest*)[SurfRequestGenerator checkUpgradeEnterpriseRequest:!self.isMT];
 
#else
    NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/cn/lookup?id=%d",kAppAppleId];
    request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    request.timeoutInterval = 10;
    
#endif
    if (self.isMT)
    {
        [PhoneNotification manuallyHideWithText:@"检查更新中,请稍候..." indicator:YES];
    }
    
    GTMHTTPFetcher* fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:^(NSData* data,NSError* error)
     {
         [PhoneNotification hideNotification];
         self->_isLoading = NO;
         if(error)
         {
             //网络错误
             self.isError = YES;
             
             if (self.isMT)
             {
                 [PhoneNotification autoHideWithText:@"请求超时"];
             }
         }
         else
         {
#ifdef ENTERPRISE
             //检测成功
             NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
             
             [self ENTERPRISEVersion:body];

#else
             //检测成功
           /*  NSString* body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
             
             NSString * officiVersion = [self getNetVersion:body];
             NSString *localVersion = [self getLocalVersion];
             
             if ([officiVersion isVersionHigherThan:localVersion])
             {
                 if ([[AppSettings sharedInstance] stringForKey:NEVERSHOWVERSION_KEY]&&!self.isMT) {
                     return ;
                 }
                 
                 NSString *showTimes=[[AppSettings sharedInstance] stringForKey: SHOWTIMESVERSION_KEY];
                 if (showTimes && openTimes<5&&!self.isMT) {
                     return;
                 }
                 
                 self.hasNewVersion = YES;
                 NSString *releaseNotes = [self getInfo:body];
                 NSString*titleStr=[NSString stringWithFormat:@"检测到新版本(%@)",officiVersion];
                 //有新版本，立刻提醒，不管是后台检测还是用户手动检测
                 UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleStr message:releaseNotes delegate:self cancelButtonTitle:nil otherButtonTitles:@"立即更新",@"不再提醒",@"稍后再说",nil];
                 [alertView show];
             }
             else
             {
                 //无新版本，如果是用户手动检测，则需要提示
                 if (self.isMT)
                    [PhoneNotification autoHideWithText:@"当前已经是最新版本"];
             }
*/
#endif
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:CALLBACK object:nil];
         
     }];
    
}

/**
 *  企业版版本
 *
 *  @param body 请求的HTTP 内容
 */
- (void)ENTERPRISEVersion:(NSString *)body
{
    NSDictionary *dict = [body objectFromJSONString];
    NSDictionary *sd = [dict objectForKey:@"sd"];
    NSString *verStr = [sd objectForKey:@"verName"];
    
    if (!sd && [sd isEqual:[NSNull null]]) {
        //无新版本，如果是用户手动检测，则需要提示
        if (self.isMT)
            [PhoneNotification autoHideWithText:@"当前已经是最新版本"];
        return;
    }
    
    // 判断服务器版本号是否比本地的版本高
    if ([verStr isVersionHigherThan:[self getLocalVersion]]){
        if ([AppSettings stringForKey:NEVERSHOWVERSION_KEY]&&!self.isMT) {
            return ;
        }
        
        NSString *showTimes=[AppSettings stringForKey: SHOWTIMESVERSION_KEY];
        if (showTimes && openTimes<5&&!self.isMT) {
            return;
        }
        
        self.hasNewVersion = YES;
        NSString *releaseNotes = [sd objectForKey:@"ut"];
        NSString *enterpriseStr = [sd objectForKey:@"updateUrl"];
        if ([enterpriseStr hasSuffixCaseInsensitive:@".ipa"]) {
            _enterpriseStr = @"itms-services://?action=download-manifest&url=https://10658123.cn/surfnews.plist";
        }
        else
            _enterpriseStr = enterpriseStr;
        NSString*titleStr=[NSString stringWithFormat:@"检测到新版本(%@)",verStr];
        //有新版本，立刻提醒，不管是后台检测还是用户手动检测
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:titleStr message:releaseNotes delegate:self cancelButtonTitle:nil otherButtonTitles:@"立即更新",@"不再提醒",@"稍后再说",nil];
        [alertView show];
    }
    else
    {
        //无新版本，如果是用户手动检测，则需要提示
        if (self.isMT)
            [PhoneNotification autoHideWithText:@"当前已经是最新版本"];
    }
    
}

- (NSString *)getLocalVersion
{
    NSString *locationVersionStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];

    return locationVersionStr;
}

- (NSString *)getNetVersion:(NSString *)body
{
    NSDictionary *dict = [body objectFromJSONString];
    NSArray *resultsArr = [dict objectForKey:@"results"];
    NSString *version = @"1.0.0";//不要给nil，防止外面匹配的时候空指针
    for (NSDictionary *dic in resultsArr)
    {
        version = [NSString stringWithFormat:@"%@", [dic objectForKey:@"version"]];
//        self.updateUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"trackViewUrl"]]];
        self.updateUrl = [NSString stringWithFormat:@"%@", [dic objectForKey:@"trackViewUrl"]];
    }
    
    return version;
}


- (NSString *)getInfo:(NSString *)body
{
    NSDictionary *dict = [body objectFromJSONString];
    NSArray *resultsArr = [dict objectForKey:@"results"];
    NSString *releaseNotes = nil;
    for (NSDictionary *dic in resultsArr)
    {
        //releaseNotes
         releaseNotes = [NSString stringWithFormat:@"%@", [dic objectForKey:@"releaseNotes"]];
    }
    if (releaseNotes)
        return releaseNotes;
    else
        return @" ";
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#ifdef ENTERPRISE
    if (buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_enterpriseStr]];
        
        exit(0);
    }
    else if(1 == buttonIndex){
        [AppSettings setInteger:1 forKey:NEVERSHOWVERSION_KEY];
    }
    else if(2 == buttonIndex){
        [AppSettings setInteger:1 forKey:SHOWTIMESVERSION_KEY];
    }
#else
    if (buttonIndex == 0)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/cn/app/sandman/id%d?mt=8",kAppAppleId]]];
    }
    else if(1 == buttonIndex){
        [AppSettings setInteger:1 forKey:NEVERSHOWVERSION_KEY];
    }
    else if(2 == buttonIndex){
        [AppSettings setInteger:1 forKey:SHOWTIMESVERSION_KEY];
    }
#endif
}

@end
