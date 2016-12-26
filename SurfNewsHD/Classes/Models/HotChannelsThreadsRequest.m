//
//  HotChannelsThreadsRequest.m
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "HotChannelsThreadsRequest.h"

@implementation HotChannelsThreadsRequest

- (id)initWithChannelId:(long)channelId
              newsCount:(NSInteger)newsCount
                   page:(NSInteger)page
{
    if (self = [super init]) {
        self.coid = channelId;
        self.newsCount = newsCount;
        self.page = page;
    }
    
    return self;
}

@end

