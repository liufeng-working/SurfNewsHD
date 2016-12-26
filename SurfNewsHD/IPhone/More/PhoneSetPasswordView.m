//
//  PhoneSetPasswordView.m
//  SurfNewsHD
//
//  Created by SYZ on 13-6-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneSetPasswordView.h"
#import "AppSettings.h"

#define Time      60
#define Space     5.f  //间距
#define PolicyW   63.f //协议按钮的宽
#define PrivacyW  42.f //条款按钮的宽

@implementation PhoneSetPasswordView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        phoneBg = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 300.0f, 40.0f)];
        phoneBg.layer.cornerRadius = 1.0f;
        [self addSubview:phoneBg];
        
        phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 15.0f, 280.0f, 40.0f)];
        phoneTextField.delegate = self;
        phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [phoneTextField setTextColor:[UIColor colorWithHexString:@"999292"]];
        [phoneTextField setBackgroundColor:[UIColor clearColor]];
        [phoneTextField setFont:[UIFont systemFontOfSize:15.0f]];
        [phoneTextField setPlaceholder:@"请输入中国移动手机号"];
        [phoneTextField setReturnKeyType:UIReturnKeyNext];
        [phoneTextField setKeyboardType:UIKeyboardTypeNumberPad];
        phoneTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:phoneTextField];
        if ([AppSettings stringForKey:StringLoginedUser] == nil &&
            [AppSettings stringForKey:StringIMSIPhone] != nil) {
            phoneTextField.text = [AppSettings stringForKey:StringIMSIPhone];
        }
        
        verifyBg = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 70.0f, 198.0f, 40.0f)];
        verifyBg.layer.cornerRadius = 1.0f;
        [self addSubview:verifyBg];
        
        verifyTextFiled = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 70.0f, 188.0f, 40.0f)];
        verifyTextFiled.delegate = self;
        verifyTextFiled.clearButtonMode = UITextFieldViewModeWhileEditing;
        [verifyTextFiled setTextColor:[UIColor colorWithHexString:@"999292"]];
        [verifyTextFiled setBackgroundColor:[UIColor clearColor]];
        [verifyTextFiled setFont:[UIFont systemFontOfSize:15.0f]];
        [verifyTextFiled setPlaceholder:@"请输入验证码"];
        [verifyTextFiled setReturnKeyType:UIReturnKeyNext];
        [verifyTextFiled setKeyboardType:UIKeyboardTypeNumberPad];
        verifyTextFiled.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:verifyTextFiled];
        
        verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        verifyButton.frame = CGRectMake(218.0f, 70.0f, 92.0f, 40.0f);
        [verifyButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [verifyButton setBackgroundImage:[UIImage imageNamed:@"get_verify_button.png"]
                                forState:UIControlStateNormal];
        [verifyButton setTitleColor:[UIColor colorWithHexString:@"999292"]
                           forState:UIControlStateNormal];
        [verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
        [verifyButton addTarget:self
                         action:@selector(getVerifyCode:)
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:verifyButton];
        
        passwordBg = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 125.0f, 300.0f, 40.0f)];
        passwordBg.layer.cornerRadius = 1.0f;
        [self addSubview:passwordBg];
        
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 125.0f, 280.0f, 40.0f)];
        passwordTextField.delegate = self;
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [passwordTextField setTextColor:[UIColor colorWithHexString:@"999292"]];
        [passwordTextField setBackgroundColor:[UIColor clearColor]];
        [passwordTextField setFont:[UIFont systemFontOfSize:15.0f]];
        [passwordTextField setReturnKeyType:UIReturnKeyDone];
        passwordTextField.secureTextEntry = YES;
        passwordTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:passwordTextField];
        
        doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = CGRectMake(10.0f, 180.0f, 300.0f, 40.0f);
        [doneButton setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"]
                              forState:UIControlStateNormal];
        [doneButton setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
        [doneButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [doneButton addTarget:self
                       action:@selector(didDone:)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:doneButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resultGetVerifyCode:)
                                                     name:kResultGetVerifyCode
                                                   object:nil];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
        [indicatorView setCenter:verifyButton.center];
        [self addSubview:indicatorView];
    }
    return self;
}

- (void)addPolicy{
    UILabel *txt = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 216.0f, 77.f, 30.0f)];
    [txt setText:@"注册代表你同意"];
    [txt setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
    [txt setFont:[UIFont systemFontOfSize:11.0f]];
    [txt setBackgroundColor:[UIColor clearColor]];
    [txt setTextColor:[UIColor colorWithHexString:@"999292"]];
    [txt setUserInteractionEnabled:YES];
    [txt setNumberOfLines:0];
    [self addSubview:txt];
    
    CGFloat wX = CGRectGetMaxX(txt.frame) + Space;
    weiboPolicy = [UIButton buttonWithType:UIButtonTypeCustom];
    weiboPolicy.frame = CGRectMake(wX, 216.5f, PolicyW, 30.0f);
    [weiboPolicy setTitle:@"网络使用协议" forState:UIControlStateNormal];
    [weiboPolicy.titleLabel setFont:[UIFont systemFontOfSize:10.5f]];
    [weiboPolicy setTitleColor:[UIColor colorWithHexString:@"1E90FF"]
                      forState:UIControlStateNormal];
    [weiboPolicy addTarget:self
                    action:@selector(getWeiboPolicy:)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:weiboPolicy];
    
    CGFloat hX = CGRectGetMaxX(weiboPolicy.frame) + Space;
    UILabel * he = [[UILabel alloc] initWithFrame:CGRectMake(hX, 216.0f, 11.f, 30.0f)];
    [he setText:@"和"];
    [he setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
    [he setFont:[UIFont systemFontOfSize:11.0f]];
    [he setBackgroundColor:[UIColor clearColor]];
    [he setTextColor:[UIColor colorWithHexString:@"999292"]];
    [he setUserInteractionEnabled:YES];
    [he setNumberOfLines:0];
    [self addSubview:he];

    CGFloat pX = CGRectGetMaxX(he.frame) + Space;
    privacyPolicy = [UIButton buttonWithType:UIButtonTypeCustom];
    privacyPolicy.frame = CGRectMake(pX, 216.5f, PrivacyW, 30.0f);
    [privacyPolicy setTitle:@"隐私条款" forState:UIControlStateNormal];
    [privacyPolicy.titleLabel setFont:[UIFont systemFontOfSize:10.5f]];
    [privacyPolicy setTitleColor:[UIColor colorWithHexString:@"1E90FF"]
                        forState:UIControlStateNormal];
    [privacyPolicy addTarget:self
                      action:@selector(getPrivacyPolicy:)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:privacyPolicy];
}

- (void)setPasswordType:(SetPasswordType)passwordType phone:(NSString*)number
{
    _passwordType = passwordType;
    _phoneNumber = number;
    
    phoneTextField.text = _phoneNumber;
    verifyTextFiled.text = nil;
    passwordTextField.text = nil;
    if (number) {
        phoneTextField.userInteractionEnabled = NO;
    } else {
        phoneTextField.userInteractionEnabled = YES;
    }
    
    if (_passwordType == RegisterType) {
        [doneButton setTitle:@"注  册" forState:UIControlStateNormal];
        [passwordTextField setPlaceholder:@"请输入密码"];
    } else if (_passwordType == GetPasswordType) {
        [doneButton setTitle:@"确  认" forState:UIControlStateNormal];
        [passwordTextField setPlaceholder:@"请设置新密码"];
    } else if (_passwordType == FirstSetPasswordType) {
        [doneButton setTitle:@"确  认" forState:UIControlStateNormal];
        [passwordTextField setPlaceholder:@"请输入密码"];
    }
}

- (void)applyTheme:(BOOL)isNight
{
    if (isNight) {
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        phoneBg.backgroundColor = [UIColor colorWithHexString:@"222223"];
        verifyBg.backgroundColor = [UIColor colorWithHexString:@"222223"];
        passwordBg.backgroundColor = [UIColor colorWithHexString:@"222223"];
        [verifyButton setBackgroundImage:[UIImage imageNamed:@"get_verify_button_night.png"]
                                forState:UIControlStateNormal];
        [verifyButton setTitleColor:[UIColor whiteColor]
                           forState:UIControlStateNormal];
    } else {
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        phoneBg.backgroundColor = [UIColor colorWithHexString:@"F3F1F1"];
        verifyBg.backgroundColor = [UIColor colorWithHexString:@"F3F1F1"];
        passwordBg.backgroundColor = [UIColor colorWithHexString:@"F3F1F1"];
        [verifyButton setBackgroundImage:[UIImage imageNamed:@"get_verify_button.png"]
                                forState:UIControlStateNormal];
        [verifyButton setTitleColor:[UIColor colorWithHexString:@"999292"]
                           forState:UIControlStateNormal];
    }
}

- (void)popupKeyboard
{
    if (_phoneNumber) {
        [verifyTextFiled becomeFirstResponder];
    } else {
        [phoneTextField becomeFirstResponder];
    }
}

- (void)hideKeyboard
{
    [phoneTextField resignFirstResponder];
    [verifyTextFiled resignFirstResponder];
    [passwordTextField resignFirstResponder];
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
    
    verifyButton.enabled = NO;
    [verifyButton setTitle:@"" forState:UIControlStateNormal];
    [indicatorView startAnimating];
    
    [self.delegate didGetVerifyCodeWithPhoneNum:phoneTextField.text];
}

- (void)didDone:(UIButton*)button
{
    if (phoneTextField.text == nil || [phoneTextField.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"请输入手机号"];
        return;
    }
    if (![phoneTextField.text isChinaMobileNumber]) {
        [PhoneNotification autoHideWithText:@"请输入11位移动手机号"];
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
    
    [_delegate didSetPasswordWithPhoneNum:phoneTextField.text
                                   verify:verifyTextFiled.text
                                 password:passwordTextField.text];
}

-(void)getWeiboPolicy:(UIButton*)button{
    [_delegate didWeiboPolicy];
}


-(void)getPrivacyPolicy:(UIButton*)button{
    [_delegate didPrivacyPolicy];
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
    
    [indicatorView stopAnimating];
    verifyButton.enabled = YES;
    [verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
}

- (void)timerFired:(NSTimer *)_timer
{
    if (time >= 0) {
        [indicatorView stopAnimating];
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
    
    if(textField == passwordTextField){
        textField.text = @"";
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == phoneTextField) {
        [verifyTextFiled becomeFirstResponder];
    } else if (textField == verifyTextFiled) {
        [passwordTextField becomeFirstResponder];
    } else if (textField == passwordTextField) {
        [self didDone:nil];
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

@implementation PhoneQuickRegisterView

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 40.0f, frame.size.width - 20.0f, 40.0f)];
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.textColor = [[ThemeMgr sharedInstance] isNightmode] ? [UIColor whiteColor] : [UIColor colorWithHexString:@"999292"];
        messageLabel.font = [UIFont systemFontOfSize:14.0f];
        messageLabel.numberOfLines = 2;
        messageLabel.text = @"发送免费短信就能一键注册冲浪快讯，本短信不收取任何费用。";
		[self addSubview:messageLabel];
        
        UIButton *registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        registerButton.frame = CGRectMake(10.0f, 120.0f, 300.0f, 40.0f);
        [registerButton setTitle:@"发送免费短信注册" forState:UIControlStateNormal];
        [registerButton setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"]
                              forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor whiteColor]
                         forState:UIControlStateNormal];
        [registerButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [registerButton addTarget:self
                       action:@selector(quickRegister:)
             forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:registerButton];
        
        //添加隐私政策
        [self addPolicyQuickRegister];
    }
    return self;
}


- (void)quickRegister:(id)button
{
    [_delegate didQuickRegisetr];
}

- (void)addPolicyQuickRegister{
    UILabel *txt = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 160.0f, 77.f, 30.0f)];
    [txt setText:@"注册代表你同意"];
    [txt setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
    [txt setFont:[UIFont systemFontOfSize:11.0f]];
    [txt setBackgroundColor:[UIColor clearColor]];
    [txt setTextColor:[UIColor colorWithHexString:@"999292"]];
    [txt setUserInteractionEnabled:YES];
    [txt setNumberOfLines:0];
    [self addSubview:txt];
    
    CGFloat wX = CGRectGetMaxX(txt.frame) + Space;
    weiboPolicyQuickRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    weiboPolicyQuickRegister.frame = CGRectMake(wX, 160.5f, PolicyW, 30.0f);
    [weiboPolicyQuickRegister setTitle:@"网络使用协议" forState:UIControlStateNormal];
    [weiboPolicyQuickRegister.titleLabel setFont:[UIFont systemFontOfSize:10.5f]];
    [weiboPolicyQuickRegister setTitleColor:[UIColor colorWithHexString:@"1E90FF"]
                      forState:UIControlStateNormal];
    [weiboPolicyQuickRegister addTarget:self
                    action:@selector(getWeiboPolicyQuickRegister:)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:weiboPolicyQuickRegister];
    
    CGFloat hX = CGRectGetMaxX(weiboPolicyQuickRegister.frame) + Space;
    UILabel * he = [[UILabel alloc] initWithFrame:CGRectMake(hX, 160.f, 11.f, 30.0f)];
    [he setText:@"和"];
    [he setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
    [he setFont:[UIFont systemFontOfSize:11.0f]];
    [he setBackgroundColor:[UIColor clearColor]];
    [he setTextColor:[UIColor colorWithHexString:@"999292"]];
    [he setUserInteractionEnabled:YES];
    [he setNumberOfLines:0];
    [self addSubview:he];
    
    CGFloat pX = CGRectGetMaxX(he.frame) + Space;
    privacyPolicyQuickRegister = [UIButton buttonWithType:UIButtonTypeCustom];
    privacyPolicyQuickRegister.frame = CGRectMake(pX, 160.5f, PrivacyW, 30.0f);
    [privacyPolicyQuickRegister setTitle:@"隐私条款" forState:UIControlStateNormal];
    [privacyPolicyQuickRegister.titleLabel setFont:[UIFont systemFontOfSize:10.5f]];
    [privacyPolicyQuickRegister setTitleColor:[UIColor colorWithHexString:@"1E90FF"]
                        forState:UIControlStateNormal];
    [privacyPolicyQuickRegister addTarget:self
                      action:@selector(getPrivacyPolicyQuickRegister:)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:privacyPolicyQuickRegister];
}

-(void)getWeiboPolicyQuickRegister:(UIButton*)button{
    [_delegate didWeiboPolicyQuickRegister];
}


-(void)getPrivacyPolicyQuickRegister:(UIButton*)button{
    [_delegate didPrivacyPolicyQuickRegister];
}


@end
