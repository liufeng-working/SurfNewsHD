//
//  DispatchUtil.m
//  SurfNewsHD
//
//  Created by yuleiming on 14-7-8.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "DispatchUtil.h"

@implementation DispatchUtil

/**
 *  异步工具函数
 *
 *  @param handler        block 对象
 *  @param delayInSeconds 延迟时间(秒)
 */
+(void)dispatch:(DispatchHandler)handler after:(double)delayInSeconds
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        handler();
    });
}

@end
