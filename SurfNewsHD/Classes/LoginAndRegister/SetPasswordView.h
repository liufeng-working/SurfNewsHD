//
//  SetPasswordView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicPopupView.h"
#import "NSString+Extensions.h"

typedef enum {
    RegisterType,               // 注册
    GetPasswordType,            // 取回密码
    FirstSetPasswordType        // 第一次设置密码
} SetPasswordType;

@protocol SetPasswordViewDelegate <NSObject>

- (void)didCancleSetPassword;
- (void)didGetVerifyCodeWithPhoneNum:(NSString*)number;
- (void)didSetPasswordWithPhoneNum:(NSString*)number
                            verify:(NSString*)code
                          password:(NSString*)pwd;

@end

@interface SetPasswordView : UIView <UITextFieldDelegate>
{
    __unsafe_unretained id<SetPasswordViewDelegate> delegate;
    
    SetPasswordType passwordType;
    NSTimer *timer;
    int time;
    
    UIButton *verifyButton;
    UIButton *doneButton;
    
    PublicPopupView *backgroundView;
    UITextField *phoneTextField;
    UITextField *verifyTextFiled;
    UITextField *passwordTextField;
}

@property(nonatomic, unsafe_unretained) __unsafe_unretained id<SetPasswordViewDelegate> delegate;
@property(nonatomic, strong) UITextField *phoneTextField;
@property(nonatomic, strong) UITextField *verifyTextFiled;
@property(nonatomic, strong) UITextField *passwordTextField;
@property(nonatomic) SetPasswordType passwordType;

- (void)setPasswordType:(SetPasswordType)_passwordType phone:(NSString*)_number;

@end
