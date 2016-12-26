//
//  WebPeriodicalController.h
//  SurfNewsHD
//
//  Created by apple on 13-5-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GetPeriodicalListResponse.h"
#import "PhoneSurfController.h"
#import "OfflineDownloader.h"
#import "PathUtil.h"
#import "EzJsonParser.h"

@interface WebPeriodicalController : PhoneSurfController<UIWebViewDelegate,OfflineDownloaderDelegate, UIAlertViewDelegate>
{
    UIWebView *webview;
    NSMutableArray *herfArray;
    UIActivityIndicatorView *activity;
    
    UIButton *offlineBtn;
}

@property(nonatomic,strong) PeriodicalInfo* periodicalInfo;

@end
