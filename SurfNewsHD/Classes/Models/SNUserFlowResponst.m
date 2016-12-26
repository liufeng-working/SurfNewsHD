//
//  SNUserFlowResponst.m
//  SurfNewsHD
//
//  Created by XuXg on 15/10/12.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "SNUserFlowResponst.h"

@implementation PackflowData

@end


@implementation VoicePackFlowData
@end


@implementation SNUserFlowResponst
/**
 *  数组中需要转换的模型类
 *
 *  @return 字典中的key是数组属性名，value是数组中存放模型的Class（Class类型或者NSString类型）
 */
+ (NSDictionary *)objectClassInArray
{
    return @{
             @"packflow" : @"PackflowData",
             @"voicepackflow" : @"VoicePackFlowData"
             };
}
@end
