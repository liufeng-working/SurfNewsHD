//
//  LevelInfoViewController.m
//  SurfNewsHD
//
//  Created by 潘俊申 on 15/10/22.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "LevelInfoViewController.h"
@interface LevelInfoViewController ()

@end

@implementation LevelInfoViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.titleState = PhoneSurfControllerStateTop;


    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"等级说明";

    CGFloat vX = self.StateBarHeight;
    CGFloat xW = CGRectGetWidth(self.view.bounds);
    CGFloat vH = CGRectGetHeight(self.view.bounds)-vX;
    CGRect vR = CGRectMake(0, vX, xW, vH);
    LevelInfoWebView = [[UIWebView alloc] initWithFrame:vR];
    LevelInfoWebView.backgroundColor = [UIColor clearColor];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"rank_info" ofType:@"html"];
    NSString *htmlCont = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [LevelInfoWebView loadHTMLString:htmlCont baseURL:baseURL];
    [self.view  addSubview:LevelInfoWebView];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
