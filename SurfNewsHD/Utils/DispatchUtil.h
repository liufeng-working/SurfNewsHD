//
//  DispatchUtil.h
//  SurfNewsHD
//
//  Created by yuleiming on 14-7-8.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DispatchHandler)();

@interface DispatchUtil : NSObject

/**
 延迟delayInSeconds秒后，在主线程中执行handler
 */
+(void)dispatch:(DispatchHandler)handler after:(double)delayInSeconds;

@end
