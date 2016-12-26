//
//  UserManager.h
//  SurfNewsHD
//
//  Created by apple on 13-3-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfRequestGenerator.h"
#import "SurfAccountResponse.h"
#import "AppSettings.h"
#import "SNUserFlowResponst.h"


typedef SNUserFlowResponst SNUserFlow;
@class MagazinesSortInfo;
@class SubsChannelsSortInfo;
@class UserTaskData;



@protocol UserManagerObserver <NSObject>

@required
-(void)currentUserLoginChanged;
@end


@interface UserDes : NSObject

@property(nonatomic,strong) NSString *nickName;
@property(nonatomic,strong) NSString *headPic;
@property(nonatomic,strong) NSString *sex;
@property(nonatomic,strong) NSString *credit;//积分
@property(nonatomic,strong) NSString *lvl;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *upgradeCredit;//升级所需积分

@end

@interface UserInfo : NSObject

@property(nonatomic,strong) NSString *phoneNum;
@property(nonatomic,strong) NSString *password;
@property(nonatomic,strong) NSString *userID;
@property(nonatomic,strong) NSString *encryptUserID;
@property(nonatomic,strong) NSString *cityId;
@property(nonatomic,strong) SubsChannelsSortInfo *subsChannelsSortInfo;
@property(nonatomic,strong) MagazinesSortInfo *magazinesSortInfo;
@property(nonatomic) NSInteger isValid;          //保存的userInfo是否有用,1:有用, 0:无用

@property(nonatomic,strong) NSString *selectedMoreVC;

@property(nonatomic, strong)UserDes *userDes;

@property(nonatomic, strong)UserTaskData *userGold;

@end



@interface UserTaskData : NSObject

@property(nonatomic,strong) NSString *desc;
@property(nonatomic,strong) NSString *exp;
@property(nonatomic,strong) NSString *finishNum;
@property(nonatomic,strong) NSString *gold;
@property(nonatomic,strong) NSString *id_id;
@property(nonatomic,strong) NSString *stateDesc;
@property(nonatomic,strong) NSString *title;
@property(nonatomic,strong) NSString *type;
@property(nonatomic,strong) NSString *totalNum;

@end



@interface UserManager : NSObject
{
    __strong NSMutableArray* observers_;
    UserInfo *loginedUser;
    SNUserFlow *_userFlow;
}

+(UserManager*)sharedInstance;

//返回已登陆用户，未登陆返回空
-(UserInfo *)loginedUser;

//退出登录
-(void)quitLogin;

//用户登陆
-(void)userLogin:(NSString *)phoneNum
        password:(NSString *)password
withCompletionHandler:(void(^)(BOOL succeeded, NSInteger code))handler;

//获得验证码
-(void)getVerifyCode:(NSString*)phoneNum
             capType:(NSString*)type
withCompletionHandler:(void(^)(BOOL succeeded, NSInteger code))handler;

//用户注册
-(void)userRegister:(NSString*)phoneNum
           password:(NSString *)password
             verify:(NSString*)code
withCompletionHandler:(void(^)(BOOL succeeded, NSInteger code))handler;

//重置密码
-(void)resetPassword:(NSString*)phoneNum
            password:(NSString *)password
              verify:(NSString*)code
withCompletionHandler:(void(^)(BOOL succeeded, NSInteger code))handler;

-(void)addUserLoginObserver:(id<UserManagerObserver>)observer;
-(void)removeUserLoginObserver:(id<UserManagerObserver>)observer;

//注销用户
- (void)removeUserInfo:(void(^)(BOOL))result;

-(void)savePathOfUserInfo;

//登录后获取订阅关系
- (void)getSubsAfterLogin:(id)resp
                    phone:(NSString *)phoneNum
    withCompletionHandler:(void (^)(BOOL succeeded))handler;


- (void)writeToSelectedMoreVC:(NSString* )writeStr;
- (BOOL)readFileArraySelectedMoreVC;


//1.1获取个人信息
-(void)findUserInfowithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler;


//更新个人信息
- (void)modifyUserInfoNickName:(NSString *)nickName andSex:(NSString *)Sex WithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler;

//上传头像
- (void)uploadHeadPic:(UIImage *)imageData_PNG WithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler;

//获取任务列表
- (void)findTasksWithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler;

//领取金币

- (void)postUserScoreWithCompletionHandler:(void(^)(BOOL succeeded, NSDictionary *dicData))handler;

// 获取用户流量，必须是登录用户，否则获取不到数据
-(void)userFlowInfo:(void(^)(SNUserFlow *flowInfo))handler;
@end
