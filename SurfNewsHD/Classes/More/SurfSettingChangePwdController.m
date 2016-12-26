//
//  SurfSettingChangePwdController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-27.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfSettingChangePwdController.h"
#import "NSString+Extensions.h"
#import "UserManager.h"

@implementation ChangePwdView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        accountLabel = [[UILabel alloc] initWithFrame:CGRectMake(2.0f, 0.0f, self.bounds.size.width - 28.0f, 35.0f)];
        [accountLabel setBackgroundColor:[UIColor clearColor]];
        [accountLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [accountLabel setTextColor:[UIColor blackColor]];
        [self addSubview:accountLabel];
        UserManager *manager = [UserManager sharedInstance];
        accountLabel.text = manager.loginedUser.phoneNum;
        
        verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        verifyButton.frame = CGRectMake(0.0f, 45.0f, self.bounds.size.width - 24.0f, 35.0f);
        [verifyButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [verifyButton setBackgroundColor:[UIColor colorWithHexString:@"7B7777"]];
        [verifyButton setTitleColor:[UIColor colorWithHexString:@"DED9D1"]
                           forState:UIControlStateNormal];
        [verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [verifyButton addTarget:self
                         action:@selector(getVerifyCode:)
               forControlEvents:UIControlEventTouchUpInside];
        verifyButton.layer.cornerRadius = 6.0f;
        [self addSubview:verifyButton];
        
        UIView *verifyBg = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 100.0f, self.bounds.size.width - 24.0f, 35.0f)];
        verifyBg.backgroundColor = [UIColor colorWithHexString:@"7B7777"];
        verifyBg.layer.cornerRadius = 6.0f;
        [self addSubview:verifyBg];
        
        verifyTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(5.0f, 100.0f, self.bounds.size.width - 34.0f, 35.0f)];
        verifyTextFiled.delegate = self;
        [verifyTextFiled setTextColor:[UIColor colorWithHexString:@"DED9D1"]];
        [verifyTextFiled setBackgroundColor:[UIColor clearColor]];
        [verifyTextFiled setFont:[UIFont systemFontOfSize:15.0f]];
        [verifyTextFiled setPlaceholder:@"请输入验证码"];
        verifyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        verifyTextFiled.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        verifyTextFiled.layer.cornerRadius = 6.0f;
        [self addSubview:verifyTextFiled];
        
        UIView *passwordBg = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 155.0f, self.bounds.size.width - 24.0f, 35.0f)];
        passwordBg.backgroundColor = [UIColor colorWithHexString:@"7B7777"];
        passwordBg.layer.cornerRadius = 6.0f;
        [self addSubview:passwordBg];
        
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(5.0f, 155.0f, self.bounds.size.width - 34.0f, 35.0f)];
        passwordTextField.delegate = self;
        [passwordTextField setTextColor:[UIColor colorWithHexString:@"DED9D1"]];
        [passwordTextField setBackgroundColor:[UIColor clearColor]];
        [passwordTextField setFont:[UIFont systemFontOfSize:15.0f]];
        [passwordTextField setPlaceholder:@"请输入密码"];
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        passwordTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        passwordTextField.layer.cornerRadius = 6.0f;
        [self addSubview:passwordTextField];
        
        doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(0.0f, 210.0f, self.bounds.size.width - 24.0f, 35.0f);
        [doneButton setBackgroundColor:[UIColor colorWithHexString:@"7B7777"]];
        [doneButton setTitleColor:[UIColor colorWithHexString:@"DED9D1"]
                         forState:UIControlStateNormal];
        [doneButton setTitle:@"确定" forState:UIControlStateNormal];
        [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [doneButton addTarget:self
                       action:@selector(didDone:)
             forControlEvents:UIControlEventTouchUpInside];
        doneButton.layer.cornerRadius = 6.0f;
        [self addSubview:doneButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resultGetVerifyCode:)
                                                     name:kResultGetVerifyCode
                                                   object:nil];
    }
    return self;
}

- (void)getVerifyCode:(UIButton*)button
{    
    [self.delegate didGetVerifyCodeWithPhoneNum:accountLabel.text];
    [self startTimer];
}

- (void)didDone:(UIButton*)button
{
    if (verifyTextFiled.text == nil || [verifyTextFiled.text isEmptyOrBlank]) {
        [SurfNotification surfNotification:@"请输入验证码"];
        return;
    }
    if (passwordTextField.text == nil || [passwordTextField.text isEmptyOrBlank]) {
        [SurfNotification surfNotification:@"请输入密码"];
        return;
    }
    
    if (passwordTextField.text.length < 6) {
        [SurfNotification surfNotification:@"密码须为6~16位的数字,字母,字符"];
        return;
    }
    
    [self.delegate didChangePwdWithPhoneNum:accountLabel.text
                                     verify:verifyTextFiled.text
                                   password:passwordTextField.text];
}

- (void)startTimer
{
    if(timer == nil){
        timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
        time = Time;
    }
}

- (void)stopTimer
{
    if(timer != nil)
        [timer invalidate];
    timer = nil;
    
    verifyButton.enabled = YES;
    [verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
}

- (void)timerFired:(NSTimer *)_timer
{
    if (time >= 0) {
        verifyButton.enabled = NO;
        [verifyButton setTitle:[NSString stringWithFormat:@"再次发送(%d)", time] forState:UIControlStateNormal];
        time --;
    } else {
        [self stopTimer];
    }
}

#pragma mark NSNotificationCenter methods
- (void)resultGetVerifyCode:(NSNotification*)notification
{
    NSString *result = [notification object];
    if ([result isEqualToString:@"SUCCESS"]) {
        [self startTimer];
    } else if ([result isEqualToString:@"FAIL"]) {
        [self stopTimer];
    }
}


#pragma mark UITextFiledDelegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == passwordTextField){
        if (range.location >= 16) {
            return NO;
        }
    }
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kResultGetVerifyCode
                                                  object:nil];
}

@end

@implementation SurfSettingChangePwdController

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = ViewTitleStateNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIImageView *titleImageView = [[UIImageView alloc] initWithFrame:CGRectMake(4.0f, 20.0f, 178.0f, 30.0f)];
    titleImageView.image = [UIImage imageNamed:@"change_pwd"];
    [self.view addSubview:titleImageView];
    
    ChangePwdView *view = [[ChangePwdView alloc] initWithFrame:CGRectMake(12.0f, 60.0f, 186.0f, 255.0f)];
    view.delegate = self;
    [self.view addSubview:view];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(11.0f, 713.0f, 164.0f, 25.0f)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"setting_back"]
                          forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(didBack)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
}

- (void)didBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ChangePwdViewDelegate methods
- (void)didGetVerifyCodeWithPhoneNum:(NSString *)number
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager getVerifyCode:number capType:@"2" withCompletionHandler:^(BOOL succeeded, NSInteger code) {
        if (succeeded) {
            [SurfNotification surfNotification:[dict valueForKey:[NSString stringWithFormat:@"%@", @(code)]]];
        } else {
            [SurfNotification surfNotification:@"获取验证码失败,请重试"];
        }
    }];
}

- (void)didChangePwdWithPhoneNum:(NSString *)number verify:(NSString *)code password:(NSString *)pwd
{
    SurfNotification *notification = [SurfNotification surfNotificatioIndicatorAutoHide:NO];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager resetPassword:number password:pwd verify:code withCompletionHandler:^(BOOL succeeded, NSInteger code) {
        if (succeeded) {
            if (code == 200) {
                [notification hideNotificatioIndicator:^(BOOL finished) {
                    [self.navigationController popViewControllerAnimated:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
