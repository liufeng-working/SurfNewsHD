//
//  ReadNewsController.m
//  SurfNewsHD
//
//  Created by apple on 13-1-28.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ReadNewsController.h"

@interface ReadNewsController ()

@end

@implementation ReadNewsController
@synthesize webview,webUrl,state;
@synthesize USERAGENT;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = ViewTitleStateNone;
        self.USERAGENT = ReadNewsUSERAGENT_IPAD;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"000000"];
    webview = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webview.delegate = self;

    webview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webview];
    
    UIButton *refeshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refeshBtn setBackgroundImage:[UIImage imageNamed:@"news_Back"] forState:UIControlStateNormal];
    [refeshBtn addTarget:self action:@selector(backNews) forControlEvents:UIControlEventTouchUpInside];
    refeshBtn.frame = CGRectMake(50.0f, 5.0f, 53.0f, 30.0f);
    
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:refeshBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
    [tools setTintColor:[self.navigationController.navigationBar tintColor]];
    [tools setAlpha:[self.navigationController.navigationBar alpha]];
    
    
    stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stateBtn addTarget:self action:@selector(stateUp) forControlEvents:UIControlEventTouchUpInside];
    [stateBtn setBackgroundImage:[UIImage imageNamed:@"news_Refesh"] forState:UIControlStateNormal];
    stateBtn.frame = CGRectMake(0.0f, 5.0f, 35.0f, 30.0f);
    [tools addSubview:stateBtn];
    
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"news_Left"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(webViewBack) forControlEvents:UIControlEventTouchUpInside];
    backBtn.frame = CGRectMake(50.0f, 5.0f, 35.0f, 30.0f);
    [tools addSubview:backBtn];

    
    forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forwardBtn.frame = CGRectMake(100.0f, 5.0f, 35.0f, 30.0f);
    [forwardBtn setBackgroundImage:[UIImage imageNamed:@"news_Right"] forState:UIControlStateNormal];
    [forwardBtn addTarget:self action:@selector(webViewForward) forControlEvents:UIControlEventTouchUpInside];
    [tools addSubview:forwardBtn];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    DJLog(@"%@",webUrl);
#ifdef ipad
    if (self.USERAGENT == ReadNewsUSERAGENT_IPHONE)
    {
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:IPHONE_USERAGENT,
                                     @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    }
    else if (self.USERAGENT == ReadNewsUSERAGENT_IPAD)
    {
        NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:IPAD_USERAGENT,
                                     @"UserAgent", nil];
        [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    }
#else
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:IPHONE_USERAGENT,
                                 @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
#endif
    //http://112.4.12.8:8090/ua.jsp
    [webview loadRequest:[NSMutableURLRequest requestWithURL:[NSURL URLWithString:webUrl]]];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)backNews
{
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setState:(BOOL)_state
{
    state = _state;
    /*
    if (state)
    {
        [stateBtn setTitle:@"X" forState:UIControlStateNormal];
    }
    else
    {
        [stateBtn setTitle:@"O" forState:UIControlStateNormal];
    }
     */
}
#pragma marl - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.state = YES;
    [backBtn setEnabled:[webview canGoBack]];
    [forwardBtn setEnabled:[webview canGoForward]];

}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.state = NO;
    [backBtn setEnabled:[webview canGoBack]];
    [forwardBtn setEnabled:[webview canGoForward]];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.state = NO;
}
#pragma mark - Btn
-(void)stateUp
{
    if (self.state)
    {
        [webview stopLoading];
    }else
    {
        [webview reload];
    }
}
-(void)webViewBack
{
    [webview goBack];
}
-(void)webViewForward
{
    [webview goForward];
}

@end
