//
//  PhoneLoginController.m
//  SurfNewsHD
//
//  Created by SYZ on 13-6-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "PhoneLoginController.h"
#import "NSString+Extensions.h"
#import "NotificationManager.h"
#import "DeviceIdentifier.h"

@implementation PhoneLoginView 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        phoneBg = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 300.0f, 40.0f)];
        phoneBg.layer.cornerRadius = 1.0f;
        [self addSubview:phoneBg];
        
        phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 15.0f, 280.0f, 40.0f)];
        [phoneTextField setBackgroundColor:[UIColor clearColor]];
        [phoneTextField setFont:[UIFont systemFontOfSize:15.0f]];
        [phoneTextField setPlaceholder:@"中国移动手机号"];
        phoneTextField.delegate = self;
        phoneTextField.textColor = [UIColor colorWithHexString:@"999292"];
        phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneTextField.returnKeyType = UIReturnKeyNext;
        phoneTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self addSubview:phoneTextField];
        if ([AppSettings stringForKey:StringLoginedUser] != nil) {
            phoneTextField.text = [AppSettings stringForKey:StringLoginedUser];
        } else if ([AppSettings stringForKey:StringIMSIPhone] != nil) {
            phoneTextField.text = [AppSettings stringForKey:StringIMSIPhone];
        }
        
        passwordBg = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 70.0f, 300.0f, 40.0f)];
        passwordBg.layer.cornerRadius = 1.0f;
        [self addSubview:passwordBg];
        
        passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0f, 70.0f, 280.0f, 40.0f)];
        [passwordTextField setBackgroundColor:[UIColor clearColor]];
        [passwordTextField setFont:[UIFont systemFontOfSize:15.0f]];
        [passwordTextField setPlaceholder:@"密码"];
        passwordTextField.delegate = self;
        passwordTextField.textColor = [UIColor colorWithHexString:@"999292"];
        passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        passwordTextField.returnKeyType = UIReturnKeyDone;
        passwordTextField.contentVerticalAlignment = UIControlContentHorizontalAlignmentCenter;
        passwordTextField.secureTextEntry = YES;
        [self addSubview:passwordTextField];
        
        UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        loginButton.frame = CGRectMake(10.0f, 125.0f, 300.0f, 40.0f);
        [loginButton setBackgroundImage:[UIImage imageNamed:@"login_register_button.png"]
                                       forState:UIControlStateNormal];
        [loginButton setTitle:@"登  录" forState:UIControlStateNormal];
        [loginButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
        [loginButton.titleLabel setFont:[UIFont systemFontOfSize:18.0f]];
        [loginButton addTarget:self
                        action:@selector(didLogin:)
              forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loginButton];
        
        UIButton *forgetPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        forgetPasswordButton.frame = CGRectMake(240.0f, 175.0f, 70.0f, 20.0f);
        [forgetPasswordButton setBackgroundColor:[UIColor clearColor]];
        [forgetPasswordButton setTitleColor:[UIColor colorWithHexString:@"999292"]
                                  forState:UIControlStateNormal];
        [forgetPasswordButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
        [forgetPasswordButton setTitle:@"忘记密码?" forState:UIControlStateNormal];
        [forgetPasswordButton addTarget:self
                                 action:@selector(didForgetPassword:)
                       forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:forgetPasswordButton];
    }
    return self;
}

- (void)applyTheme:(BOOL)isNight
{
    if (isNight) {
        phoneBg.backgroundColor = [UIColor colorWithHexString:@"222223"];
        passwordBg.backgroundColor = [UIColor colorWithHexString:@"222223"];
    } else {
        phoneBg.backgroundColor = [UIColor colorWithHexString:@"F3F1F1"];
        passwordBg.backgroundColor = [UIColor colorWithHexString:@"F3F1F1"];
    }
}

- (void)popupKeyboard
{
    [phoneTextField becomeFirstResponder];
}

- (void)hideKeyboard
{
    [phoneTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
}

- (void)didLogin:(id)sender
{
    if (phoneTextField.text == nil || [phoneTextField.text isEmptyOrBlank]) {
        [PhoneNotification autoHideWithText:@"请输入手机号"];
        return;
    }
    if (![phoneTextField.text isChinaMobileNumber]) {
        [PhoneNotification autoHideWithText:@"请输入11位移动手机号"];
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
    
    [_delegate didLoginAction:phoneTextField.text password:passwordTextField.text];
}

- (void)didForgetPassword:(id)sender
{
    [phoneTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    
    [self.delegate didForgetPasswordAction];
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
    }
    else if (textField == passwordTextField){
        if (range.location >= 16) {
            //限制16个字符
            return NO;
        }
    }
    return YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == phoneTextField) {
        [passwordTextField becomeFirstResponder];
    } else if (textField == passwordTextField) {
        [self didLogin:nil];
    } 
    return YES;
}

@end

@implementation PhoneLoginController
//登陆时的界面，不需要返回按钮
- (BOOL)isSupportTopBar {

    return (char)nil;

}

- (id)init
{
    self = [super init];
    if (self) {
        self.titleState = PhoneSurfControllerStateTop;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    if (!bgView) {
//        bgView=[[UIView alloc] initWithFrame:CGRectMake(0, self.StateBarHeight, self.view.frame.size.width, self.view.frame.size.height)];
//    }
//    if (![self.view.subviews containsObject:bgView]) {
//        [self.view addSubview:bgView];
//    }
    
    
    loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(0.0f, 5.0f, 65.0f, 40.0f);
    loginButton.tag = 50;
    [loginButton.titleLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [loginButton setTitle: @"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(switchLoginOrRegister:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginButton];
    
    registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    registerButton.frame = CGRectMake(65.0f, 5.0f, 65.0f, 40.0f);
    registerButton.tag = 100;
    [registerButton.titleLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
    [registerButton setTitle: @"注册" forState:UIControlStateNormal];
    [registerButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(switchLoginOrRegister:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:registerButton];
    
    if (IOS7) {
        loginButton.frame = CGRectMake(0.0f, 20.0f, 65.0f, 40.0f);
        registerButton.frame = CGRectMake(65.0f, 20.0f, 65.0f, 40.0f);
    }
    
    self.noGestureRecognizerRect = CGRectMake(0.0f, 5.0f, 130.0f, 40.0f);
    
    UIButton *blankButton = [UIButton buttonWithType:UIButtonTypeCustom];
    blankButton.frame = CGRectMake(130.0f, 0.0f, kContentWidth - 130.0f, self.StateBarHeight);
    [blankButton addTarget:self action:@selector(dismissKeyboard:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:blankButton];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, [self StateBarHeight], kContentWidth, kContentHeight - [self StateBarHeight])];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    scrollView.bounces = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.contentSize = CGSizeMake(kContentWidth * 2, scrollView.frame.size.height);
    [self.view addSubview:scrollView];
    
    loginView = [[PhoneLoginView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, 215.0f)];
    loginView.delegate = self;
    
    loginTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, scrollView.frame.size.height)
                                                  style:UITableViewStylePlain];
    loginTableView.bounces = NO;
    [loginTableView setBackgroundColor:[UIColor clearColor]];
    [loginTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [loginTableView setTableHeaderView:loginView];
    [scrollView addSubview:loginTableView];
    
    registerView = [[PhoneSetPasswordView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, kContentWidth, 235.0f)];
    registerView.delegate = self;
    [registerView setPasswordType:RegisterType phone:nil];
    [registerView addPolicy];
    
    registerTableView = [[UITableView alloc] initWithFrame:CGRectMake(kContentWidth, 0.0f, kContentWidth, scrollView.frame.size.height)
                                                     style:UITableViewStylePlain];
    registerTableView.bounces = NO;
    [registerTableView setBackgroundColor:[UIColor clearColor]];
    [registerTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [registerTableView setTableHeaderView:registerView];
    [scrollView addSubview:registerTableView];
    
    if ([DeviceIdentifier carrierIsChinaMobile] &&
        ![AppSettings boolForKey:BOOLKey_ShowQuickRegister]) {
        quickRegisterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        quickRegisterButton.frame = CGRectMake(130.0f, 5.0f, 110.0f, 40.0f);
        if (IOS7) {
            quickRegisterButton.frame = CGRectMake(130.0f, 20.0f, 110.0f, 40.0f);
        }
        quickRegisterButton.tag = 150;
        quickRegisterButton.backgroundColor = [UIColor clearColor];
        [quickRegisterButton.titleLabel setFont:[UIFont boldSystemFontOfSize:22.0f]];
        [quickRegisterButton setTitle: @"一键注册" forState:UIControlStateNormal];
        [quickRegisterButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [quickRegisterButton addTarget:self action:@selector(switchLoginOrRegister:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:quickRegisterButton];
        
        PhoneQuickRegisterView *quickRegisterView = [[PhoneQuickRegisterView alloc] initWithFrame:CGRectMake(kContentWidth * 2, 0.0f, kContentWidth, scrollView.frame.size.height)];
        quickRegisterView.backgroundColor = [UIColor clearColor];
        quickRegisterView.delegate = self;
        [scrollView addSubview:quickRegisterView];
        
        blankButton.frame = CGRectMake(240.0f, 0.0f, kContentWidth - 240.0f, self.StateBarHeight);
        scrollView.contentSize = CGSizeMake(kContentWidth * 3, scrollView.frame.size.height);
    }
    [self addBottomToolsBar];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    singleFingerTap.cancelsTouchesInView = NO;
    [scrollView addGestureRecognizer:singleFingerTap];
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
    
    NSInteger page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    if (page == 0) {
        [loginView performSelector:@selector(popupKeyboard) withObject:nil afterDelay:0.4f];
    } else if (page == 1) {
        [registerView performSelector:@selector(popupKeyboard) withObject:nil afterDelay:0.4f];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{   
    NSInteger page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    
    if (page == 0) {
        [loginView hideKeyboard];
    } else if (page == 1) {
        [registerView hideKeyboard];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [PhoneNotification hideNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self dismissKeyboard:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)nightModeChanged:(BOOL)night
{
    [super nightModeChanged:night];
    
    [loginView applyTheme:night];
    [registerView applyTheme:night];
}

#pragma mark PhoneLoginViewDelegate methods
- (void)didLoginAction:(NSString *)phone password:(NSString *)pwd
{
    [PhoneNotification manuallyHideWithText:@"正在登录,请稍候..." indicator:YES];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager userLogin:phone password:pwd withCompletionHandler:^(BOOL succeeded, NSInteger code) {
        if (succeeded) {
            if (code == 200) {
                //登录成功后,发送设备信息到web端
                [[NotificationManager sharedInstance] sendNotifiWithDeviceInfo];
                
                [PhoneNotification manuallyHideWithIndicator];
                [[UserManager sharedInstance] findUserInfowithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData) {
                    if (succeeded) {
                        [[UserManager sharedInstance] findTasksWithCompletionHandler:^(BOOL succeeded, NSDictionary *dicData) {
                            if (succeeded) {
                                [PhoneNotification autoHideWithText:@"您已成功登录,冲浪有您更精彩!"];
                            }
                            else{
                                
                            }
                            [self dismissControllerAnimated:PresentAnimatedStateFromRight];
                        }];
                    }
                    else{
                        [self dismissControllerAnimated:PresentAnimatedStateFromRight];
                    }
                }];
              
            } else {
                [PhoneNotification autoHideWithText:[dict valueForKey:[NSString stringWithFormat:@"%@", @(code)]]];
                if (code == 608){
                    PhoneSetPasswordController *controller = [[PhoneSetPasswordController alloc] init];
                    controller.setPasswordType = FirstSetPasswordType;
                    controller.phoneNumber = phone;
                    [self presentController:controller animated:PresentAnimatedStateFromRight];
                }
            }
        } else {
            [PhoneNotification autoHideWithText:@"登录失败,请重试"];
        }
    }];
}

- (void)didForgetPasswordAction
{
    PhoneSetPasswordController *controller = [[PhoneSetPasswordController alloc] init];
    controller.setPasswordType = GetPasswordType;
    [self presentController:controller
                   animated:PresentAnimatedStateFromRight];
}

#pragma mark PhoneSetPasswordViewDelegate methods
//注册的capType为1
- (void)didGetVerifyCodeWithPhoneNum:(NSString *)number
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager getVerifyCode:number capType:@"1" withCompletionHandler:^(BOOL succeeded, NSInteger code) {
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
    [PhoneNotification manuallyHideWithText:@"正在注册,请稍候..." indicator:YES];
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"RequestCode" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    UserManager *manager = [UserManager sharedInstance];
    [manager userRegister:number password:pwd verify:code withCompletionHandler:^(BOOL succeeded, NSInteger code) {
        if (succeeded) {
            if (code == 200) {
                [PhoneNotification autoHideWithText:@"您已成功注册,开始一段神奇的冲浪体验!"];
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
        PhoneWeiboPolicyController *weiboPolicyViewCrl = [[PhoneWeiboPolicyController alloc] init];
        [weiboPolicyViewCrl setURL:@"http://go.10086.cn/guide/agreement.html"];
        [self presentController:weiboPolicyViewCrl animated:PresentAnimatedStateFromRight];
}

- (void)didPrivacyPolicy{
        PhoneWeiboPolicyController *weiboPolicyViewCrl = [[PhoneWeiboPolicyController alloc] init];
        [weiboPolicyViewCrl setURL:@"http://go.10086.cn/guide/privacy.html"];
        [self presentController:weiboPolicyViewCrl animated:PresentAnimatedStateFromRight];
}

#pragma mark PhoneQuickRegisterViewDelegate methods
- (void)didQuickRegisetr
{
    if (![self enableToSendSMS]) {
        [PhoneNotification autoHideWithText:@"每天只能发送3次信息,请选择手动注册方式"];
        return;
    }
    if ([MFMessageComposeViewController canSendText]) {
        NSString *did = [DeviceIdentifier getDeviceId];
        identifier = [NSString stringWithFormat:@"%@%d", did, arc4random() % 8999 + 1000];
        NSArray *recipients = [NSArray arrayWithObject:@"10658433"];
        NSString *SMSText = [NSString stringWithFormat:@"9266%@0a60", identifier];
        theApp.nightModeShadow.hidden = YES;
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.body = SMSText;
        messageController.recipients = recipients;
        messageController.messageComposeDelegate = self;
        [self presentViewController:messageController
                           animated:YES
                         completion:nil];
    }
}

- (void)didWeiboPolicyQuickRegister{
    PhoneWeiboPolicyController *weiboPolicyViewCrl = [[PhoneWeiboPolicyController alloc] init];
    [weiboPolicyViewCrl setURL:@"http://go.10086.cn/guide/agreement.html"];
    [self presentController:weiboPolicyViewCrl animated:PresentAnimatedStateFromRight];
}

- (void)didPrivacyPolicyQuickRegister{
    PhoneWeiboPolicyController *weiboPolicyViewCrl = [[PhoneWeiboPolicyController alloc] init];
    [weiboPolicyViewCrl setURL:@"http://go.10086.cn/guide/privacy.html"];
    [self presentController:weiboPolicyViewCrl animated:PresentAnimatedStateFromRight];
}

#pragma mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    if (result == MessageComposeResultSent) {
        [self sendSMSSuccessAndRegister];
    }
    else if (result == MessageComposeResultFailed) {
        [PhoneNotification autoHideWithText:@"短信发送失败"];
    }
    theApp.nightModeShadow.hidden = ![[ThemeMgr sharedInstance] isNightmode];
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIScrollViewDelegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)_scrollView
{
    int page = floor((scrollView.contentOffset.x - scrollView.frame.size.width / 2) / scrollView.frame.size.width) + 1;
    
    if (page == 0) {
        [loginView popupKeyboard];
        [loginButton setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [quickRegisterButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
    } else if (page == 1) {
        [registerView popupKeyboard];
        [loginButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
        [quickRegisterButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
    } else if (page == 2) {
        [registerView hideKeyboard];
        [loginButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [quickRegisterButton setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
    }
}

- (void)switchLoginOrRegister:(UIButton*)button
{
    if (button.tag == 50) {
        [loginView popupKeyboard];
        [scrollView setContentOffset:CGPointZero animated:YES];
        [loginButton setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [quickRegisterButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
    } else if (button.tag == 100) {
        [registerView popupKeyboard];
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width, 0.0f) animated:YES];
        [loginButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
        [quickRegisterButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
    } else if (button.tag == 150) {
        [loginView hideKeyboard];
        [registerView hideKeyboard];
        [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * 2, 0.0f) animated:YES];
        [loginButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [registerButton setTitleColor:[UIColor colorWithHexString:@"999292"] forState:UIControlStateNormal];
        [quickRegisterButton setTitleColor:[UIColor colorWithHexString:@"AD2F2F"] forState:UIControlStateNormal];
    }
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

                             CGRect loginTableViewFrame = loginTableView.frame;
                             loginTableViewFrame.size.height -= 216.0f;
                             loginTableView.frame = loginTableViewFrame;
                             
                             CGRect registerTableViewFrame = registerTableView.frame;
                             registerTableViewFrame.size.height -= 216.0f;
                             registerTableView.frame = registerTableViewFrame;
                             
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
                             CGRect loginTableViewFrame = loginTableView.frame;
                             loginTableViewFrame.size.height += 216.0f;
                             loginTableView.frame = loginTableViewFrame;
                             
                             CGRect registerTableViewFrame = registerTableView.frame;
                             registerTableViewFrame.size.height += 216.0f;
                             registerTableView.frame = registerTableViewFrame;
                             
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
    [loginView hideKeyboard];
    [registerView hideKeyboard];
}

- (void)sendSMSSuccessAndRegister
{
    [self addSMSSendCount];
    
    [PhoneNotification manuallyHideWithText:@"注册中..." indicator:YES];
    [PhoneNotification setHUDUserInteractionEnabled:NO];
    
    id req = [SurfRequestGenerator quickRegisterRequestWithIdentifier:identifier];
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:req];
    [fetcher beginFetchWithCompletionHandler:^(NSData *data,NSError *error)
     {
         [[NSURLCache sharedURLCache] removeAllCachedResponses];
         [[NSURLCache sharedURLCache] setDiskCapacity:0];
         [[NSURLCache sharedURLCache] setMemoryCapacity:0];
         if(!error) {
             NSString *body = [[NSString alloc] initWithData:data encoding:[[[fetcher response] textEncodingName] convertToStringEncoding]];
             LongPullServletResponse *resp = [EzJsonParser deserializeFromJson:body AsType:[LongPullServletResponse class]];
             if ([resp.code isEqualToString:@"1"]) {
                 [[UserManager sharedInstance] getSubsAfterLogin:resp phone:nil withCompletionHandler:^(BOOL succeeded) {
                     if (succeeded) {
                         [AppSettings setBool:YES forKey:BOOLKey_ShowQuickRegister];
                         [PhoneNotification autoHideWithText:@"登录成功"];
                         [self dismissControllerAnimated:PresentAnimatedStateFromRight];
                     } else {
                         [PhoneNotification autoHideWithText:@"注册失败"];
                     }
                 }];
             } else {
                 [PhoneNotification autoHideWithText:@"注册失败"];
             }
         } else {
             [PhoneNotification autoHideWithText:@"注册失败"];
         }
     }];
}

//每天只有3次机会
- (BOOL)enableToSendSMS
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSString *oldString = [AppSettings stringForKey:StringSMSSendCountIPhone];
    if (oldString) {
        NSArray *array = [oldString componentsSeparatedByString:@"-"];
        if ([array[0] intValue] < [dateString intValue]) {
            [AppSettings setString:[dateString stringByAppendingString:@"-0"] forKey:StringSMSSendCountIPhone];
            return YES;
        } else if ([array[1] intValue] < 3) {
            return YES;
        } else {
            return NO;
        }
    } else {
        [AppSettings setString:[dateString stringByAppendingString:@"-0"] forKey:StringSMSSendCountIPhone];
        return YES;
    }
    return NO;
}

- (void)addSMSSendCount
{
    NSString *string = [AppSettings stringForKey:StringSMSSendCountIPhone];
    NSArray *array = [string componentsSeparatedByString:@"-"];
    int count = [array[1] intValue] + 1;
    NSString *newString = [NSString stringWithFormat:@"%@-%d", array[0], count];
    [AppSettings setString:newString forKey:StringSMSSendCountIPhone];
}

@end
