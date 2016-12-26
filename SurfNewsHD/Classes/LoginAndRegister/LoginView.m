//
//  LoginView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "LoginView.h"
#import "NSString+Extensions.h"

@implementation LoginView

@synthesize phoneTextField;
@synthesize passwordTextField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundView = [[PublicPopupView alloc] initWithFrame:self.bounds];
        backgroundView.title = @"登录";
        [self addSubview:backgroundView];
        
        UIImageView *phoneBg = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, 90.0f, 270.0f, 40.0f)];
        phoneBg.image = [UIImage imageNamed:@"input_view"];
        [self addSubview:phoneBg];
        
        phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0f, 95.0f, 250.0f, 30.0f)];
        [phoneTextField setTextColor:[UIColor colorWithHexString:@"8B8782"]];
        [phoneTextField setBackgroundColor:[UIColor clearColor]];
        [phoneTextField setFont:[UIFont systemFontOfSize:15.0f]];
        [phoneTextField setPlaceholder:@"请输入中国移动手机号"];
        phoneTextField.delegate = self;
        phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:phoneTextField];
        
        UIImageView *passwordBg = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, 145.0f, 270.0f, 40.0f)];
        passwordBg.image = [UIImage imageNamed:@"input_view"];
        [self addSubview:passwordBg];
        
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0f, 150.0f, 250.0f, 30.0f)];
        [passwordTextField setTextColor:[UIColor colorWithHexString:@"8B8782"]];
        [passwordTextField setBackgroundColor:[UIColor clearColor]];
        [passwordTextField setFont:[UIFont systemFontOfSize:15.0f]];
        [passwordTextField setPlaceholder:@"请输入密码"];
        passwordTextField.delegate = self;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        passwordTextField.secureTextEntry = YES;
        passwordTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:passwordTextField];
        
        UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        registerButton.frame = CGRectMake(40.0f, 200.0f, 125.0f, 43.0f);
        [registerButton setBackgroundImage:[UIImage imageNamed:@"public_popup_button"]
                               forState:UIControlStateNormal];
        [registerButton setTitle:@"注册" forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor colorWithHexString:@"6F5639"]
                          forState:UIControlStateNormal];
        [registerButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [registerButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [registerButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        [registerButton addTarget:self
                           action:@selector(didRegister:)
                 forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:registerButton];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.frame = CGRectMake(185.0f, 200.0f, 125.0f, 43.0f);
        [loginButton setBackgroundImage:[UIImage imageNamed:@"public_popup_button2"]
                               forState:UIControlStateNormal];
        [loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
        [loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [loginButton addTarget:self
                        action:@selector(didLogin:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loginButton];
        
        UIButton *resetPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        resetPasswordButton.frame = CGRectMake(220.0f, 258.0f, 90.0f, 20.0f);
        [resetPasswordButton setBackgroundColor:[UIColor clearColor]];
        [resetPasswordButton setTitleColor:[UIColor colorWithHexString:@"9D9696"]
                                  forState:UIControlStateNormal];
        [resetPasswordButton.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0f]];
        [resetPasswordButton setTitle:@"快速找回密码 >>" forState:UIControlStateNormal];
        [resetPasswordButton addTarget:self
                                action:@selector(didResetPassword:)
                      forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:resetPasswordButton];
        
        whyLogin = [[UIImageView alloc] initWithFrame:CGRectMake(44.0f, 300.0f, 272.0f, 75.0f)];
        whyLogin.image = [UIImage imageNamed:@"popup_why_login"];
        [self addSubview:whyLogin];
    }
    return self;
}

- (void)didRegister:(UIButton*)button
{
    [phoneTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [self.delegate didRegisterAction];
}

- (void)didLogin:(UIButton*)button
{
    if (phoneTextField.text == nil || [phoneTextField.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"请输入手机号"];
        return;
    }
    if (passwordTextField.text == nil || [passwordTextField.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"请输入密码"];
        return;
    }
    if (passwordTextField.text.length < 6) {
        [PhoneNotification autoHideWithText:@"密码须为6~16位的数字,字母,字符"];
        return;
    }
    
    [phoneTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    [self.delegate didLoginAction:phoneTextField.text password:passwordTextField.text];
}

- (void)didResetPassword:(UIButton*)button
{
    [phoneTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    [self.delegate didResetPasswordAction];
}

- (void)clearTextFiled
{
    phoneTextField.text = nil;
    passwordTextField.text = nil;
    [phoneTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

- (void)hiddenView
{
    backgroundView.hidden = YES;
    whyLogin.hidden = YES;
}

#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField != phoneTextField) {
        if (phoneTextField.text == nil || [phoneTextField.text isEmptyOrBlank]) {
            [PhoneNotification autoHideWithText:@"请输入手机号"];
        } else if (![phoneTextField.text isChinaMobileNumber]) {
            [PhoneNotification autoHideWithText:@"请输入11位移动手机号"];
        }
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == phoneTextField){
        if (range.location >= 11) {
            return NO;
        }
    }else if (textField == passwordTextField){
        if (range.location >= 16) {
            return NO;
        }
    }
    return YES;
}

@end
