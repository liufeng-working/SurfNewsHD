//
//  ShareCountStatisticsRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 14-5-15.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "ShareCountStatisticsRequest.h"

@implementation ShareCountStatisticsRequest

- (id)initWithActiveId:(NSString *)activeId shareType:(NSInteger)type
{
    if (self = [super init]) {
        _activeId = activeId;
        _shareType = type;
    }
    return self;
}

@end
