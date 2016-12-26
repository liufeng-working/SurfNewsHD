//
//  SubsChannelModelResponse.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-6-14.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubsChannelModelResponse.h"

@implementation UpdateSubsChannelsLastNewsResponse
@synthesize item = __ELE_TYPE_UpdateSubsChannelInfo;
@end


@implementation UpdateSubsChannelInfo
@synthesize news = __ELE_TYPE_ThreadSummary;
@end

/*
@implementation UpdateNewsInfo

@end
*/