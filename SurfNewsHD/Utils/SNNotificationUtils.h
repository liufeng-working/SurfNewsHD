//
//  SNNotificationUtils.h
//  SurfNewsHD
//
//  Created by XuXg on 15/11/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  定义通知类型，重点：（不能重名，不能重名，不能重名）重要的事说三遍。
 */

// 新闻频道中的美女频道，美女列表坐标发生改变。
#define kNotifyType_BeautyList_Pointer_Changed @"beautyListPointerChanged"




/**
 *  冲浪快讯通知管理器，工程中已经分散了好多通知，我就不归集了，
 *  只在后续的开发中，一步一步的归集到这个类中，来统一管理。
 */
@interface SNNotificationUtils : NSObject


+(void)addNotifyObserver:(nonnull id)observer
                selector:(nonnull SEL)aSelector
              notifyType:(nonnull NSString*)nType;


/**
 *  删除观察者中指定类型的通知监听
 *
 *  @param observer 观察者
 *  @param nType    通知类型
 */
+(void)removerNotifyObserver:(nonnull id)observer
                  notifyType:(nonnull NSString *)nType;

/**
 *  删除观察者中得所有类型通知
 *
 *  @param observer 观察者
 */
+(void)removerAllNotify:(nonnull id)observer;


/**
 *  发起一个通知
 *
 *  @param nType    通知类型
 *  @param anObject 接受通知者，可能需要的参数，可以为空
 */
+(void)pushNotifyWithType:(nonnull NSString*)nType
                   object:(nullable id)anyObject;

@end
