//
//  SurfAccountRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 13-3-25.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

//获取金币
@interface SurfPostUserScoreRequest : SurfJsonRequestBase

@property NSString *taskId;
@property NSString *type;

@end


//获取个人列表
@interface SurfFindTasksRequest : SurfJsonRequestBase

@end

//获取个人信息
@interface SurfGetUserInfoRequest : SurfJsonRequestBase


- (id)initWithUserId:(NSString *)userId;

@end

@interface SurfModifyUserInfoRequest : SurfJsonRequestBase

@property NSString *nickName;
@property NSString *sex;

- (id)initWithNickName:(NSString *)nickName andSex:(NSString *)sex;

//@property NSString *headPic;//在这里直接给nil，其实有了上传头像的接口，为毛这里还要有这个属性，每次更新的个人信息的话，还得搞张图片占用请求耗时，不得其解...

@end

//登录
@interface SurfLoginRequest : SurfJsonRequestBase

@property NSString *phoneNum;
@property NSString *userPwd;

- (id)initWithPhoneNum:(NSString*)number password:(NSString*)pwd;

@end

//获取验证码
@interface SurfGetVerifyCodeRequest : SurfJsonRequestBase

@property NSString *phoneNum;
@property NSString *capType;                 //1表示注册使用,2表示修改密码用或者首次登录使用

- (id)initWithPhoneNum:(NSString*)number capType:(NSString*)type;

@end

//注册
@interface SurfRegisterUserRequest : SurfJsonRequestBase

@property NSString *verifyCode;
@property NSString *phoneNum;
@property NSString *userPwd;

- (id)initWithPhoneNum:(NSString*)number password:(NSString*)pwd verify:(NSString*)code;

@end

//重置密码
@interface SurfResetPwdRequest : SurfJsonRequestBase

@property NSString *phoneNum;
@property NSString *pwd;                     //newPwd,arc不支持以new开头的变量
@property NSString *verifyCode;

- (id)initWithPhoneNum:(NSString*)number password:(NSString*)pwd verify:(NSString*)code;

@end
