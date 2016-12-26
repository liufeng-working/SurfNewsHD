//
//  SetPasswordView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SetPasswordView.h"

#define Time 60

@implementation SetPasswordView

@synthesize delegate;
@synthesize phoneTextField;
@synthesize verifyTextFiled;
@synthesize passwordTextField;
@synthesize passwordType;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        backgroundView = [[PublicPopupView alloc] initWithFrame:self.bounds];
        [self addSubview:backgroundView];
        
        UIImageView *phoneBg = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, 90.0f, 270.0f, 40.0f)];
        phoneBg.image = [UIImage imageNamed:@"input_view"];
        [self addSubview:phoneBg];
        
        phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0f, 95.0f, 160.0f, 30.0f)];
        phoneTextField.delegate = self;
        phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [phoneTextField setTextColor:[UIColor colorWithHexString:@"8B8782"]];
        [phoneTextField setBackgroundColor:[UIColor clearColor]];
        [phoneTextField setFont:[UIFont systemFontOfSize:15.0f]];
        [phoneTextField setPlaceholder:@"请输入手机号"];
        phoneTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:phoneTextField];
        
        verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        verifyButton.frame = CGRectMake(218.0f, 95.0f, 87.0f, 30.0f);
        [verifyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
        [verifyButton setBackgroundImage:[UIImage imageNamed:@"get_verifycode_btn"]
                                forState:UIControlStateNormal];
        [verifyButton setTitleColor:[UIColor colorWithHexString:@"8B8782"]
                         forState:UIControlStateNormal];
        [verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [verifyButton addTarget:self
                         action:@selector(getVerifyCode:)
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:verifyButton];
        
        UIImageView *verifyBg = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, 145.0f, 270.0f, 40.0f)];
        verifyBg.image = [UIImage imageNamed:@"input_view"];
        [self addSubview:verifyBg];
        
        verifyTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(50.0f, 150.0f, 250.0f, 30.0f)];
        verifyTextFiled.delegate = self;
        verifyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        [verifyTextFiled setTextColor:[UIColor colorWithHexString:@"8B8782"]];
        [verifyTextFiled setBackgroundColor:[UIColor clearColor]];
        [verifyTextFiled setFont:[UIFont systemFontOfSize:15.0f]];
        [verifyTextFiled setPlaceholder:@"请输入验证码"];
        verifyTextFiled.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:verifyTextFiled];
        
        UIImageView *passwordBg = [[UIImageView alloc] initWithFrame:CGRectMake(40.0f, 200.0f, 270.0f, 40.0f)];
        passwordBg.image = [UIImage imageNamed:@"input_view"];
        [self addSubview:passwordBg];
        
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(50.0f, 205.0f, 250.0f, 30.0f)];
        passwordTextField.delegate = self;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [passwordTextField setTextColor:[UIColor colorWithHexString:@"8B8782"]];
        [passwordTextField setBackgroundColor:[UIColor clearColor]];
        [passwordTextField setFont:[UIFont systemFontOfSize:15.0f]];
        [passwordTextField setPlaceholder:@"请输入密码"];
        passwordTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:passwordTextField];
        
        UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancleButton.frame = CGRectMake(40.0f, 255.0f, 125.0f, 43.0f);
        [cancleButton setBackgroundImage:[UIImage imageNamed:@"public_popup_button"]
                                  forState:UIControlStateNormal];
        [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancleButton setTitleColor:[UIColor colorWithHexString:@"6F5639"]
                             forState:UIControlStateNormal];
        [cancleButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [cancleButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancleButton.titleLabel setShadowOffset:CGSizeMake(0.0f, -1.0f)];
        [cancleButton addTarget:self
                         action:@selector(didCancle:)
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancleButton];
        
        doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(185.0f, 255.0f, 125.0f, 43.0f);
        [doneButton setBackgroundImage:[UIImage imageNamed:@"public_popup_button2"]
                               forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
        [doneButton.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [doneButton addTarget:self
                        action:@selector(didDone:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resultGetVerifyCode:)
                                                     name:kResultGetVerifyCode
                                                   object:nil];
    }
    return self;
}

- (void)setPasswordType:(SetPasswordType)_passwordType phone:(NSString*)_number
{
    passwordType = _passwordType;
    
    phoneTextField.text = _number;
    verifyTextFiled.text = nil;
    passwordTextField.text = nil;
    if (_number) {
        phoneTextField.userInteractionEnabled = NO;
    } else {
        phoneTextField.userInteractionEnabled = YES;
    }
    
    if (passwordType == RegisterType) {
        backgroundView.title = @"中国移动手机号快速注册";
        [doneButton setTitle:@"注册" forState:UIControlStateNormal];
    } else if (passwordType == GetPasswordType) {
        backgroundView.title = @"快速找回密码";
        [doneButton setTitle:@"确认" forState:UIControlStateNormal];
    } else if (passwordType == FirstSetPasswordType) {
        backgroundView.title = @"首次登录,请您设置密码";
        [doneButton setTitle:@"确认" forState:UIControlStateNormal];
    }
}

- (void)getVerifyCode:(UIButton*)button
{
    if (phoneTextField.text == nil || [phoneTextField.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"请输入手机号"];
        return;
    }
    if (![phoneTextField.text isChinaMobileNumber]) {
        [PhoneNotification autoHideWithText:@"请输入11位移动手机号"];
        return;
    }
    
    [self startTimer];
    
    [self.delegate didGetVerifyCodeWithPhoneNum:phoneTextField.text];
}

- (void)didCancle:(UIButton*)button
{
    [self.delegate didCancleSetPassword];
}

- (void)didDone:(UIButton*)button
{
    if (phoneTextField.text == nil || [phoneTextField.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"请输入手机号"];
        return;
    }
    if (verifyTextFiled.text == nil || [verifyTextFiled.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"请输入验证码"];
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
    
    [self.delegate didSetPasswordWithPhoneNum:phoneTextField.text
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kResultGetVerifyCode
                                                  object:nil];
}

@end
