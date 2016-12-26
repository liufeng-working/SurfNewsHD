//
//  SubsChannelsListResponse.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubsChannelsListResponse.h"

@implementation SubsChannelsListResponse

@synthesize item = __ELE_TYPE_SubsChannel;


@end


@implementation SubsChannel

@synthesize channelId = __KEY_NAME_columnId;
@synthesize index = __KEY_NAME_indexId;
@synthesize newThreadSummaryCount = __DO_NOT_SERIALIZE_;
@end