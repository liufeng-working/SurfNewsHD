//
//  LongPullServletRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 14-3-26.
//  Copyright (c) 2014年 apple. All rights reserved.
//

#import "LongPullServletRequest.h"

@implementation LongPullServletRequest

- (id)initWithIdentifier:(NSString *)identifier
{
    if (self = [super init]) {
        if ([DeviceIdentifier getIMSI]) {
            _imsi = [DeviceIdentifier getIMSI];
        } else {
            _imsi = @"";
        }
        _identifier = identifier;
        _type = 0;     //0为快讯，1为浏览器
    }
    return self;
}

@end
