//
//  SubsChannelsThreadsRequest.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-7.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonRequestBase.h"

@interface SubsChannelsThreadsRequest : SurfJsonRequestBase

@property long coid;
@property NSInteger newsCount;
@property NSInteger page;


-(id)initWithChannelId:(long)channelId
             newsCount:(NSInteger)newsCount
                  page:(NSInteger)page;


@end
