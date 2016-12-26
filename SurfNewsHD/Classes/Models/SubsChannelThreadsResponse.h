//
//  SubsChannelThreadsResponse.h
//  SurfNewsHD
//
//  Created by MacXuXG on 13-1-8.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import "SurfJsonResponseBase.h"

// 订阅频道中的订阅新闻
@interface SubsNewsInfo : NSObject


@end

@interface SubsChannelThreadsResponse : SurfJsonResponseBase

@property int countPage;
@property NSArray* item;

@end
