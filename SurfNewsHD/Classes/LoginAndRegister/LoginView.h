//
//  LoginView.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-22.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicPopupView.h"

@protocol LoginViewDelegate <NSObject>

- (void)didRegisterAction;
- (void)didLoginAction:(NSString*)phone password:(NSString*)pwd;
- (void)didResetPasswordAction;

@end

@interface LoginView : UIView <UITextFieldDelegate>
{
    PublicPopupView *backgroundView;
    UITextField *phoneTextField;
    UITextField *passwordTextField;
    UIImageView *whyLogin;
}

@property(nonatomic, unsafe_unretained) id<LoginViewDelegate> delegate;
@property(nonatomic, strong) UITextField *phoneTextField;
@property(nonatomic, strong) UITextField *passwordTextField;

- (void)clearTextFiled;
- (void)hiddenView;

@end
