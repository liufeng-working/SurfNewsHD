//
//  RDCFeedBack.h
//  RDCFeedBack
//
//  Created by 周峰 on 15/2/6.
//  Copyright (c) 2015年 中国移动江苏公司. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - 反馈内容
@interface CMCCFBInfo : NSObject

@property(strong,nonatomic) NSString* type1;/**< 反馈类别一(必填，不能为nil)  */
@property(strong,nonatomic) NSString* type2;/**< 反馈类别二(选填，能为nil)  */
@property(strong,nonatomic) NSString* type3;/**< 反馈类别三(选填，能为nil)  */
@property(strong,nonatomic) NSString* content;/**< 反馈内容(必填，不能为nil)  */

@property(nonatomic) float nps;/**< 软件评分(0-10.0)  */
@property(nonatomic) float sfn;/**<  满意度评分(0-10.0) */

/**
 *  APP推荐度
 *
 *  @param nps nps>=0.0
 *
 *  @return nps<0时返回nil
 */
+(instancetype) initWithNPS:(float) nps;
/**
 *  满意度评分
 *
 *  @param sfn sfn>=0.0
 *
 *  @return sfn<0时返回nil
 */
+(instancetype) initWithSFN:(float) sfn;
/**
 *  意见反馈
 *
 *  @param type    反馈类型（不能为nil）
 *  @param content 反馈内容（不能为nil）
 *
 *  @return if type or conten == nil return nil
 */
+(instancetype) initWithType:(NSString*) type content:(NSString*) content;
/**
 *  意见反馈
 *
 *  @param type1   反馈类型（不能为nil）
 *  @param type2   反馈子类型
 *  @param type3   反馈子类型
 *  @param content 反馈内容（不能为nil）
 *
 *  @return if type or conten == nil return nil
 */
+(instancetype) initWithType1:(NSString*) type1 type2:(NSString*)type2 type3:(NSString*) type3 content:(NSString*) content;


@end


#pragma mark - 反馈人员信息
/**
 *  反馈人员信息
 */
@interface CMCCFBUserInfo : NSObject

@property(strong,nonatomic) NSString* username;/**< 用户姓名(必填)  */
@property(strong,nonatomic) NSString* phone;/**< 用户手机号(必填)  */

/**
 *  反馈人员信息
 *
 *  @param phone 手机号（必填）
 *  @param name  姓名（必填）
 *
 *  @return
 */
+(instancetype) initWithPhone:(NSString*) phone name:(NSString*) name;

@end


#pragma mark - 应用信息
@interface CMCCAppInfo : NSObject

@property(strong,nonatomic) NSString* appkey; /**<  SDK 申请的AppKey */
@property(strong,nonatomic) NSString* appName;/**<  应用名称，如不填，则自动获取 */
@property(strong,nonatomic) NSString* appVersion;/**<  应用版本号，如不填，则自动获取 */


+(instancetype) initWithAppKey:(NSString*) key;
+(instancetype) initWithAppKey:(NSString *)key appName:(NSString*) appName appVersion:(NSString*) appVersion;

@end



#pragma mark - 反馈SDK Public API
/**
 *  上传反馈信息的回掉
 *
 *  @param BOOL     反馈信息是否上传成功
 *  @param NSString 平台返回的具体信息
 */
typedef void(^FeedBackHandler)(BOOL,NSString*);

@interface CMCCFeedBack : NSObject


+(instancetype) initWithFBInfo:(CMCCFBInfo*) fbinfo userInfo:(CMCCFBUserInfo*) userinfo appInfo:(CMCCAppInfo*) appInfo;

/**
 *  异步提交反馈
 *
 *  @param blockHandler 反馈结果处理block
 */
-(void) asyncSendWithHandler:(FeedBackHandler) blockHandler;





@end
