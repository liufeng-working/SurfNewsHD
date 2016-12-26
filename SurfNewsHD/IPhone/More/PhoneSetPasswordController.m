//
//  PhoneSetPasswordController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-6-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSetPasswordController.h"

@interface PhoneSetPasswordController ()

@end

@implementation PhoneSetPasswordController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
        _phoneNumber = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_setPasswordType == GetPasswordType) {
        self.title = @"快速找回密码";
    } else if (_setPasswordType == FirstSetPasswordType) {
        self.title = @"首次登录,请您设置密码";
    }
    
    //隐藏
    [self topGoBackView].hidden = YES;
    
    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    blankButton.frame = CGRectMake(0.0f, 0.0f, kContentWidth, self.StateBarHeight);
    [blankButton addTarget:self action:@selector(dismissKeyboard:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:blankButton];
    
    setPasswordView = [[PhoneSetPasswordView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, 235.0f)];
    [setPasswordView setPasswordType:_setPasswordType phone:_phoneNumber];
    setPasswordView.delegate = self;
    
    setPasswordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, self.StateBarHeight, kContentWidth, kContentHeight - self.StateBarHeight)
                                                  style:UITableViewStylePlain];
    setPasswordTableView.bounces = NO;
    [setPasswordTableView setBackgroundColor:[UIColor clearColor]];
    [setPasswordTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [setPasswordTableView setTableHeaderView:setPasswordView];
    [self.view addSubview:setPasswordTableView];
    
    [self addBottomToolsBar];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [setPasswordTableView addGestureRecognizer:singleFingerTap];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [setPasswordView popupKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    [setPasswordView applyTheme:night];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    [setPasswordView hideKeyboard];
}

#pragma mark PhoneSetPasswordViewDelegate methods
//除了注册,其他capType都为2
- (void)didGetVerifyCodeWithPhoneNum:(NSString *)number
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager getVerifyCode:number capType:@"2" withCompletionHandler:^(BOOL succeeded, NSInteger code) {
        if (succeeded) {
            if (code == 200) {
                [PhoneNotification autoHideWithText:@"验证码已发送到您的手机,5分钟内输入有效"];
            } else {
                [PhoneNotification autoHideWithText:[dict valueForKey:[NSString stringWithFormat:@"%@", @(code)]]];
            }
        } else {
            [PhoneNotification autoHideWithText:@"获取验证码失败,请重试"];
        }
    }];
}

- (void)didSetPasswordWithPhoneNum:(NSString *)number verify:(NSString *)code password:(NSString *)pwd
{
    [PhoneNotification manuallyHideWithIndicator];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager resetPassword:number password:pwd verify:code withCompletionHandler:^(BOOL succeeded, NSInteger code) {
        if (succeeded) {
            if (code == 200) {
                [PhoneNotification autoHideWithText:@"修改已成功,要牢记新的信息哦!"];
                [self dismissControllerAnimated:PresentAnimatedStateFromRight];
            } else {
                [PhoneNotification autoHideWithText:[dict valueForKey:[NSString stringWithFormat:@"%@", @(code)]]];
            }
        } else {
            [PhoneNotification autoHideWithText:@"注册失败,请重试"];
        }
    }];
}

- (void)didWeiboPolicy{

}

- (void)didPrivacyPolicy{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Observer methods
- (void)keyboardWillShow:(NSNotification *)notification
{
    [super addMiniKeyBoard];
    if (!keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGRect setPasswordTableViewFrame = setPasswordTableView.frame;
                             setPasswordTableViewFrame.size.height -= 216.0f;
                             setPasswordTableView.frame = setPasswordTableViewFrame;
                             
                             CGRect toolsBottomBarFrame = toolsBottomBar.frame;
                             toolsBottomBarFrame.origin.y -= 216.0f;
                             toolsBottomBar.frame = toolsBottomBarFrame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [super dismissMiniKeyBoard];
    if (keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             CGRect setPasswordTableViewFrame = setPasswordTableView.frame;
                             setPasswordTableViewFrame.size.height += 216.0f;
                             setPasswordTableView.frame = setPasswordTableViewFrame;
                             
                             CGRect toolsBottomBarFrame = toolsBottomBar.frame;
                             toolsBottomBarFrame.origin.y += 216.0f;
                             toolsBottomBar.frame = toolsBottomBarFrame;
                         }
                         completion:nil
         ];
    }
    keyboardShowing = NO;
}

- (void)dismissKeyboard:(id)sender
{
    [setPasswordView hideKeyboard];
}

@end
