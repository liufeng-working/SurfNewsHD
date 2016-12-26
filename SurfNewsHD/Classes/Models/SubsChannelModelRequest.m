//
//  SubsChannelModelRequest.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//  注：因为订阅这块请求类相对比较小，反复建立也挺烦，想把相关的类都集合到这里。

#import "SubsChannelModelRequest.h"
#import "SubsChannelsListResponse.h"
#import "SubsChannelsManager.h"


@implementation UpdateSubsChannelsLastNewsRequest
@synthesize scids = __ELE_TYPE_SubsChannelLastNewInfo;
@end


@implementation SubsChannelLastNewInfo

@end