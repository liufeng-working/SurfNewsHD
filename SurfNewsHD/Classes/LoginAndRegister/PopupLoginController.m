//
//  PopupLoginController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-26.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PopupLoginController.h"
#import "PublicPopupView.h"
#import "AppDelegate.h"
#import "SetPasswordController.h"

@interface PopupLoginController ()

@end

@implementation PopupLoginController

+ (PopupLoginController*)sharedInstance
{
    static PopupLoginController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PopupLoginController alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = ViewTitleStateNone;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *viewController = appDelegate.window.rootViewController;
    self.view.frame = viewController.view.bounds;
    [self.view setBackgroundColor:[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f]];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    [backgroundView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:backgroundView];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(tapDetected:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [backgroundView addGestureRecognizer:tapRecognizer];
    
    loginView = [[LoginView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 360.0f, 400.0f)];
    centerPoint = CGPointMake(self.view.center.x + 46.0f, self.view.center.y);
    leftCenterPoint = CGPointMake(-200.0f, self.view.center.y);
    rightCenterPoint = CGPointMake(1224.0f, self.view.center.y);
    loginView.center = centerPoint;
    loginView.delegate = self;
    [self.view addSubview:loginView];
    
    setPasswordView = [[SetPasswordView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 360.0f, 400.0f)];
    setPasswordView.center = rightCenterPoint;
    setPasswordView.delegate = self;
    [self.view addSubview:setPasswordView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//将登录界面加到整个view上
- (void)addLoginViewToSuperView
{
    [loginView clearTextFiled];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *viewController = appDelegate.window.rootViewController;
    self.view.alpha = 0.0f;
    [viewController.view addSubview:self.view];
    
    animating = YES;
    [UIView animateWithDuration:0.3f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.view.alpha = 1.0f;
                     }
                     completion:^(BOOL finished) {
                         animating = NO;
                     }
     ];
}

//移除view
- (void)tapDetected:(UITapGestureRecognizer *)sender
{
    if (keyboardShowing) {
        [loginView.phoneTextField resignFirstResponder];
        [loginView.passwordTextField resignFirstResponder];
        [setPasswordView.phoneTextField resignFirstResponder];
        [setPasswordView.verifyTextFiled resignFirstResponder];
        [setPasswordView.passwordTextField resignFirstResponder];
    } else {
        [self.view removeFromSuperview];
        loginView.center = centerPoint;
        setPasswordView.center = rightCenterPoint;
    }
}

//第一次登录,设置密码
- (void)firstSetPasswordAction:(NSString*)phone
{
    if (animating) {
        return;
    }
    
    [loginView.phoneTextField resignFirstResponder];
    [loginView.passwordTextField resignFirstResponder];
    
    passwordType = FirstSetPasswordType;
    [setPasswordView setPasswordType:passwordType phone:phone];
    
    [self viewSwitchAnimate];
}

//登录界面和设置密码界面切换的动画
- (void)viewSwitchAnimate
{
    [UIView animateWithDuration:0.5f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         loginView.center = leftCenterPoint;
                         setPasswordView.center = centerPoint;
                     }
                     completion:^(BOOL finished) {
                         animating = NO;
                     }
     ];
}

#pragma mark LoginViewDelegate methods
//登录界面点击注册按钮的delegate方法
- (void)didRegisterAction
{
    if (animating) {
        return;
    }
    
    [loginView.phoneTextField resignFirstResponder];
    [loginView.passwordTextField resignFirstResponder];
    
    passwordType = RegisterType;
    [setPasswordView setPasswordType:passwordType phone:nil];

    [self viewSwitchAnimate];
}

//登录界面点击取回密码按钮的delegate方法
- (void)didResetPasswordAction
{
    if (animating) {
        return;
    }
    
    [loginView.phoneTextField resignFirstResponder];
    [loginView.passwordTextField resignFirstResponder];
    
    passwordType = GetPasswordType;
    [setPasswordView setPasswordType:passwordType phone:nil];
    
    [self viewSwitchAnimate];
}

//登录界面登录按钮的delegate方法
- (void)didLoginAction:(NSString *)phone password:(NSString *)pwd
{
    SurfNotification *notification = [SurfNotification surfNotificatioIndicatorAutoHide:NO];
    
    [loginView.phoneTextField resignFirstResponder];
    [loginView.passwordTextField resignFirstResponder];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager userLogin:phone password:pwd withCompletionHandler:^(BOOL succeeded, NSInteger code) {
        if (succeeded) {
            if (code == 200) {
                [notification hideNotificatioIndicator:^(BOOL finished) {
                    [SurfNotification surfNotification:@"您已成功登录,冲浪有您更精彩!"];
                    [self.view removeFromSuperview];
                }];
            } else{
                [notification hideNotificatioIndicator:^(BOOL finished) {
                    [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%@", @(code)]]];
                    if (code == 608){
                        [self firstSetPasswordAction:phone];
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

#pragma mark  SetPasswordViewDelegate methods
//设置密码界面的取消按钮delegate方法
- (void)didCancleSetPassword
{
    [setPasswordView.phoneTextField resignFirstResponder];
    [setPasswordView.verifyTextFiled resignFirstResponder];
    [setPasswordView.passwordTextField resignFirstResponder];
    [self.view removeFromSuperview];
    loginView.center = centerPoint;
    setPasswordView.center = rightCenterPoint;
}

//设置密码界面的获得验证码delegate方法
- (void)didGetVerifyCodeWithPhoneNum:(NSString *)number
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    if (passwordType == RegisterType) {
        [manager getVerifyCode:number capType:@"1" withCompletionHandler:^(BOOL succeeded, NSInteger code) {
            if (succeeded) {
                if (code == 200) {
                    [SurfNotification surfNotification:@"验证码已发送到您的手机,5分钟内输入有效"];
                } else {
                    [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%@", @(code)]]];
                }
            } else {
                [SurfNotification surfNotification:@"获取验证码失败,请重试"];
            }
        }];
    } else {
        [manager getVerifyCode:number capType:@"2" withCompletionHandler:^(BOOL succeeded, NSInteger code) {
            if (succeeded) {
                if (code == 200) {
                    [SurfNotification surfNotification:@"验证码已发送到您的手机,5分钟内输入有效"];
                } else {
                    [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%@", @(code)]]];
                }
            } else {
                [SurfNotification surfNotification:@"获取验证码失败,请重试"];
            }
        }];
    }
}

//设置密码界面的注册/确定按钮的delegate方法
- (void)didSetPasswordWithPhoneNum:(NSString *)number verify:(NSString *)code password:(NSString *)pwd
{
    SurfNotification *notification = [SurfNotification surfNotificatioIndicatorAutoHide:NO];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    if (passwordType == RegisterType) {
        [manager userRegister:number password:pwd verify:code withCompletionHandler:^(BOOL succeeded, NSInteger code) {
            if (succeeded) {
                if (code == 200) {
                    [notification hideNotificatioIndicator:^(BOOL finished) {
                        [self didCancleSetPassword];
                        [SurfNotification surfNotification:@"您已成功注册,开始一段神奇的冲浪体验!"];
                    }];
                } else {
                    [notification hideNotificatioIndicator:^(BOOL finished) {
                        [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%@", @(code)]]];
                    }];
                }
            } else {
                [notification hideNotificatioIndicator:^(BOOL finished) {
                    [SurfNotification surfNotification:@"注册失败,请重试"];
                }];
            }
        }];
    } else {
        [manager resetPassword:number password:pwd verify:code withCompletionHandler:^(BOOL succeeded, NSInteger code) {
            if (succeeded) {
                if (code == 200) {
                    [notification hideNotificatioIndicator:^(BOOL finished) {
                        [self didCancleSetPassword];
                        [SurfNotification surfNotification:@"修改已成功,要牢记新的信息哦!"];
                    }];
                } else {
                    [notification hideNotificatioIndicator:^(BOOL finished) {
                        [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%@", @(code)]]];
                    }];
                }
            } else {
                [notification hideNotificatioIndicator:^(BOOL finished) {
                    [SurfNotification surfNotification:@"密码修改失败,请重试"];
                }];
            }
        }];
    }
}

#pragma mark Observer methods
- (void)keyboardWillShow:(NSNotification *)notification
{
    if (!keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             UIView *view = (loginView.center.x == centerPoint.x &&
                                             loginView.center.y == centerPoint.y) ? loginView : setPasswordView;
                             CGRect frame = view.frame;
                             frame.origin.y -= 252.0f;
                             view.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             animating = NO;
                         }
         ];
    }
    keyboardShowing = YES;
    
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    if (keyboardShowing) {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             UIView *view = (loginView.center.x == centerPoint.x &&
                                             loginView.center.y == centerPoint.y - 252.0f) ? loginView : setPasswordView;
                             CGRect frame = view.frame;
                             frame.origin.y += 252.0f;
                             view.frame = frame;
                         }
                         completion:^(BOOL finished) {
                             animating = NO;
                         }
         ];
    }
    keyboardShowing = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

@end
