//
//  CheckRecommendRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 13-12-30.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "CheckRecommendRequest.h"
#import "Encrypt.h"

@implementation CheckRecommendRequest

- (id)init
{
    if(self = [super init]) {
        if ([DeviceIdentifier getIMSI]) {
            _imsi = [Encrypt encryptUseDES:[DeviceIdentifier getIMSI]];
        }
    }
    return self;
}

@end
