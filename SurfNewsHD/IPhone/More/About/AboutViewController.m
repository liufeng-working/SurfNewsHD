//
//  AboutViewController.m
//  iOSUIFrame
//
//  Created by Jerry Yu on 13-5-22.
//  Copyright (c) 2013年 adways. All rights reserved.
//

#import "AboutViewController.h"
#import "AppSettings.h"
#import "NotificationManager.h"
#import "SurfJsonRequestBase.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"关于";
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0f, 40.0f+self.StateBarHeight,
                                                                           76.0f, 76.0f)];
    imageView.image = [UIImage imageNamed:@"aboutLogo.png"];
    
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:
                                                                           self action:@selector(UserClicked:)];
    
    [imageView addGestureRecognizer:singleTap];
    
    ClickNum = 0;
    
    [self.view addSubview:imageView];
    NSString *titleString = [NSString stringWithFormat:@"版本号：v%@\n中国移动通信  版权所有\n",version];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0f, imageView.frame.origin.y, kContentWidth- 40.0f, 40.0f)];
    titleLabel.text =titleString;
    titleLabel.font = [UIFont systemFontOfSize:12.0f];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 2;
    titleLabel.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor colorWithHexString:@"34393d"];
    [self.view addSubview:titleLabel];
    
    UILabel *desLabel = [[UILabel alloc] initWithFrame:CGRectMake(130.0f,                  imageView.frame.origin.y +40.0f, kContentWidth- 40.0f, 40.0f)];
    desLabel.text =@"网址：http://go.10086.cn\n飞信群：60708482";
    desLabel.font = [UIFont systemFontOfSize:9.0f];
    desLabel.backgroundColor = [UIColor clearColor];
    desLabel.numberOfLines = 2;
    desLabel.textColor = [UIColor colorWithHexString:@"999292"];
    [self.view addSubview:desLabel];
    
    
    //by yujiuyin
    NSString *detailStr = @"        冲浪快讯新闻资讯客户端由中国移动通信集团江苏有限公司、新华网股份有限公司、新华社江苏分社三方共同出品。新华网与新华社江苏分社作为媒体资质及内容资源提供方为本客户端提供内容整合服务，发布权威、原创内容，实现精品资讯阅读，本客户端版权归中国移动通信集团所有。";
    UILabel *detailLab = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, desLabel.frame.origin.y + 45, kContentWidth- 50.0f, 90.0f)];
    detailLab.text =detailStr;
    detailLab.font = [UIFont systemFontOfSize:12.0f];
    detailLab.backgroundColor = [UIColor clearColor];
    detailLab.numberOfLines = 6;
    detailLab.textColor = [[ThemeMgr sharedInstance]isNightmode]?[UIColor whiteColor]:[UIColor colorWithHexString:@"34393d"];
    [self.view addSubview:detailLab];
}

- (void)initToolBar
{
    [self addBottomToolsBar];
}

-(void)UserClicked:(UIGestureRecognizer *)gestureRecognizer{
    ClickNum++;
    if (ClickNum == 10) {
        
        NSString *token = [NotificationManager getDeviceToken];
        
        SurfJsonRequestBase *surfJsonRequestBase=[[SurfJsonRequestBase alloc] init];
        NSString *did = surfJsonRequestBase.did;
        NSString *cid = surfJsonRequestBase.cid;
        
#if ENTERPRISE
        Token = [NSString stringWithFormat:@"Enterprise token : %@ ,\n did : %@ , \n cid : %@" , token , did, cid];
#elif JAILBREAK
        Token = [NSString stringWithFormat:@"Jailbreak token : %@ ,\n did : %@ , \n cid : %@" , token , did, cid];
#else
        Token = [NSString stringWithFormat:@"token : %@ ,\n did : %@ , \n cid : %@" , token , did, cid];
#endif
        
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"提示" message:Token delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"复制到剪切板", nil];
        [alter show];
    
        [self.view becomeFirstResponder];
        
        //重置
        ClickNum = 0;
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        return;
    }
    else if(buttonIndex == 1){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = Token;
    }
}



@end
