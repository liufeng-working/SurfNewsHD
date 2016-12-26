//
//  SNNotificationUtils.m
//  SurfNewsHD
//
//  Created by XuXg on 15/11/13.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "SNNotificationUtils.h"

@implementation SNNotificationUtils


+(void)addNotifyObserver:(nonnull id)observer
                 selector:(nonnull SEL)aSelector
               notifyType:(nonnull NSString*)nType
{
    if (!observer) {
        return;
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:observer selector:aSelector name:nType object:nil];
}

+(void)removerNotifyObserver:(nonnull id)observer
                   notifyType:(nonnull NSString*)nType
{
    if (!observer) {
        return;
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:observer forKeyPath:nType];
}

+(void)removerAllNotify:(nonnull id)observer
{
    if (!observer) {
        return;
    }
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:observer];
}

/**
 *  发起一个通知
 *
 *  @param nType    通知类型
 *  @param anObject 接受通知者，可能需要的参数，可以为空
 */
+(void)pushNotifyWithType:(nonnull NSString*)nType
                   object:(nullable id)anObject
{
    if (!nType || [nType isEmptyOrBlank]) {
        return;
    }
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:nType object:anObject];
}

@end
