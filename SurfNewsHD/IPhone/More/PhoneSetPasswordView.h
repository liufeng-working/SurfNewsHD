//
//  PhoneSetPasswordView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-6-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSString+Extensions.h"

typedef enum {
    RegisterType,               // 注册
    GetPasswordType,            // 取回密码
    FirstSetPasswordType        // 第一次设置密码
} SetPasswordType;

@protocol PhoneSetPasswordViewDelegate <NSObject>

- (void)didGetVerifyCodeWithPhoneNum:(NSString*)number;
- (void)didSetPasswordWithPhoneNum:(NSString*)number
                            verify:(NSString*)code
                          password:(NSString*)pwd;
- (void)didWeiboPolicy;
- (void)didPrivacyPolicy;
@end

@interface PhoneSetPasswordView : UIView <UITextFieldDelegate>
{
    NSTimer *timer;
    int time;
    
    UIButton *verifyButton;
    UIButton *doneButton;
    
    UIButton *weiboPolicy;
    UIButton *privacyPolicy;
    
    UIView *phoneBg;
    UITextField *phoneTextField;
    UIView *verifyBg;
    UITextField *verifyTextFiled;
    UIView *passwordBg;
    UITextField *passwordTextField;
    UIActivityIndicatorView *indicatorView;
}

@property(nonatomic, weak) id<PhoneSetPasswordViewDelegate> delegate;
@property(nonatomic) SetPasswordType passwordType;
@property(nonatomic, strong) NSString *phoneNumber;

- (void)setPasswordType:(SetPasswordType)_passwordType phone:(NSString*)_number;
- (void)applyTheme:(BOOL)isNight;
- (void)popupKeyboard;
- (void)hideKeyboard;
- (void)addPolicy;

@end

@protocol PhoneQuickRegisterViewDelegate <NSObject>

- (void)didQuickRegisetr;
- (void)didWeiboPolicyQuickRegister;
- (void)didPrivacyPolicyQuickRegister;

@end

@interface PhoneQuickRegisterView : UIView{
    UIButton *weiboPolicyQuickRegister;
    UIButton *privacyPolicyQuickRegister;
}

@property(nonatomic, weak) id<PhoneQuickRegisterViewDelegate> delegate;

@end
