//
//  PhoneWeiboPolicyController.m
//  SurfNewsHD
//
//  Created by jsg on 14-9-23.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "PhoneWeiboPolicyController.h"
#define BottomToolsBarHeight 47.0f
@interface PhoneWeiboPolicyController ()

@end

@implementation PhoneWeiboPolicyController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}

- (void)setURL:(NSString*)str{
    
    //NSURL *url = [NSURL URLWithString:@"https://store.apple.com/cn"];
    m_url = [NSString stringWithString:str];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    //设置背景
    
    NSURL *url = [NSURL URLWithString:m_url];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    m_webview = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x, self.view.bounds.origin.y + 15.0f, self.view.bounds.size.width, self.view.bounds.size.height - BottomToolsBarHeight - 20.0f)];
    [m_webview loadRequest:request];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:m_webview];
    [self addBottomToolsBar];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillDisappear:animated];
}

#pragma mark NightModeChangedDelegate
- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    if (night) {
        m_webview.backgroundColor = [UIColor colorWithHexValue:0xFF19191A];
    }
    else{
        m_webview.backgroundColor = [UIColor colorWithHexValue:0xFFDCDBDB];
    }
}

@end
