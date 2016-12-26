//
//  ContentShareController.m
//  SurfNewsHD
//
//  Created by jsg on 13-10-17.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "ContentShareController.h"
#import "AppDelegate.h"

#define kAnimateTime 0.2f
#define KeyboardSystemDefault 216.0f
#define KeyboardExtendCN 19.0f
@interface ContentShareController ()
{
    CGFloat _keyboardH;
}

@end

@implementation ContentShareController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.titleState = PhoneSurfControllerStateTop;
        
        m_contentShareView = [[ContentShareView alloc] initWithFrame:CGRectMake(0.0f, self.StateBarHeight, kContentWidth ,kContentHeight - self.StateBarHeight - 47.0f)];
    }
    return self;
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editKeyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(editKeyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *titleStr;

    
    if (m_contentShareView.m_shareToWeibo == SinaWeibo) {
        titleStr = [NSString stringWithFormat:@"分享到新浪微博"];
    } else if (m_contentShareView.m_shareToWeibo == TencentWeibo) {
        titleStr = [NSString stringWithFormat:@"分享到腾讯微博"];
    } else if (m_contentShareView.m_shareToWeibo == ChinaMobileWeibo) {
        titleStr = [NSString stringWithFormat:@"分享到中国移动微博"];
    }
    
    self.title = titleStr;
    
    m_contentShareView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_contentShareView];
    
    sendWeibo = [[SendWeibo alloc] init];
    [sendWeibo setDelegate:self];

    [self initBottomToolsBar:NO];
    m_toolsBottomBar = [self getBottomToolsBar];
    [self addButtonOnToolsBar];
    
    
}

- (ContentShareView *)curShareView{
    return m_contentShareView;
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    [m_contentShareView nightModeChange];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addButtonOnToolsBar
{
    if(m_contentShareView.m_shareToWeibo == SinaWeibo){
        shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        shareButton.frame = CGRectMake(kContentWidth - 200.0f, 4.0f, 55.0f, 38.0f);
        [shareButton setTitle:@"" forState:UIControlStateNormal];
        [shareButton setBackgroundImage:[UIImage imageNamed:@"@.png"] forState:UIControlStateNormal];
        [shareButton.titleLabel setFont:[UIFont systemFontOfSize:25.0f]];
        [shareButton addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
        [m_toolsBottomBar addSubview:shareButton];
    }
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(kContentWidth - 64.0f, 4.0f, 58.0f, 38.0f);
    [sendButton setTitle:@"发布" forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"]
                            forState:UIControlStateNormal];

    [sendButton.titleLabel setFont:[UIFont systemFontOfSize:16.0f]];
    [sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [m_toolsBottomBar addSubview:sendButton];
}

- (void)clearButtonOnToolsBar{
    [shareButton removeFromSuperview];
}

//多个图片链接
//m_contentShareView.m_shareArray
//分享文字
//m_contentShareView.m_shareWord.text 
//新闻地址
//m_contentShareView.m_shareNewsAds
//微博类型
//m_contentShareView.m_shareToWeibo
//分享图片 UIImage
//m_contentShareView.m_shareImage

- (IBAction)share:(id)sender{
    
    PhoneSinaWeiboUserFriendsController *c = [[PhoneSinaWeiboUserFriendsController alloc] init];
    c.delegate = self;
    [self presentController:c animated:PresentAnimatedStateFromRight];
}

- (IBAction)send:(id)sender{
    NSString *newsAds = [m_contentShareView.m_shareNewsAds isEqualToString:@""] ? @"":[m_contentShareView.m_shareNewsAds completeUrl];
    NSString *text = [NSString stringWithFormat:@"%@ %@",
                      m_contentShareView.m_shareStr == nil ? @"" :  m_contentShareView.m_shareStr,
                      newsAds];
    //[m_contentShareView.m_shareNewsAds completeUrl]
    NSLog(@"%@",text);
    [PhoneNotification manuallyHideWithIndicator];
    
    if (m_contentShareView.m_shareToWeibo == SinaWeibo) {
        [sendWeibo sendWeiboWithTpye:ShareToSina shareText:text shareImage:m_contentShareView.m_shareImage];
    } else if (m_contentShareView.m_shareToWeibo == TencentWeibo) {
        [sendWeibo sendWeiboWithTpye:ShareToTencent shareText:text shareImage:m_contentShareView.m_shareImage];
    } else if (m_contentShareView.m_shareToWeibo == ChinaMobileWeibo) {
        [sendWeibo sendWeiboWithTpye:ShareToCM shareText:text shareImage:m_contentShareView.m_shareImage];
    }
}

#pragma mark SendWeiboDelegate methods
//发送微博成功
- (void)sendWeiboResult:(NSString *)result weiboType:(NSString *)type
{
    [theApp commitShareOperation];      // 分享成功
    [self dismissControllerAnimated:PresentAnimatedStateFromRight];
}

//发送微博失败
- (void)sendWeiboFailed:(NSString *)result weiboType:(NSString *)type
{
    /****短时间内，分享相同的内容，也是会分享失败的，想同的标准就是url或者标题
     {"error":"repeat content!","error_code":20019,"request":"/2/statuses/update.json"}
     */
    [PhoneNotification autoHideWithText:@"分享失败"];
}

#pragma mark PhoneSinaWeiboUserFriendsControllerDelegate methods
- (void)selectFriendsToShare:(NSArray *)array controller:(PhoneSinaWeiboUserFriendsController *)controller
{
    NSString *peopleList = @"";
    for (NSInteger num = 0; num < [array count]; num++) {
        SinaWeiboUserInfo *userInfo = [array objectAtIndex:num];
        NSString *name = userInfo.name;
        NSString *people = [NSString stringWithFormat:@" @%@",name];
        peopleList = [peopleList stringByAppendingString:people];
    }

    NSString* shareStr = [NSString stringWithFormat:@"%@%@",m_contentShareView.m_shareWord.text,peopleList];
    
    //字数超过120
    if ([shareStr length] > 120) {
        [PhoneNotification autoHideWithText:@"字数超过限制"];
        [self dismissControllerAnimated:PresentAnimatedStateFromRight];
    }
    else{
        [m_contentShareView.m_shareWord setText:shareStr];
        m_contentShareView.m_shareStr = shareStr;
        [m_contentShareView remainlab:shareStr];
    }

    NSLog(@"%@",shareStr);

    
    [controller dismissControllerAnimated:PresentAnimatedStateFromRight];
}

#pragma mark Observer methods
- (void)editKeyboardWillShow:(NSNotification *)notification
{
    NSDictionary * dic = notification.userInfo;
    CGRect rect = [dic[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardH = rect.size.height;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         m_toolsBottomBar.frame = CGRectMake(0.0f, CGRectGetHeight(self.view.frame) - kToolsBarHeight - _keyboardH,self.view.frame.size.width, kToolsBarHeight);
                     }
                     completion:nil
     ];

    keyboardShowing = YES;
}

- (void)editKeyboardWillHide:(NSNotification *)notification
{

    if (keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGRect toolsBottomBarFrame = m_toolsBottomBar.frame;
                             toolsBottomBarFrame.origin.y += _keyboardH;
                             m_toolsBottomBar.frame = toolsBottomBarFrame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = NO;
}

@end

