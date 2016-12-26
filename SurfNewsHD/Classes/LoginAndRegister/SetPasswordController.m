//
//  SetPasswordController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-23.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SetPasswordController.h"
#import "AppDelegate.h"
#import "Encrypt.h"
#import "CloudRootController.h"
#import "SurfRootViewController.h"
#import "SurfRightController.h"
@interface SetPasswordController ()

@end

@implementation SetPasswordController

+ (SetPasswordController*)sharedInstance
{
    static SetPasswordController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SetPasswordController alloc] init];
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

	setPasswordView = [[SetPasswordView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 360.0f, 400.0f)];
    CGPoint center = CGPointMake(self.view.center.x + 46.0f, self.view.center.y);
    setPasswordView.center = center;
    
    setPasswordView.delegate = self;
    [self.view addSubview:setPasswordView];
}

- (void)addViewToSuperViewWithType:(SetPasswordType)type phone:(NSString *)number
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    UIViewController *viewController = appDelegate.window.rootViewController;
    [viewController.view addSubview:self.view];
    self.setPasswordType = type;
    [setPasswordView setPasswordType:self.setPasswordType phone:number];
}

//移除view
- (void)tapDetected:(UITapGestureRecognizer *)sender
{
    if (keyboardShowing) {
        [setPasswordView.phoneTextField resignFirstResponder];
        [setPasswordView.verifyTextFiled resignFirstResponder];
        [setPasswordView.passwordTextField resignFirstResponder];
    } else {
        [self.view removeFromSuperview];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SetPasswordViewDelegate methods
- (void)didCancleSetPassword
{
    if (keyboardShowing) {
        [setPasswordView.phoneTextField resignFirstResponder];
        [setPasswordView.verifyTextFiled resignFirstResponder];
        [setPasswordView.passwordTextField resignFirstResponder];
    } else {
        [self.view removeFromSuperview];
    }
}

- (void)didGetVerifyCodeWithPhoneNum:(NSString *)number
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    if (self.setPasswordType == RegisterType) {
        [manager getVerifyCode:number capType:@"1" withCompletionHandler:^(BOOL succeeded, int code) {
            if (succeeded) {
                if (code == 200) {
                    [SurfNotification surfNotification:@"验证码已发送到您的手机,5分钟内输入有效"];
                } else {
                    [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%d", code]]];
                }
            } else {
                [SurfNotification surfNotification:@"获取验证码失败,请重试"];
            }
        }];
    } else {
        [manager getVerifyCode:number capType:@"2" withCompletionHandler:^(BOOL succeeded, int code) {
            if (succeeded) {
                if (code == 200) {
                    [SurfNotification surfNotification:@"验证码已发送到您的手机,5分钟内输入有效"];
                } else {
                    [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%d", code]]];
                }
            } else {
                [SurfNotification surfNotification:@"获取验证码失败,请重试"];
            } 
        }];
    }
}

- (void)didSetPasswordWithPhoneNum:(NSString *)number verify:(NSString *)code password:(NSString *)pwd
{
    SurfNotification *notification = [SurfNotification surfNotificatioIndicatorAutoHide:NO];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    if (self.setPasswordType == RegisterType) {
        [manager userRegister:number password:pwd verify:code withCompletionHandler:^(BOOL succeeded, int code) {
            if (succeeded) {
                if (code == 200) {
                    [notification hideNotificatioIndicator:^(BOOL finished) {
                        [self.view removeFromSuperview];
                        [SurfNotification surfNotification:@"您已成功注册,开始一段神奇的冲浪体验!"];
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
#ifdef ipad
                        SurfRightController *rightController = rootController.rightController;
                        [rightController.loginController didEnter:nil];
#else
                        
#endif
                    }];
                } else {
                    [notification hideNotificatioIndicator:^(BOOL finished) {
                        [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%d", code]]];
                    }];
                }
            } else {
                [notification hideNotificatioIndicator:^(BOOL finished) {
                    [SurfNotification surfNotification:@"注册失败,请重试"];
                }];
            }
        }];
    } else {
        [manager resetPassword:number password:pwd verify:code withCompletionHandler:^(BOOL succeeded, int code) {
            if (succeeded) {
                if (code == 200) {
                    [notification hideNotificatioIndicator:^(BOOL finished) {
                        [self.view removeFromSuperview];
                        [SurfNotification surfNotification:@"修改已成功,要牢记新的信息哦!"];
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        SurfRootViewController *rootController = (SurfRootViewController *)appDelegate.window.rootViewController;
#ifdef  ipad
                        SurfRightController *rightController = rootController.rightController;
                        [rightController.loginController didEnter:nil];
#else
                        
#endif
                    }];
                } else {
                    [notification hideNotificatioIndicator:^(BOOL finished) {
                        [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%d", code]]];
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
                             CGRect frame = setPasswordView.frame;
                             frame.origin.y -= 252.0f;
                             setPasswordView.frame = frame;
                         }
                         completion:nil
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
                             CGRect frame = setPasswordView.frame;
                             frame.origin.y += 252.0f;
                             setPasswordView.frame = frame;
                         }
                         completion:nil
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
