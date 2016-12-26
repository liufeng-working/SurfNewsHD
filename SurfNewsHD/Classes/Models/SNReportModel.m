//
//  SNReportModel.m
//  SurfNewsHD
//
//  Created by XuXg on 15/10/20.
//  Copyright © 2015年 apple. All rights reserved.
//


#import "SNReportModel.h"

// 举报数据模型
@implementation SNReportInfo

/**
 *  将属性名换为其他key去字典中取值
 *
 *  @return 字典中的key是属性名，value是从字典中取值用的key
 */
+ (NSDictionary *)replacedKeyFromPropertyName
{
    return @{@"resportId":@"id"};
}

@end


@implementation SNReportResponse

+ (NSDictionary *)objectClassInArray
{
    return @{@"item" : @"SNReportInfo"};
}
@end



//////////////////////////////////////////
// 提交举报

@implementation SNReportSubmitRequest


@end
