//
//  ReadNewsController.h
//  SurfNewsHD
//
//  Created by apple on 13-1-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfNewsViewController.h"
#define IPHONE_USERAGENT        @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B329 Safari/8536.25"
#define IPAD_USERAGENT        @"Mozilla/5.0 (iPad; CPU OS 6_1_3 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B146 Safari/8536.25"

typedef enum {
    ReadNewsUSERAGENT_IPHONE = 0,   //IPHONE
    ReadNewsUSERAGENT_IPAD = 1      //IPAD
} ReadNewsUSERAGENTStyle;

@interface ReadNewsController : SurfNewsViewController<UIWebViewDelegate>
{
    UIWebView *webview;
    UIButton *stateBtn;
    UIButton *backBtn;
    UIButton *forwardBtn;
    BOOL state;
}
@property(nonatomic,strong) NSString *webUrl;
@property(nonatomic,strong) UIWebView *webview;
@property(nonatomic,assign) BOOL state;
@property(nonatomic,assign) ReadNewsUSERAGENTStyle USERAGENT;
@end
