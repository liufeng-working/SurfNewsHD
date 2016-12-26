//
//  ActivityRequest.m
//  SurfNewsHD
//
//  Created by xuxg on 14-4-29.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "ActivityRequest.h"

// 新闻类型中的type==3(活动) 需要生成新的新闻链接
@implementation ActivityRequest

-(instancetype)init:(long)acitityId;
{
    if (self = [super init]) {
        _activityId = acitityId;
    }
    return self;
}
@end
