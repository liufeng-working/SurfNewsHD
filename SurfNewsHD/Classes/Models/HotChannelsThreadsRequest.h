//
//  HotChannelsThreadsRequest.h
//  SurfNewsHD
//
//  Created by SYZ on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

@interface HotChannelsThreadsRequest : SurfJsonRequestBase

@property long coid;
@property NSInteger newsCount;
@property NSInteger page;

- (id)initWithChannelId:(long)channelId
              newsCount:(NSInteger)newsCount
                   page:(NSInteger)page;

@end
