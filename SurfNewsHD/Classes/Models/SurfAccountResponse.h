//
//  SurfAccountResponse.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SurfAccountResponseBase : NSObject

@property int code;
@property NSString *msg;

@end

//登录
@interface SurfLoginResponse : SurfAccountResponseBase

@property NSString *uid;
@property NSString *cityId;
@property int isNew;          //是否第一次登录 1是, 0不是

@end

//获取验证码
@interface SurfGetVerifyCodeResponse : SurfAccountResponseBase

@end

//注册
@interface SurfRegisterUserResponse : SurfAccountResponseBase

@property NSString *uid;
@property NSString *cityId;

@end

//重置密码
@interface SurfResetPwdResponse : SurfAccountResponseBase

@property NSString *uid;

@end