//
//  LoginController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "LoginController.h"
#import "AppDelegate.h"
#import "SetPasswordController.h"
#import "CloudRootController.h"
#import "UserManager.h"

@interface LoginController ()

@end

@implementation LoginController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = ViewTitleStateSpecial;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UserManager *manager = [UserManager sharedInstance];
    if (manager.loginedUser) {
        CloudRootController *rootviewController = [[CloudRootController alloc] init];
        [self pushViewController:rootviewController animated:NO];
    }
    
    [loginView clearTextFiled];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    loginView = [[LoginView alloc] initWithFrame:CGRectMake(255.0f, 110.0f, 360.0f, 400.0f)];
    loginView.delegate = self;
    [loginView hiddenView];
    [self.view addSubview:loginView];
    
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(385.0f, 74.0f, 90.0f, 90.0f)];
    avatarImageView.image = [UIImage imageNamed:@"default_avatar"];
    [self.view addSubview:avatarImageView];
    
    UIImageView *whyLoginImageView = [[UIImageView alloc] initWithFrame:CGRectMake(255.0f, 464.0f, 357.0f, 200.0f)];
    whyLoginImageView.image = [UIImage imageNamed:@"why_login"];
    [self.view addSubview:whyLoginImageView];
    
    UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enterButton.frame = CGRectMake(700.0f, 314.0f, 133.0f, 85.0f);
    [enterButton setBackgroundImage:[UIImage imageNamed:@"enter"]
                           forState:UIControlStateNormal];
    [enterButton addTarget:self
                    action:@selector(didEnter:)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enterButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//不登录直接进入
- (void)didEnter:(UIButton*)button
{
    CloudRootController *rootviewController = [[CloudRootController alloc] init];
    [self pushViewController:rootviewController animated:YES];
}

#pragma mark LoginViewDelegate methods
- (void)didRegisterAction
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
#ifdef ipad
    SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
    [rootController setSplitPosition:kSplitPositionMin animated:NO];

#else
    
#endif
    SetPasswordController *controller = [SetPasswordController sharedInstance];
    [controller addViewToSuperViewWithType:RegisterType phone:nil];
}

- (void)didResetPasswordAction
{
    SetPasswordController *controller = [SetPasswordController sharedInstance];
    [controller addViewToSuperViewWithType:GetPasswordType phone:nil];
}

- (void)didLoginAction:(NSString *)phone password:(NSString *)pwd
{
    SurfNotification *notification = [SurfNotification surfNotificatioIndicatorAutoHide:NO];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager userLogin:phone password:pwd withCompletionHandler:^(BOOL succeeded, NSInteger code) {
        if (succeeded) {
            [[UserManager sharedInstance] findUserInfowithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData) {
                if (succeeded) {
                    [[UserManager sharedInstance] findTasksWithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData) {
                        
                    }];
                }
            }];

            if (code == 200) {
                [notification hideNotificatioIndicator:^(BOOL finished) {
                    [SurfNotification surfNotification:@"您已成功登录,冲浪有您更精彩!"];
                    CloudRootController *rootviewController = [[CloudRootController alloc] init];
                    [self pushViewController:rootviewController animated:YES];
                }];
            } else {
                [notification hideNotificatioIndicator:^(BOOL finished) {
                    [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%d", code]]];
                    if (code == 608){
                        SetPasswordController *controller = [SetPasswordController sharedInstance];
                        controller.setPasswordType = FirstSetPasswordType;
                        [controller addViewToSuperViewWithType:FirstSetPasswordType phone:phone];
                    }
                }];
            }
        } else {
            [notification hideNotificatioIndicator:^(BOOL finished) {
                [SurfNotification surfNotification:@"登录失败,请重试"];
            }];
        }
    }];
}

@end
