//
//  SubsChannelsThreadsRequest.m
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SubsChannelsThreadsRequest.h"

@implementation SubsChannelsThreadsRequest

-(id)initWithChannelId:(long)channelId
             newsCount:(NSInteger)newsCount
                  page:(NSInteger)page
{
    if(self = [super init])
    {
        self.coid = channelId;
        self.newsCount = newsCount;
        self.page = page;
    }
    return self;
}
@end
